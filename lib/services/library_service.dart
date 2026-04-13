import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models.dart';


final libraryProvider = Provider((ref) => LibraryRepository());

class LibraryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Liked Songs
  Stream<List<MusicTrack>> getLikedSongs() {
    if (_userId == null) return Stream.value([]);
    return _db.collection('users').doc(_userId).collection('liked_songs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MusicTrack.fromMap(doc.data())).toList();
    });
  }

  Future<void> toggleLike(MusicTrack track) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId).collection('liked_songs').doc(track.id);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(track.copyWith(isLiked: true).toMap());
    }
  }

  // Playlists
  Stream<List<MusicPlaylist>> getPlaylists() {
    if (_userId == null) return Stream.value([]);
    return _db.collection('users').doc(_userId).collection('playlists').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MusicPlaylist.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> createPlaylist(String name) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('playlists').add({
      'name': name,
      'ownerId': _userId,
      'trackIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('playlists').doc(playlistId).update({
      'name': newName,
    });
  }

  Future<void> addTrackToPlaylist(String playlistId, MusicTrack track) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('playlists').doc(playlistId).update({
      'trackIds': FieldValue.arrayUnion([track.id]),
    });
    // Also save track metadata if not exists
    await _db.collection('tracks').doc(track.id).set(track.toMap(), SetOptions(merge: true));
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('playlists').doc(playlistId).update({
      'trackIds': FieldValue.arrayRemove([trackId]),
    });
  }
}

final likedSongsProvider = StreamProvider<List<MusicTrack>>((ref) {
  return ref.watch(libraryProvider).getLikedSongs();
});

final userPlaylistsProvider = StreamProvider<List<MusicPlaylist>>((ref) {
  return ref.watch(libraryProvider).getPlaylists();
});
