import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NowPlayingHeader extends StatelessWidget {
  final dynamic currentSong;

  const NowPlayingHeader({required this.currentSong});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade900, Colors.black],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.6),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: Colors.deepPurple,
                    child: Icon(Icons.music_note, size: 100, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 30,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: Size(200, 100),
                  painter: CurvedTrackPainter(),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            currentSong.title,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            currentSong.artist,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CurvedTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width / 2, size.height * 0.8, size.width / 2 - 70, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
