import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';
import 'package:radio_nueva_esperanza/data/services/mixlr_service.dart';

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

    // Listen to ICY Metadata (Stream Titles)
    _player.icyMetadataStream.listen((metadata) {
      if (metadata != null && metadata.info != null) {
        final title = metadata.info!.title;
        final url = metadata.info!.url;

        print("--- DEBUG: ICY Metadata Received: $title (URL: $url) ---");

        if (title != null && title.isNotEmpty) {
          // Update MediaItem with new title
          final currentItem = mediaItem.value ??
              MediaItem(id: _streamUrl, title: "Radio Nueva Esperanza");

          mediaItem.add(currentItem.copyWith(
            title: title,
            artist: "En Vivo",
            // Keep existing art or update if metadata provides one (rare for ICY)
          ));
        }
      }
    });
  }

  @override
  Future<void> play() async {
    // ... existing logic ...
    await _playStream();
  }

  Future<void> _playStream() async {
    // Logic from original play() moved here
    try {
      // Fetch dynamic URL from config
      String urlToPlay = _streamUrl;
      try {
        final config = await DataRepository().getAppConfig();
        if (config.streamUrl.isNotEmpty) {
          urlToPlay = config.streamUrl;
        }
      } catch (e) {
        print("Warning fetching config: $e");
      }

      // Mixlr Resolution (NEW)
      String initialTitle = "Radio Nueva Esperanza";
      if (urlToPlay.contains('mixlr.com') && !urlToPlay.contains('edge')) {
        print("--- INFO: Attempting to resolve Mixlr URL: $urlToPlay ---");
        final resolved = await MixlrService().resolveStream(urlToPlay);
        if (resolved != null) {
          if (resolved['streamUrl'] != null) {
            urlToPlay = resolved['streamUrl']!;
            print("--- INFO: Resolved Stream URL: $urlToPlay ---");
          }
          if (resolved['title'] != null) {
            initialTitle = resolved['title']!;
          }
        }
      }

      // Check if we need to reload:
      // 1. If player is idle
      // 2. If current item is NOT the stream (e.g. came from podcast)
      bool needsReload = _player.processingState == ProcessingState.idle ||
          mediaItem.value?.id != urlToPlay;

      if (needsReload) {
        await _player.stop();
        await _player.setUrl(urlToPlay);

        mediaItem.add(MediaItem(
          id: urlToPlay,
          title: initialTitle,
          artist: "En Vivo",
          artUri: Uri.parse("https://via.placeholder.com/300"),
        ));
      }
    } catch (e) {
      print("Error loading stream: $e");
      return;
    }

    _player.play();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    try {
      await _player.stop(); // Stop current stream
      await _player.setUrl(uri.toString());

      mediaItem.add(MediaItem(
        id: uri.toString(),
        title: extras?['title'] ?? "Podcast",
        artist: extras?['artist'] ?? "Radio Nueva Esperanza",
        artUri: Uri.parse("https://via.placeholder.com/300"),
      ));

      _player.play();
    } catch (e) {
      print("Error playing URI: $e");
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  // Dispose player when app is killed? Usually handled by OS/AudioService
}
