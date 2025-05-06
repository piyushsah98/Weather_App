import 'dart:convert';
import 'dart:ui';
import 'package:weather_app/secrects.dart';
import './hourly_forecast_item.dart';
import 'package:flutter/material.dart';
import './additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {

  final VoidCallback onToggleTheme;
  const WeatherScreen({
    super.key,
    required this.onToggleTheme
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
    late Future<Map<String , dynamic >>weatherFuture;

    Future<Position> _getCurrentLocation() async{
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await
          Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled){
        throw 'Location services are disabled';
      }

      // Check and request permission
      permission =
          await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied){
          throw'Location permission are denied';
        }
      }

      if(permission == LocationPermission.deniedForever){
        throw Exception(
          'Location permissions are permanently denied , we cannot request permission .');
      }

      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings
      );
    }


    Future<Map<String, dynamic>> getCurrentWeather() async {
    try{
       final position = await _getCurrentLocation();
       final lat = position.latitude;
       final lon = position.longitude;


      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$openWeatherApiKey'),
      );
      final data = jsonDecode(res.body);

      if(data['cod'] != '200') {
        throw 'Failed to load weather data';
}
        return data;
    } catch(e){
      throw e.toString();
    }
}

  @override
  void initState() {
    super.initState();
    weatherFuture = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed:widget.onToggleTheme,
              icon: const Icon(Icons.brightness_6),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                });
              },
              icon: const Icon(
                  Icons.refresh
              )
          ),
        ],
      ),
      body: FutureBuilder(
        future: weatherFuture,
        builder: (context , snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child:  CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemp = (currentWeatherData['main']['temp']).toStringAsFixed(2);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = data['list'][0]['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child:  Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:  Column(
                          children: [
                            Text(
                              '$currentTemp°C',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                             Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64
                            ),
                            const SizedBox(height: 16),
                             Text(currentSky, style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Hourly forecast card
              const SizedBox(height: 20),
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                    itemBuilder:(context , index){
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                      final hourlyTemp = (hourlyForecast['main']['temp']).toStringAsFixed(2);
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecastItem(
                          time: DateFormat.j().format(time),
                          tempreture: hourlyTemp,
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ?  Icons.cloud
                              : Icons.sunny,
                      );
                    },
                ),
              ),

              /// additional information
              const SizedBox(height: 30),
              const Text(
                'Additional Information',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: currentWindSpeed.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}


