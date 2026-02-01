import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  // --- Singleton ---
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playRideRequestTone() async {
    if (_isPlaying) return;

    _isPlaying = true;

    await _player.setReleaseMode(ReleaseMode.loop);

    await _player.play(AssetSource('sounds/ringing.mp3'), volume: 1.0);
    // await _player.play(AssetSource('ringing.mp3'), volume: 1.0);
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    _isPlaying = false;
    await _player.stop();
  }

  Future<void> dispose() async {
    _isPlaying = false;
    await _player.dispose();
  }
}
