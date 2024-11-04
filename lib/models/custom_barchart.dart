import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChart extends StatelessWidget {
  final Map<String, double> periodData;

  const CustomBarChart({
    super.key,
    required this.periodData,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 34, 65, 98)
      : const Color.fromARGB(255, 41, 36, 36),
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 97, 3, 3)
      : const Color.fromARGB(255, 97, 3, 3),
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 89, 100, 117)
      : const Color.fromARGB(255, 100, 100, 100),
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 0, 126, 167)
      : const Color.fromARGB(255, 150, 150, 150),
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 45, 49, 66)
      : const Color.fromARGB(255, 50, 50, 50),
  Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 66, 12, 20)
      : const Color.fromARGB(255, 66, 12, 20),
];

    final maxValue = periodData.values.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            BarChart(
              BarChartData(
                maxY: maxValue * 1.2,
                barGroups: periodData.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final periodEntry = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: periodEntry.value,
                        color: colors[index % colors.length],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < periodData.keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              periodData.keys.elementAt(index),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawHorizontalLine: false,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
            ...periodData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value.value;

              // Calcolo posizioni
              final barWidth = constraints.maxWidth / periodData.length;
              final barCenter = (barWidth * index) + (barWidth / 2);

              // Nuovo calcolo per l'altezza che garantisce che anche il valore massimo sia corretto
              final heightPercentage = value / maxValue;

              final availableHeight = constraints.maxHeight * 0.80;
              final verticalPosition = availableHeight * (1 - heightPercentage) == 0
                  ? availableHeight * (1 - heightPercentage) + 25
                  : availableHeight * (1 - heightPercentage);

              return Positioned(
                left: (barCenter.isNaN ? 0 : barCenter) - 15,
                top: (verticalPosition.isNaN ? 0 : verticalPosition) - 25,// aumentato lo spazio sopra la barra
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}