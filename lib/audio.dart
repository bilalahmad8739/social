import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

class CustomWaveform extends StatefulWidget {
  @override
  _CustomWaveformState createState() => _CustomWaveformState();
}

class _CustomWaveformState extends State<CustomWaveform> {
  late AudioPlayer audioPlayer;
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPlaying = false;
  bool isAudioLoaded = false;

  // Fixed number of waveform samples (100 samples)
  List<double> waveform = List.generate(100, (index) => Random().nextDouble());

  double scrollOffset = 0.0; // Store the scroll offset

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    // Play the audio file from the assets using AssetSource
    audioPlayer.play(AssetSource("audio/creepy.mp3")).then((_) {
      setState(() {
        isAudioLoaded = true;
      });
    }).catchError((error) {
      print("Error loading audio: $error");
    });

    // Get audio duration
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        audioDuration = duration;
      });
    });

    // Track audio position
    audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    // Listen to audio player state changes (to detect pause and stop)
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    // Properly dispose of the audio player
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Waveform"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // GestureDetector to handle tap and scrolling
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Adjust scroll offset and direction of audio seeking
              setState(() {
                scrollOffset += details.primaryDelta!;
                _seekAudioBasedOnScroll();
              });
            },
            onTapDown: (details) {
              // Calculate the position where the user tapped
              double tapPosition = details.localPosition.dx;
              _seekAudioBasedOnTap(tapPosition);
            },
            child: Container(
              height: 30,
              width: double.infinity,
              child: RectangleWaveform(
                isCentered: true,
                showActiveWaveform: true,
                isRoundedRectangle: true,
                activeBorderColor: Colors.blue,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey.withOpacity(0.3),
                inactiveBorderColor: Colors.grey.withOpacity(0.3),
                samples: waveform,
                height: 30,
                width: 100 * 3.0, // Width based on 100 samples
                maxDuration: audioDuration,
                elapsedDuration: currentPosition,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Audio Duration display (below the waveform)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(currentPosition),
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  formatDuration(audioDuration),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Play button
          ElevatedButton(
            onPressed: isAudioLoaded
                ? () {
                    if (isPlaying) {
                      audioPlayer.pause();
                    } else {
                      audioPlayer.resume();
                    }
                  }
                : null, // Disable if audio not loaded
            style: ElevatedButton.styleFrom(
              backgroundColor: isPlaying ? Colors.red : Colors.blue, // Toggle color
            ),
            child: Text(isPlaying ? "Pause" : "Play"),
          ),

          if (!isAudioLoaded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Loading audio... Please wait."),
            ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first; // Format as HH:mm:ss
  }

  void _seekAudioBasedOnScroll() {
    if (audioDuration.inMilliseconds > 0) {
      // Map the scroll offset to audio duration
      double progress = (scrollOffset / (100 * 3.0)); // 100 samples, adjust the scale factor
      Duration newPosition = Duration(milliseconds: (progress * audioDuration.inMilliseconds).toInt());

      // Ensure the new position is within bounds
      newPosition = newPosition.inMilliseconds < 0
          ? Duration.zero
          : (newPosition.inMilliseconds > audioDuration.inMilliseconds
              ? audioDuration
              : newPosition);

      // Seek to the new position
      audioPlayer.seek(newPosition);
    }
  }

  void _seekAudioBasedOnTap(double tapPosition) {
    if (audioDuration.inMilliseconds > 0) {
      // Map the tap position to the audio duration
      double progress = tapPosition / (100 * 3.0); // 100 samples, adjust scale if needed
      Duration newPosition = Duration(milliseconds: (progress * audioDuration.inMilliseconds).toInt());

      // Ensure the new position is within bounds
      newPosition = newPosition.inMilliseconds < 0
          ? Duration.zero
          : (newPosition.inMilliseconds > audioDuration.inMilliseconds
              ? audioDuration
              : newPosition);

      // Seek to the new position
      audioPlayer.seek(newPosition);
    }
  }

  // You can adjust the waveform generation based on the audio length
  void _generateDynamicWaveform() {
    if (audioDuration.inMilliseconds > 0) {
      int sampleCount = 100; // Fixed sample count
      setState(() {
        waveform = List.generate(sampleCount, (index) => Random().nextDouble());
      });
    }
  }
}
