import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'package:smart_garden/sensor_button.dart';
import 'package:smart_garden/header.dart';

void main() => runApp(MyApp());

const primColor = Colors.blue;

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
  double temp = 22.0;
  double humidity = 30.0;
  double soilMoisture = 60.0;
  double lightIntensity = 15.0;

  bool ledState = true;
  bool windowState = false;
  bool showerState = false;

  void toggleLED() {
    setState(() {
      ledState = !ledState;
    });
    channel.sink.add('{"action": "led_toggle", "state": ${ledState ? 1 : 0}}');
  }

  void toggleWindow() {
    setState(() {
      windowState = !windowState;
    });
    channel.sink
        .add('{"action": "window_toggle", "state": ${windowState ? 1 : 0}}');
  }

  void toggleShower() {
    if (!showerState) {
      setState(() {
        showerState = true;
      });
      channel.sink.add('{"action": "shower"}');

      var timer = Timer(const Duration(seconds: 4), () {
        setState(() {
          showerState = false;
        });
      });
    }
  }

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
            humidity = json_data["humidity"].toDouble();
            temp = json_data["temp"].toDouble();
            soilMoisture = json_data["soil_moisture"].toDouble();
            lightIntensity = json_data["light_intensity"].toDouble();
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
          margin: EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              SmartGardenHeader(
                ledState: ledState,
                toggleLED: toggleLED,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Set the alignment of the children
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          toggleWindow();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0.0,
                            shadowColor: Colors.transparent),
                        child: Icon(
                          Icons.air_outlined,
                          color: windowState ? Colors.blue : Colors.black,
                          weight: 100,
                          size: 64,
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height / 2.2,
                      // width: MediaQuery.of(context).size.width,
                      child: Transform.translate(
                          offset: const Offset(
                              0, -30.0), // set a negative margin on the top
                          child: Image.asset(
                            'assets/plant.png',
                            fit: BoxFit.contain,
                          )),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          toggleShower();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0.0,
                            shadowColor: Colors.transparent),
                        child: Icon(
                          Icons.shower_outlined,
                          color: showerState ? Colors.blue : Colors.black,
                          weight: 100,
                          size: 70,
                        )),
                  ]),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Transform.translate(
                    offset: const Offset(0, -30.0),
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
                          subtitle: '${humidity.toStringAsFixed(0)}%',
                          icon: Icons.water_drop_outlined,
                          backgroundColor: Color.fromRGBO(241, 244, 255, 1),
                        ),
                        SensorButton(
                          title: 'Temperature',
                          subtitle: '${temp.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat_outlined,
                          backgroundColor: Color.fromRGBO(253, 234, 236, 1),
                        ),
                        SensorButton(
                          title: 'Soil Moisture',
                          subtitle: '${soilMoisture.toStringAsFixed(0)}%',
                          icon: Icons.grass,
                          backgroundColor: Color.fromRGBO(225, 255, 250, 1),
                        ),
                        SensorButton(
                          title: 'Light',
                          subtitle: '${lightIntensity.toStringAsFixed(0)}%',
                          icon: Icons.wb_sunny_outlined,
                          backgroundColor: Color.fromRGBO(251, 242, 231, 1),
                        ),
                      ],
                    )),
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
