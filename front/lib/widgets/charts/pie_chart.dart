import 'package:flutter/material.dart';

class PieSlice {
  final String label;
  final double value;
  final Color color;
  PieSlice(this.label, this.value, this.color);
}

class SimplePieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;

  const SimplePieChart({super.key, required this.slices, this.size = 160});

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (p, e) => p + e.value);
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PiePainter(slices: slices, total: total),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: slices
              .map((s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${s.label} (${total == 0 ? 0 : ((s.value / total) * 100).round()}%)', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ))
              .toList(),
        )
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<PieSlice> slices;
  final double total;
  _PiePainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double piVal = 3.141592653589793;
    double startRads = -piVal / 2;
    for (final s in slices) {
      final double sweep = total == 0 ? 0 : (s.value / total) * piVal * 2.0;
      final paint = Paint()..color = s.color..style = PaintingStyle.fill;
      canvas.drawArc(rect, startRads, sweep, true, paint);
      startRads += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}