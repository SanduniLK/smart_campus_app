import 'package:flutter/material.dart';
import 'package:smart_campus_app/presentation/screens/splash/widgets/mesh_painter.dart';


class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MeshPainter(),
    );
  }
}