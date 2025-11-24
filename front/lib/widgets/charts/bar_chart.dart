import 'package:flutter/material.dart';

class BarData {
  final String label;
  final double value;
  BarData(this.label, this.value);
}

class SimpleBarChart extends StatelessWidget {
  final List<BarData> data;
  final double height;
  final Color barColor;
  final Color axisColor;

  const SimpleBarChart({super.key, required this.data, this.height = 180, this.barColor = const Color(0xFFFF312E), this.axisColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    final maxV = data.isEmpty ? 0.0 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height + 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data
                    .map(
                      (e) => Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: maxV == 0 ? 0 : (e.value / maxV) * height,
                              decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6)),
                            ),
                            const SizedBox(height: 6),
                            Text(e.label, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: axisColor.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}