import 'package:flutter/material.dart';

class SmartGardenHeader extends StatefulWidget {
  SmartGardenHeader();

  @override
  _SmartGardenHeader createState() => _SmartGardenHeader();
}

class _SmartGardenHeader extends State<SmartGardenHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 10.0,
            width: MediaQuery.of(context).size.width * 0.4,
            color: Colors.black,
          ),
        ),
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80.0),
          painter: TrapezoidPainter(),
        ),
      ],
    ));
  }
}

class TrapezoidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.3, 0.0);
    path.lineTo(size.width * 0.7, 0.0);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.close();

    final Gradient gradient = LinearGradient(
      colors: [Color.fromRGBO(255, 151, 255, 1), Colors.white.withOpacity(0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final Paint paint = Paint()
      ..shader = gradient.createShader(path.getBounds());
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
