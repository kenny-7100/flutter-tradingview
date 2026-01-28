import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewX extends StatefulWidget {
  const WebViewX({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
  });

  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;

  @override
  State<WebViewX> createState() => _WebViewXState();
}

class _WebViewXState extends State<WebViewX> {
  InAppLocalhostServer? _localhostServer;
  String? _serverUrl;
  bool _isReady = false;

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    isInspectable: kDebugMode,
  );

  @override
  void initState() {
    super.initState();
    if (widget.assetPath != null) {
      _startLocalServer();
    } else {
      _isReady = true;
    }
  }

  Future<void> _startLocalServer() async {
    _localhostServer = InAppLocalhostServer(documentRoot: 'assets/website');
    await _localhostServer!.start();
    setState(() {
      _serverUrl = 'http://localhost:8080/index.html';
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _localhostServer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadUrl = widget.url ?? _serverUrl;
    if (loadUrl == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(loadUrl)),
        initialSettings: _settings,
        onConsoleMessage: (controller, msg) {
          final level = msg.messageLevel.toString().split('.').last;
          debugPrint('[WebView][$level] ${msg.message}');
        },
        onReceivedError: (controller, request, error) {
          debugPrint('[WebView Error] ${request.url}: ${error.description}');
        },
      ),
    );
  }
}
