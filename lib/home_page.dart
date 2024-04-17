import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:havadurumu/search_page.dart';
import 'package:havadurumu/widgets/daily_weather_card.dart';
import 'package:http/http.dart' as http;

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  String location = "Istanbul";
  double? temperature;
  final String key = "a73f596fca724d6933983a3911b74ec5";
  String lat = "";
  String lon = "";

  var locationData;
  String code = 'Clear';
  Position? devicePosition;
  String? icon;

  List<String> icons = [
    "01d",
    "01d",
    "01d",
    "01d",
    "01d",
  ];
  List<double> temperatures = [20.0, 20.0, 20.0, 20.0, 20.0];
  List<String> dates = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"];

  Future<void> getDevicePosition() async {
    Position devicePosition = await _determinePosition();
    lat = devicePosition.latitude.toString();
    lon = devicePosition.longitude.toString();

    print("dsfsdfds $devicePosition");
    print(lat);
    print(lon);
  }

  Future<void> getLocationData() async {
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));

    var jsonData = jsonDecode(response.body);
    setState(() {
      temperature = (jsonData['main']['temp']).toDouble();
      location = jsonData['name'];
      code = jsonData['weather'].first['main'];
      icon = jsonData['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataByLatLon() async {
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=$key&units=metric'));

    var jsonData = jsonDecode(response.body);
    setState(() {
      temperature = (jsonData['main']['temp']).toDouble();
      location = jsonData['name'];
      code = jsonData['weather'].first['main'];
      icon = jsonData['weather'].first['icon'];
    });
  }

  Future<void> getDailyForecastByLatLon() async {
    // print(devicePosition);
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=$key&units=metric'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(response);
      temperatures.clear();
      icons.clear();
      dates.clear();
      setState(() {
        for (int i = 7; i < 40; i += 8) {
          temperatures.add(jsonData['list'][i]['main']['temp']);
          icons.add(jsonData['list'][i]['weather'][0]['icon']);
          dates.add(jsonData['list'][i]['dt_txt']);
        }
      });
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  void asd() async {
    await getDevicePosition(); //cihaz konumu isteme
    await getDailyForecastByLatLon(); //5 günlük veriler
    await getLocationData(); //search pageden gelen şehri ekranda gösterme
    await getLocationDataByLatLon(); //lat long ile konum alma
  }

  void initState() {
    asd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/$code.jpg'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: (temperature == null)
          ? Center(
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5,
                strokeAlign: 10,
              ),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Image.network(
                          'https://openweathermap.org/img/wn/$icon@4x.png'),
                    ),
                    Text(
                      '$temperature  °C',
                      style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$location',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          iconSize: 35,
                          color: Colors.white,
                          onPressed: () async {
                            final selectedCity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                            location = selectedCity;
                            getLocationData();
                            getDailyForecastByLatLon();
                          },
                          icon: Icon(Icons.search_rounded),
                        )
                      ],
                    ),
                    buildWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];

    for (int j = 0; j < 5; j++) {
      cards.add(DailyWeatherCard(
          date: dates[j], icon: icons[j], temperature: temperatures[j]));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
