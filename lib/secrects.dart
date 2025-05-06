const openWeatherApiKey = 'f403d34669e728c25851dc394126ed43';

// This is a line of code to fit n number of cards in a single row
// but the disadvantage is that if we have 30 cards it shows 30 cards . Thats why we use
// listview Builder <-----
//            |||
//             ↓
// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     children: [
//       for(int i = 0 ; i < 5 ; i++)
//         HourlyForecastItem(
//           time: data['list'][i + 1]['dt'].toString(),
//           icon: data['list'][i + 1]['weather'][0]['main'] == 'Clouds'
//               || data['list'][i + 1]['weather'][0]['main'] == 'Rain'
//               ? Icons.cloud : Icons.sunny,
//           tempreture: data['list'][i + 1]['main']['temp'].toString() ,
//         ),
//     ],
//   ),
// ),