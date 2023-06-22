import 'package:flutter/material.dart';

class DiamondDivider extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DiamondDivider({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DiamondDividerPainter(color: color),
      ),
    );
  }
}

class _DiamondDividerPainter extends CustomPainter {
  final Color color;

  _DiamondDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.square;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 4, 0);
    path.lineTo(size.width * 3 / 4, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 3 / 4, size.height);
    path.lineTo(size.width / 4, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
