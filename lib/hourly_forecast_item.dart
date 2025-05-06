import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String tempreture;
  const HourlyForecastItem({
    super.key,
    required this.tempreture,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(time,
              style:const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ) ,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 8,),
             Icon(icon,
              size: 38,
            ),
            SizedBox(height: 6,),
            Text(tempreture,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
