import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard(
      {super.key,
      required this.date,
      required this.icon,
      required this.temperature});

  final String icon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 150,
        width: 100,
        child: Column(
          children: [
            Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
            Text(
              '$temperature  °C',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text("$date"),
          ],
        ),
      ),
    );
  }
}
