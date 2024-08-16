import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class FlashcardAudioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    _audioPlayer.positionStream,
    _audioPlayer.bufferedPositionStream,
    _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
      position,
      bufferedPosition,
      duration ?? Duration.zero,
    ),
  );

  Future<void> play(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
