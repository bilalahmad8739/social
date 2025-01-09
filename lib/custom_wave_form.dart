import 'package:flutter/material.dart';
import 'dart:math';

class CustomWaveform extends StatelessWidget {
  final List<double> samples;
  final double height;
  final double width;
  final Color color;
  final double spacing;

  CustomWaveform({
    required this.samples,
    required this.height,
    required this.width,
    required this.color,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CustomPaint(
        painter: WaveformPainter(samples, color, spacing),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color color;
  final double spacing;

  WaveformPainter(this.samples, this.color, this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = spacing;

    final middle = size.height / 2;
    final sampleCount = samples.length;
    final sampleWidth = size.width / sampleCount;

    for (int i = 0; i < sampleCount; i++) {
      final sample = samples[i];
      final x = sampleWidth * i;
      final y = middle - (sample * middle);
      canvas.drawLine(
        Offset(x, middle),
        Offset(x, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


