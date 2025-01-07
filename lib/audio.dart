import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Voice Message Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              VoiceMessageWidget(
                audiopath:
                    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                isSender: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoiceMessageWidget extends StatefulWidget {
  final String audiopath;
  final bool isSender;

  VoiceMessageWidget({required this.audiopath, required this.isSender});

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  AudioPlayer player = AudioPlayer();
  final PlayerController playerController = PlayerController();

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });

    player.onPositionChanged.listen((p) {
      setState(() {
        position = p;
        // Sync player position with the waveform position
       // playerController.seekTo(p.inMilliseconds.toDouble());
       playerController.seekTo(p.inMilliseconds);
      });
    });

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero; // Reset position to start
        playerController.seekTo(0);
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

   // print("controller ---------------->${playerController}");
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color:
                      widget.isSender ? Color(0xffF3F3F3) : Color(0xff1C6593),
                ),
                onPressed: () {
                  if (isPlaying) {
                    player.pause();
                  } else {
                    _playAudio(widget.audiopath);
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
              Expanded(
                child: AudioFileWaveforms(
                  backgroundColor: Colors.blue,
                  animationCurve: Curves.bounceIn,
                  continuousWaveform: true,
                  animationDuration: Duration(seconds: 50),
                  waveformType: WaveformType.long,
                  margin: EdgeInsets.all(10),
                  enableSeekGesture: true,
                  playerWaveStyle: PlayerWaveStyle(
                    showTop: true,
                    showSeekLine: true,
                    fixedWaveColor: Colors.amber,
                    backgroundColor: Colors.red,
                  ),
                  playerController: playerController,
                  size: Size(300, 100), // Set size for waveform
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color:
                        widget.isSender ? Color(0xffF3F3F3) : Color(0xff1C6593),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color:
                        widget.isSender ? Color(0xffF3F3F3) : Color(0xff1C6593),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _playAudio(String path) async {
    try {
      if (path.contains('http') || path.contains('www')) {
        // For online URLs
        await player.setSourceUrl(path);
      } else {
        // For local assets
        await player.setSourceAsset(path);
      }
      await player.resume();
      playerController.startPlayer();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }
}
