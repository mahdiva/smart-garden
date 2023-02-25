import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'package:smart_garden/sensor_button.dart';
import 'package:smart_garden/header.dart';

void main() => runApp(MyApp());

final primColor = Colors.blue;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: primColor, primarySwatch: primColor),
      home: SmartGardenHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SmartGardenHome extends StatefulWidget {
  @override
  SmartGardenHomeState createState() => SmartGardenHomeState();
}

class SmartGardenHomeState extends State<SmartGardenHome> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.21:3000'),
  );
  var temp = "22";
  var humidity = "30";
  var soilMoisture = "60";
  var lightIntensity = "15";

  @override
  void initState() {
    channel.stream.listen(
      (data) {
        Map<String, dynamic> json_data = jsonDecode(data);
        if (json_data['action'] == 'env_conditions') {
          print('Humidity = ${json_data["humidity"]}');
          print('Temp = ${json_data["temp"]}');
          print('Soil Moisture = ${json_data["soil_moisture"]}');
          print('Light Intensity = ${json_data["light_intensity"]}');

          setState(() {
            humidity = json_data["humidity"];
            temp = json_data["temp"];
            soilMoisture = json_data["soil_moisture"];
            lightIntensity = json_data["light_intensity"];
          });
        }
      },
      onError: (error) => print(error),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              SmartGardenHeader(),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Transform.translate(
                    offset: Offset(0, 0), // set a negative margin on the top
                    child: Image.asset(
                      'assets/plant.png',
                      fit: BoxFit.contain,
                    )),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: GridView.count(
                  padding: EdgeInsets.only(top: 20),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  crossAxisCount: 2,
                  childAspectRatio: 2.0,
                  shrinkWrap: true,
                  children: [
                    SensorButton(
                      title: 'Humidity',
                      subtitle: '${humidity}%',
                      icon: Icons.water_drop_outlined,
                      backgroundColor: Color.fromRGBO(241, 244, 255, 1),
                    ),
                    SensorButton(
                      title: 'Temperature',
                      subtitle: '${temp}°C',
                      icon: Icons.thermostat_outlined,
                      backgroundColor: Color.fromRGBO(253, 234, 236, 1),
                    ),
                    SensorButton(
                      title: 'Soil Moisture',
                      subtitle: '${soilMoisture}%',
                      icon: Icons.grass,
                      backgroundColor: Color.fromRGBO(225, 255, 250, 1),
                    ),
                    SensorButton(
                      title: 'Light',
                      subtitle: '${lightIntensity}%',
                      icon: Icons.wb_sunny_outlined,
                      backgroundColor: Color.fromRGBO(251, 242, 231, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
