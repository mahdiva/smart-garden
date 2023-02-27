import 'package:flutter/material.dart';

class SmartGardenHeader extends StatefulWidget {
  bool ledState;
  Function toggleLED;
  SmartGardenHeader({required this.ledState, required this.toggleLED});

  @override
  _SmartGardenHeader createState() => _SmartGardenHeader();
}

class _SmartGardenHeader extends State<SmartGardenHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        ElevatedButton(
            onPressed: () {
              widget.toggleLED();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0.0,
                shadowColor: Colors.transparent),
            child: Icon(
              widget.ledState ? Icons.tungsten : Icons.tungsten_outlined,
              color: widget.ledState
                  ? Color.fromRGBO(255, 100, 255, 1)
                  : Colors.black,
              weight: 100,
              size: 70,
            )),
        Visibility(
          visible: widget.ledState,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80.0),
            painter: TrapezoidPainter(),
          ),
        )
      ],
    ));
  }
}

class TrapezoidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.45, 0.0);
    path.lineTo(size.width * 0.55, 0.0);
    path.lineTo(size.width * 0.9, size.height * 1.5);
    path.lineTo(size.width * 0.1, size.height * 1.5);
    path.close();

    final Gradient gradient = LinearGradient(
      colors: [Color.fromRGBO(255, 100, 255, 0.5), Colors.white.withOpacity(0)],
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
