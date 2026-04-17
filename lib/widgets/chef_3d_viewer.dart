// lib/widgets/chef_3d_viewer.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui';

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
  late WebViewController _controller;
  bool _isLoading = true;

  // Your GitHub raw URL for the chef model
  static const String _modelUrl =
      'https://raw.githubusercontent.com/veerabathirannatrajan/kitchen_app/master/assets/threeD/chef.glb';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final String html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                background: transparent !important;
                overflow: hidden;
            }
            model-viewer {
                width: 100%;
                height: 100vh;
                background: transparent;
                --poster-color: transparent;
            }
            #loading {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 10;
                display: none;
            }
        </style>
        <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.0.0/model-viewer.min.js"></script>
    </head>
    <body>
        <model-viewer 
            id="viewer"
            src="$_modelUrl"
            alt="Chef 3D Model"
            auto-rotate
            camera-controls
            camera-orbit="0deg 75deg 2.5m"
            exposure="1.5"
            shadow-intensity="0.8"
            environment-image="neutral"
            loading="eager"
            style="background: transparent;">
        </model-viewer>
        
        <script>
            const viewer = document.getElementById('viewer');
            viewer.addEventListener('load', () => {
                // Model loaded successfully
            });
            viewer.addEventListener('error', (e) => {
                console.log('Model load error, retrying...');
                setTimeout(() => {
                    viewer.src = viewer.src;
                }, 2000);
            });
        </script>
    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            // Silent error - retry in background
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.transparent,
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}