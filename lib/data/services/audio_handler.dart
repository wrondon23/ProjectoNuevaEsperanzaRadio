import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.nuevaesperanza.radio.channel.audio',
      androidNotificationChannelName: 'Radio Nueva Esperanza',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  // Use a placeholder URL or the real one if known.
  // Using a sample reliable stream for testing purposes if user didn't provide specific one yet.
  // Replaced with a placeholder variable as requested.
  // Placeholder static MP3 for testing (SoundHelix)
  // Using a static file to rule out streaming server issues.
  static const _streamUrl =
      'https://edge.mixlr.com/channel/mkjhc'; // RELIABLE TEST FILE

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToPlaybackState();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      print(
          "--- DEBUG: Playback Event: playing=$playing, processingState=${_player.processingState}, position=${_player.position} ---");

      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    }, onError: (Object e, StackTrace stack) {
      print("--- ERROR: Playback Event Stream Error: $e ---");
    });
  }

  void _listenToPlaybackState() {
    _player.playerStateStream.listen((playerState) {
      print("--- DEBUG: Player State Changed: $playerState ---");
      if (playerState.processingState == ProcessingState.completed) {
        print("--- DEBUG: Track completed ---");
      }
    });

    _player.volumeStream.listen((volume) {
      print("--- DEBUG: Player Volume: $volume ---");
    });
  }

  @override
  Future<void> play() async {
    // If not loaded, load the source
    if (_player.processingState == ProcessingState.idle) {
      try {
        await _player.setUrl(_streamUrl);

        // Update metadata for lock screen
        mediaItem.add(MediaItem(
          id: _streamUrl,
          title: "Radio Nueva Esperanza",
          artist: "En Vivo",
          artUri: Uri.parse("https://via.placeholder.com/300"), // Placeholder
        ));
      } catch (e) {
        print("Error loading stream: $e");
        // Handle error state
        return;
      }
    }
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  // Dispose player when app is killed? Usually handled by OS/AudioService
}
