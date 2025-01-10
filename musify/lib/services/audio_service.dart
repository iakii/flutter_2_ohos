/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
// Project imports:
import 'package:musify/API/musify.dart';
import 'package:musify/main.dart';
import 'package:musify/models/position_data.dart';
import 'package:musify/services/data_manager.dart';
import 'package:musify/services/settings_manager.dart';
import 'package:musify/utilities/mediaitem.dart';
import 'package:rxdart/rxdart.dart';

class MusifyAudioHandler extends BaseAudioHandler {
  MusifyAudioHandler() {
    _setupEventSubscriptions();
    _updatePlaybackState();

    _initialize();
  }

  final AudioPlayer audioPlayer = AudioPlayer(
    userAgent: 'https://www.bilibili.com/',
    useProxyForRequestHeaders: false,
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        maxBufferDuration: Duration(seconds: 80),
        bufferForPlaybackDuration: Duration(milliseconds: 500),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
      ),
    ),
  );

  late StreamSubscription<PlaybackEvent> _playbackEventSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;

  Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  final processingStateMap = {
    ProcessingState.idle: AudioProcessingState.idle,
    ProcessingState.loading: AudioProcessingState.loading,
    ProcessingState.buffering: AudioProcessingState.buffering,
    ProcessingState.ready: AudioProcessingState.ready,
    ProcessingState.completed: AudioProcessingState.completed,
  };

  void _handlePlaybackEvent(PlaybackEvent event) {
    try {
      if (event.processingState == ProcessingState.completed && audioPlayer.playing) {
        skipToNext();
      }
      _updatePlaybackState();
    } catch (e, stackTrace) {
      logger.log('Error handling playback event', e, stackTrace);
    }
  }

  void _handleDurationChange(Duration? duration) {
    try {
      final index = audioPlayer.currentIndex;
      if (index != null && queue.value.isNotEmpty) {
        final newQueue = List<MediaItem>.from(queue.value);
        final oldMediaItem = newQueue[index];
        final newMediaItem = oldMediaItem.copyWith(duration: duration);
        newQueue[index] = newMediaItem;
        queue.add(newQueue);
        mediaItem.add(newMediaItem);
      }
    } catch (e, stackTrace) {
      logger.log('Error handling duration change', e, stackTrace);
    }
  }

  void _handleCurrentSongIndexChanged(int? index) {
    try {
      if (index != null && queue.value.isNotEmpty) {
        final playlist = queue.value;
        mediaItem.add(playlist[index]);
      }
    } catch (e, stackTrace) {
      logger.log(
        'Error handling current song index change',
        e,
        stackTrace,
      );
    }
  }

  void _handleSequenceStateChange(SequenceState? sequenceState) {
    try {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence != null && sequence.isNotEmpty) {
        final items = sequence.map((source) => source.tag as MediaItem).toList();
        queue.add(items);
        shuffleNotifier.value = sequenceState?.shuffleModeEnabled ?? false;
      }
    } catch (e, stackTrace) {
      logger.log('Error handling sequence state change', e, stackTrace);
    }
  }

  void _setupEventSubscriptions() {
    _playbackEventSubscription = audioPlayer.playbackEventStream.listen(_handlePlaybackEvent);
    _durationSubscription = audioPlayer.durationStream.listen(_handleDurationChange);
    _currentIndexSubscription = audioPlayer.currentIndexStream.listen(_handleCurrentSongIndexChanged);
    _sequenceStateSubscription = audioPlayer.sequenceStateStream.listen(_handleSequenceStateChange);
  }

  void _updatePlaybackState() {
    final hasPreviousOrNext = hasPrevious || hasNext;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (hasPreviousOrNext) MediaControl.skipToPrevious else MediaControl.rewind,
          if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
          if (hasPreviousOrNext) MediaControl.skipToNext else MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingStateMap[audioPlayer.processingState]!,
        repeatMode: repeatNotifier.value,
        shuffleMode: audioPlayer.shuffleModeEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: audioPlayer.playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: audioPlayer.currentIndex ?? 0,
      ),
    );
  }

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    try {
      await session.configure(const AudioSessionConfiguration.music());
      session.interruptionEventStream.listen((event) async {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              await audioPlayer.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              await audioPlayer.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              await audioPlayer.setVolume(1);
              break;
            case AudioInterruptionType.pause:
              await audioPlayer.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (e, stackTrace) {
      logger.log('Error initializing audio session', e, stackTrace);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await audioPlayer.stop().then((_) => audioPlayer.dispose());

    await _playbackEventSubscription.cancel();
    await _durationSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _sequenceStateSubscription.cancel();

    await super.onTaskRemoved();
  }

  bool get hasNext => activePlaylist['list'].isEmpty ? audioPlayer.hasNext : activeSongId + 1 < activePlaylist['list'].length;

  bool get hasPrevious => activePlaylist['list'].isEmpty ? audioPlayer.hasPrevious : activeSongId > 0;

  @override
  Future<void> play() => audioPlayer.play();
  @override
  Future<void> pause() => audioPlayer.pause();
  @override
  Future<void> stop() => audioPlayer.stop();
  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  @override
  Future<void> fastForward() => seek(Duration(seconds: audioPlayer.position.inSeconds + 15));

  @override
  Future<void> rewind() => seek(Duration(seconds: audioPlayer.position.inSeconds - 15));

  Future<void> playSong(Map song) async {
    try {
      final isOffline = song['isOffline'] ?? false;
      final songUrl = isOffline ? song['audioPath'] : await getSong(song['ytid'], song['isLive']);

      // songUrl =
      //     'https://upos-sz-mirrorcos.bilivideo.com/ugaxcode/n230903a22zx6glzv1gq5h1l6s7febsw-320k.m4a?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEuENvNC8aNEVEtEvE9IMvXBvE2ENvNCImNEVEIj0Y2J_aug859r1qXg8xNEVE5XREto8GuFGv2U7SuxI72X6fTr859IB_&uipk=5&nbs=1&deadline=1736513770&gen=playurlv2&os=cosbv&oi=177921628&trid=83859b3c49ef4f03bb4e7964c58e9b38B&mid=0&platform=android&og=cos&upsig=7f2d298560b3cb2ffc1294a3a6d0460b&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&bvc=vod&nettype=0&orderid=0,1&logo=00000000';

//    options: Options(responseType: ResponseType.stream),
      // await Client().get(Uri.parse(songUrl), headers: {
      //   'responseType': 'stream',
      // }).then((value) {
      //   print(value.statusCode);
      // });

      final audioSource = await buildAudioSource(song, songUrl, isOffline);

      await audioPlayer.setAudioSource(audioSource);
      await audioPlayer.play();
    } catch (e, stackTrace) {
      logger.log('Error playing song', e, stackTrace);
    }
  }

  Future<void> playPlaylistSong({
    Map<dynamic, dynamic>? playlist,
    required int songIndex,
  }) async {
    if (playlist != null) activePlaylist = playlist;
    activeSongId = songIndex;
    await audioHandler.playSong(activePlaylist['list'][activeSongId]);
  }

  Future<AudioSource> buildAudioSource(
    Map song,
    String songUrl,
    bool isOffline,
  ) async {
    final uri = Uri.parse(songUrl);
    final tag = mapToMediaItem(song, songUrl);
    final audioSource = AudioSource.uri(uri, tag: tag);

    if (isOffline || !sponsorBlockSupport.value) {
      return audioSource;
    }

    final spbAudioSource = await checkIfSponsorBlockIsAvailable(audioSource, song['ytid']);
    return spbAudioSource ?? audioSource;
  }

  Future<ClippingAudioSource?> checkIfSponsorBlockIsAvailable(
    UriAudioSource audioSource,
    String songId,
  ) async {
    try {
      final segments = await getSkipSegments(songId);

      if (segments.isNotEmpty) {
        final start = Duration(seconds: segments[0]['end']!);
        final end = segments.length > 1 ? Duration(seconds: segments[1]['start']!) : null;

        return end != null && end != Duration.zero && start < end
            ? ClippingAudioSource(
                child: audioSource,
                start: start,
                end: end,
                tag: audioSource.tag,
              )
            : null;
      }
    } catch (e, stackTrace) {
      logger.log('Error checking sponsor block', e, stackTrace);
    }
    return null;
  }

  Future<void> skipToSong(int newIndex) async {
    if (newIndex >= 0 && newIndex < activePlaylist['list'].length) {
      activeSongId = shuffleNotifier.value ? _generateRandomIndex(activePlaylist['list'].length) : newIndex;

      await playSong(activePlaylist['list'][activeSongId]);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (!hasNext && repeatNotifier.value == AudioServiceRepeatMode.all) {
      // If repeat mode is set to repeat the playlist, start from the beginning
      await skipToSong(0);
    } else if (!hasNext && playNextSongAutomatically.value && nextRecommendedSong != null) {
      // If there's no next song but playNextSongAutomatically is enabled, play the recommended song
      await playSong(nextRecommendedSong);
    } else if (hasNext) {
      // If there is a next song, skip to the next song
      await skipToSong(activeSongId + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (!hasPrevious && repeatNotifier.value == AudioServiceRepeatMode.all) {
      // If repeat mode is set to repeat the playlist, start from the end
      await skipToSong(activePlaylist['list'].length - 1);
    } else if (hasPrevious) {
      // If there is a previous song, skip to the previous song
      await skipToSong(activeSongId - 1);
    }
  }

  Future<void> playAgain() async {
    await audioPlayer.seek(Duration.zero);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final shuffleEnabled = shuffleMode != AudioServiceShuffleMode.none;
    shuffleNotifier.value = shuffleEnabled;
    await audioPlayer.setShuffleModeEnabled(shuffleEnabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // we use this only when we want to loop single song
    await audioPlayer.setLoopMode(
      repeatMode == AudioServiceRepeatMode.all ? LoopMode.one : LoopMode.off,
    );
  }

  void changeSponsorBlockStatus() {
    sponsorBlockSupport.value = !sponsorBlockSupport.value;
    addOrUpdateData(
      'settings',
      'sponsorBlockSupport',
      sponsorBlockSupport.value,
    );
  }

  void changeAutoPlayNextStatus() {
    playNextSongAutomatically.value = !playNextSongAutomatically.value;
    addOrUpdateData(
      'settings',
      'playNextSongAutomatically',
      playNextSongAutomatically.value,
    );
  }

  int _generateRandomIndex(int length) {
    final random = Random();
    var randomIndex = random.nextInt(length);

    while (randomIndex == activeSongId) {
      randomIndex = random.nextInt(length);
    }

    return randomIndex;
  }
}
