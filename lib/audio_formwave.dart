import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class NetworkAudioWaveformPlayer extends StatefulWidget {
  @override
  _NetworkAudioWaveformPlayerState createState() =>
      _NetworkAudioWaveformPlayerState();
}

class _NetworkAudioWaveformPlayerState
    extends State<NetworkAudioWaveformPlayer> {
  late PlayerController _playerController;
  final String audioUrl =
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; // Replace with your audio URL
  int currentDuration = 0; // Current playback position in milliseconds
  String errorMessage = ""; // To display error messages

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();

    // Enable debug logging for troubleshooting
  //  _playerController.enableLogging = true;

    // Prepare the player with a network audio file
    _preparePlayer();
  }

  Future<void> _preparePlayer() async {
    try {
      await _playerController.preparePlayer(
        path: audioUrl,
        shouldExtractWaveform: true,
      );
      _playerController.onCurrentDurationChanged.listen((duration) {
        setState(() {
          currentDuration = duration;
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error preparing audio player: $e";
      });
      print(errorMessage);
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Audio Player"),
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Waveform Display
                AudioFileWaveforms(
                  size: Size(double.infinity, 100),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  waveformType: WaveformType.long,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: Colors.blueAccent,
                    liveWaveColor: Colors.blue,
                    showSeekLine: true,
                    seekLineColor: Colors.red,
                  ),
                ),
                // Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10),
                      onPressed: () {
                        int newPosition =
                            currentDuration - 10000; // Move back 10 seconds
                        _playerController.seekTo(
                          newPosition.clamp(
                              0, _playerController.maxDuration ?? 0),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _playerController.playerState == PlayerState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (_playerController.playerState ==
                            PlayerState.playing) {
                          _playerController.pausePlayer();
                        } else {
                          _playerController.startPlayer();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10),
                      onPressed: () {
                        int newPosition =
                            currentDuration + 10000; // Move forward 10 seconds
                        _playerController.seekTo(
                          newPosition.clamp(
                              0, _playerController.maxDuration ?? 0),
                        );
                      },
                    ),
                  ],
                ),
                // Display Current Duration
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Current Position: ${(currentDuration / 1000).toStringAsFixed(1)} seconds",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
