import 'package:flutter/material.dart';

class SensorButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;

  SensorButton(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
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
        Text(
          subtitle,
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18.0, color: Colors.black),
        ),
      ]),
    );
  }
}
