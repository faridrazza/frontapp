import 'dart:convert';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class AudioUtils {
  static AudioPlayer? _audioPlayer;
  static final Logger _logger = Logger();

  static Future<void> playAudio(String audioBuffer, {Function? onComplete}) async {
    try {
      // Stop any existing playback
      await stopAudio();
      
      // Create new player instance
      _audioPlayer = AudioPlayer();
      
      // Convert base64 to bytes
      final bytes = base64Decode(audioBuffer);
      
      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.mp3');
      await tempFile.writeAsBytes(bytes);
      
      // Set up completion listener
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          onComplete?.call();
        }
      });

      // Play audio
      await _audioPlayer!.setFilePath(tempFile.path);
      await _audioPlayer!.play();
    } catch (e) {
      _logger.e('Error playing audio: $e');
      onComplete?.call();
      rethrow;
    }
  }

  static Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (e) {
      _logger.e('Error stopping audio: $e');
    }
  }

  static void dispose() {
    stopAudio();
  }
}