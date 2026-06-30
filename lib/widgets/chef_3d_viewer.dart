import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Chef3DViewer extends StatefulWidget {
  final double size;
  final bool autoRotate;

  const Chef3DViewer({
    super.key,
    this.size = 290,
    this.autoRotate = true,
  });

  @override
  State<Chef3DViewer> createState() => _Chef3DViewerState();
}

class _Chef3DViewerState extends State<Chef3DViewer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ModelViewer(
        src: 'assets/threeD/chef.glb',
        alt: "Chef 3D Model",
        autoPlay: true,
        autoRotate: false,           // ← CHANGE: false = user controls rotation
        cameraControls: true,        // ← CHANGE: true = user can rotate with touch
        disableZoom: true,
        disableTap: true,
        backgroundColor: Colors.transparent,
        ar: false,
        arModes: [],
        iosSrc: '',
        exposure: 1.5,
        shadowIntensity: 0.8,
        environmentImage: '',
      ),
    );
  }
}