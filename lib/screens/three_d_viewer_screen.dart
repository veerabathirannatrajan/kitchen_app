import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDViewerScreen extends StatefulWidget {
  final String title;

  const ThreeDViewerScreen({
    super.key,
    required this.title,
  });

  @override
  State<ThreeDViewerScreen> createState() => _ThreeDViewerScreenState();
}

class _ThreeDViewerScreenState extends State<ThreeDViewerScreen> {
  late final WebViewController _controller;

  // YOUR GITHUB RAW URL
  static const String _modelUrl = 'https://raw.githubusercontent.com/veerabathirannatrajan/fra_final/main/grill.glb';

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
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
                overflow: hidden;
            }
            #loading {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                color: white;
                font-family: Arial, sans-serif;
                text-align: center;
                z-index: 10;
            }
            .spinner {
                width: 50px;
                height: 50px;
                border: 4px solid rgba(255,107,53,0.2);
                border-top-color: #FF6B35;
                border-radius: 50%;
                animation: spin 1s linear infinite;
                margin: 0 auto 20px;
            }
            @keyframes spin {
                to { transform: rotate(360deg); }
            }
            .loading-text {
                color: #FF6B35;
                font-size: 16px;
                font-weight: 600;
                margin-bottom: 8px;
            }
            .loading-subtext {
                color: #888;
                font-size: 12px;
            }
            model-viewer {
                width: 100vw;
                height: 100vh;
                background: transparent;
            }
            .progress-bar {
                width: 200px;
                height: 4px;
                background: rgba(255,255,255,0.1);
                border-radius: 2px;
                margin-top: 16px;
                overflow: hidden;
            }
            .progress-fill {
                height: 100%;
                background: #FF6B35;
                width: 0%;
                transition: width 0.3s;
                border-radius: 2px;
            }
        </style>
        <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.0.0/model-viewer.min.js"></script>
    </head>
    <body>
        <div id="loading">
            <div class="spinner"></div>
            <div class="loading-text">Loading ${widget.title}</div>
            <div class="loading-subtext" id="progress-text">0%</div>
            <div class="progress-bar">
                <div class="progress-fill" id="progress-fill"></div>
            </div>
        </div>
        
        <model-viewer 
            id="viewer"
            src="$_modelUrl"
            alt="${widget.title}"
            auto-rotate
            camera-controls
            camera-orbit="0deg 75deg 3m"
            exposure="1.2"
            shadow-intensity="1"
            environment-image="neutral"
            ar
            ar-modes="webxr scene-viewer quick-look"
            loading="eager">
        </model-viewer>
        
        <script>
            const viewer = document.getElementById('viewer');
            const loading = document.getElementById('loading');
            const progressText = document.getElementById('progress-text');
            const progressFill = document.getElementById('progress-fill');
            
            viewer.addEventListener('progress', (e) => {
                const progress = e.detail.totalProgress;
                const percent = Math.round(progress * 100);
                progressText.textContent = percent + '%';
                progressFill.style.width = percent + '%';
            });
            
            viewer.addEventListener('load', () => {
                loading.style.display = 'none';
            });
            
            viewer.addEventListener('error', (e) => {
                loading.innerHTML = '<div style="color: #ff6b6b; font-size: 48px;">⚠️</div><div style="color: white; margin-top: 16px;">Failed to load model</div><div style="color: #888; font-size: 12px; margin-top: 8px;">Check your internet connection</div>';
            });
        </script>
    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}