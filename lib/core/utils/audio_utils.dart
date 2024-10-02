import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';

class AudioUtils {
  static FlutterSoundRecorder? _recorder;
  static FlutterSoundPlayer? _player;

  static Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  static Future<void> startRecording() async {
    await _recorder!.startRecorder(toFile: 'temp.aac');
  }

  static Future<String?> stopRecording() async {
    return await _recorder!.stopRecorder();
  }

  static Future<void> playAudio(String audioBase64) async {
    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      final audioData = base64Decode(audioBase64);
      await _player!.startPlayer(fromDataBuffer: audioData);
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  static Future<void> stopAudio() async {
    try {
      if (_player != null && _player!.isPlaying) {
        await _player!.stopPlayer();
        await _player!.closePlayer();
        _player = null;
      }
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }
}