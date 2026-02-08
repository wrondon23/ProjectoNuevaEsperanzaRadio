import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

class RadioProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;
  
  bool _isPlaying = false;
  bool _isLoading = false;
  String _statusMessage = "Listo para reproducir";

  RadioProvider(this._audioHandler) {
    _listenToPlaybackState();
  }

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      _isPlaying = isPlaying;
      
      switch (processingState) {
        case AudioProcessingState.idle:
          _isLoading = false;
          _statusMessage = "Listo para reproducir";
          break;
        case AudioProcessingState.loading:
          _isLoading = true;
          _statusMessage = "Conectando...";
          break;
        case AudioProcessingState.buffering:
          _isLoading = true;
          _statusMessage = "Buffering...";
          break;
        case AudioProcessingState.ready:
          _isLoading = false;
          _statusMessage = "En Vivo";
          break;
        case AudioProcessingState.error:
          _isLoading = false;
          _statusMessage = "Error de conexión";
          break;
        default:
          _isLoading = false;
          _statusMessage = "";
      }
      
      notifyListeners();
    });
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }
}
