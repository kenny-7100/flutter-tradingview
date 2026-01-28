import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef JsEventHandler = void Function(String event, Map<String, dynamic> data);

class WebViewXController {
  InAppWebViewController? _webViewController;

  bool get isReady => _webViewController != null;

  Future<dynamic> callJs(String method, [Map<String, dynamic>? args]) async {
    if (_webViewController == null) return null;
    final argsJson = args != null ? _encodeArgs(args) : '{}';
    return await _webViewController!.evaluateJavascript(
      source: 'window.flutterBridge?.onDartCall?.("$method", $argsJson)',
    );
  }

  Future<dynamic> evaluateJavascript(String source) async {
    if (_webViewController == null) return null;
    return await _webViewController!.evaluateJavascript(source: source);
  }

  String _encodeArgs(Map<String, dynamic> args) {
    return args.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : e.value;
      return '"${e.key}": $value';
    }).join(', ').let((s) => '{$s}');
  }
}

extension _StringExt on String {
  T let<T>(T Function(String) block) => block(this);
}

class WebViewX extends StatefulWidget {
  const WebViewX({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
    this.controller,
    this.onEvent,
    this.onReady,
  });

  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final WebViewXController? controller;
  final JsEventHandler? onEvent;
  final VoidCallback? onReady;

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

  void _onWebViewCreated(InAppWebViewController controller) {
    widget.controller?._webViewController = controller;

    controller.addJavaScriptHandler(
      handlerName: 'flutterEvent',
      callback: (args) {
        if (args.length >= 2 && widget.onEvent != null) {
          final event = args[0] as String;
          final data = Map<String, dynamic>.from(args[1] as Map);
          widget.onEvent!(event, data);
        }
        return null;
      },
    );
  }

  Future<void> _onLoadStop(InAppWebViewController controller, WebUri? url) async {
    await controller.evaluateJavascript(source: '''
      window.flutterBridge = {
        emit: function(event, data) {
          window.flutter_inappwebview.callHandler('flutterEvent', event, data || {});
        },
        onDartCall: null
      };
      console.log('[FlutterBridge] initialized');
    ''');
    widget.onReady?.call();
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
        onWebViewCreated: _onWebViewCreated,
        onLoadStop: _onLoadStop,
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
