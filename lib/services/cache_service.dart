import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/models.dart';

class CacheService {
  final Dio _dio = Dio();

  Future<String> downloadTrack(MusicTrack track) async {
    if (track.audioUrl == null) throw Exception("No audio URL provided");

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tracks/${track.id}.mp3';
    
    // Create directory if it doesn't exist
    final file = File(filePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    if (await file.exists()) return filePath;

    try {
      await _dio.download(track.audioUrl!, filePath);
      return filePath;
    } catch (e) {
      throw Exception("Download failed: $e");
    }
  }

  Future<bool> isTrackDownloaded(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tracks/$id.mp3';
    return await File(filePath).exists();
  }
}
