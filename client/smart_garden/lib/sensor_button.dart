import 'package:flutter/material.dart';
import 'package:smart_garden/input_dialog.dart';

class SensorButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String target;
  final IconData icon;
  final Color backgroundColor;
  final dynamic onNumberEntered;

  SensorButton(
      {required this.title,
      required this.subtitle,
      required this.target,
      required this.icon,
      required this.backgroundColor,
      required this.onNumberEntered});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => NumberInputDialog(
          onNumberEntered: onNumberEntered,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.17),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(-1, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  subtitle,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18.0,
                      color: Colors.black),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  target,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
