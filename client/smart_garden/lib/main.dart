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
    Uri.parse('ws://18.118.210.197'),
  );
  double temp = 22.0;
  double humidity = 30.0;
  double soilMoisture = 60.0;
  double lightIntensity = 15.0;

  double targetTemp = 25;
  double targetHumidity = 50;
  double targetSoilMoisture = 70.0;
  double targetLightIntensity = 30;

  bool ledState = true;
  bool windowState = false;
  bool showerState = false;

  String plant_type = "snake";

  Map<String, Map<String, double>> optimal_plant_conditions = {
    'snake': {
      'temp': 23.5,
      'humidity': 45,
      'soilMoisture': 50,
      'lightIntensity': 80,
    },
    'english_ivy': {
      'temp': 19,
      'humidity': 60,
      'soilMoisture': 60,
      'lightIntensity': 62,
    },
    'dracaena': {
      'temp': 20,
      'humidity': 50,
      'soilMoisture': 55,
      'lightIntensity': 65,
    },
    'cactus': {
      'temp': 23.5,
      'humidity': 20,
      'soilMoisture': 20,
      'lightIntensity': 88,
    },
    'aloe_vera': {
      'temp': 25,
      'humidity': 40,
      'soilMoisture': 40,
      'lightIntensity': 75,
    },
  };

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

      var timer = Timer(const Duration(seconds: 3), () {
        setState(() {
          showerState = false;
        });
      });
    }
  }

  void sendTargetConditions() {
    channel.sink.add(
        '{"action": "update_target_conditions", "target_temp": ${targetTemp}, "target_humidity": ${targetHumidity}, "target_soil_moisture": ${targetSoilMoisture}, "target_light_intensity": ${targetLightIntensity}}');
  }

  void updateTargetConditions() {
    setState(() {
      targetTemp = optimal_plant_conditions[plant_type]!['temp']!;
      targetHumidity = optimal_plant_conditions[plant_type]!['humidity']!;
      targetLightIntensity =
          optimal_plant_conditions[plant_type]!['lightIntensity']!;
      targetSoilMoisture =
          optimal_plant_conditions[plant_type]!['soilMoisture']!;
    });
    sendTargetConditions();
  }

  @override
  void initState() {
    updateTargetConditions();

    channel.stream.listen(
      (data) {
        Map<String, dynamic> json_data = jsonDecode(data);
        if (json_data['action'] == 'env_conditions') {
          // print('Humidity = ${json_data["humidity"]}');
          // print('Temp = ${json_data["temp"]}');
          // print('Soil Moisture = ${json_data["soil_moisture"]}');
          // print('Light Intensity = ${json_data["light_intensity"]}');

          setState(() {
            humidity = json_data["humidity"].toDouble();
            temp = json_data["temp"].toDouble();
            soilMoisture = json_data["soil_moisture"].toDouble();
            lightIntensity = json_data["light_intensity"].toDouble();

            ledState = json_data["led_state"] == 1 ? true : false;
            windowState = json_data["window_state"] == 1 ? true : false;
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
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0.0,
                                  shadowColor: Colors.transparent),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                        title: const Text("Select Your Plant:"),
                                        children: [
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 20),
                                            onPressed: () {
                                              setState(() {
                                                plant_type = "english_ivy";
                                              });
                                              updateTargetConditions();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("English Ivy",
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 20),
                                            onPressed: () {
                                              setState(() {
                                                plant_type = "dracaena";
                                              });
                                              updateTargetConditions();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Dracaena",
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 20),
                                            onPressed: () {
                                              setState(() {
                                                plant_type = "cactus";
                                              });
                                              updateTargetConditions();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cactus",
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 20),
                                            onPressed: () {
                                              setState(() {
                                                plant_type = "snake";
                                              });
                                              updateTargetConditions();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Snake Plant",
                                                style: TextStyle(fontSize: 16)),
                                          ),
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 20),
                                            onPressed: () {
                                              setState(() {
                                                plant_type = "aloe_vera";
                                              });
                                              updateTargetConditions();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Aloe Vera Plant",
                                                style: TextStyle(fontSize: 16)),
                                          )
                                        ]);
                                  }),
                              child: Image.asset(
                                "assets/" + plant_type + ".png",
                                fit: BoxFit.contain,
                              ))),
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
                          target: '${targetHumidity.toStringAsFixed(0)}%',
                          icon: Icons.water_drop_outlined,
                          backgroundColor: Color.fromRGBO(241, 244, 255, 1),
                          onNumberEntered: (double target) {
                            setState(() {
                              targetHumidity = target;
                            });
                            sendTargetConditions();
                          },
                        ),
                        SensorButton(
                          title: 'Temperature',
                          subtitle: '${temp.toStringAsFixed(1)}°C',
                          target: '${targetTemp.toStringAsFixed(1)}',
                          icon: Icons.thermostat_outlined,
                          backgroundColor: Color.fromRGBO(253, 234, 236, 1),
                          onNumberEntered: (double target) {
                            setState(() {
                              targetTemp = target;
                            });
                            sendTargetConditions();
                          },
                        ),
                        SensorButton(
                          title: 'Soil Moisture',
                          subtitle: '${soilMoisture.toStringAsFixed(0)}%',
                          target: '${targetSoilMoisture.toStringAsFixed(0)}%',
                          icon: Icons.grass,
                          backgroundColor: Color.fromRGBO(225, 255, 250, 1),
                          onNumberEntered: (double target) {
                            setState(() {
                              targetSoilMoisture = target;
                            });
                            sendTargetConditions();
                          },
                        ),
                        SensorButton(
                          title: 'Light',
                          subtitle: '${lightIntensity.toStringAsFixed(0)}%',
                          target: '${targetLightIntensity.toStringAsFixed(0)}%',
                          icon: Icons.wb_sunny_outlined,
                          backgroundColor: Color.fromRGBO(251, 242, 231, 1),
                          onNumberEntered: (double target) {
                            setState(() {
                              targetLightIntensity = target;
                            });
                            sendTargetConditions();
                          },
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
