import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final doc = await _db.collection('users').doc(currentUser!.uid).get();
    return doc.data()?['role'] == 'admin' || currentUser!.email == 'isaacpille@icloud.com';
  }

  Future<void> signup(String name, String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await _db.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'user',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    // Check if banned
    final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
    if (doc.data()?['status'] == 'banned') {
      await logout();
      throw Exception("Votre compte a été banni.");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
