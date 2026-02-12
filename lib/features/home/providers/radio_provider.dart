import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:radio_nueva_esperanza/data/models/podcast_model.dart';

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

    _audioHandler.mediaItem.listen((mediaItem) {
      _currentMediaItem = mediaItem;
      notifyListeners();
    });
  }

  // --- Sleep Timer ---
  Timer? _sleepTimer;
  Timer? _countdownTimer;
  Duration? _timeRemaining;

  Duration? get timeRemaining => _timeRemaining;

  void setSleepTimer(Duration duration) {
    cancelSleepTimer();
    _timeRemaining = duration;
    notifyListeners();

    // Actual sleep action
    _sleepTimer = Timer(duration, () {
      _audioHandler.pause();
      cancelSleepTimer();
    });

    // Countdown for UI
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining != null && _timeRemaining!.inSeconds > 0) {
        _timeRemaining = _timeRemaining! - const Duration(seconds: 1);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    _sleepTimer = null;
    _countdownTimer = null;
    _timeRemaining = null;
    notifyListeners();
  }

  @override
  void dispose() {
    cancelSleepTimer();
    super.dispose();
  }

  MediaItem? _currentMediaItem;
  MediaItem? get currentMediaItem => _currentMediaItem;

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> playPodcast(PodcastModel podcast) async {
    try {
      // Assuming we implement playFromUri in our handler
      await _audioHandler.playFromUri(Uri.parse(podcast.audioUrl),
          {'title': podcast.title, 'artist': podcast.speaker});
    } catch (e) {
      print("Error playing podcast: $e");
    }
  }
}
