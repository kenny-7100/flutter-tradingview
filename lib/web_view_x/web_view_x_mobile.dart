import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewX extends StatefulWidget {
  const WebViewX({super.key, required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  State<WebViewX> createState() => _WebViewXState();
}

class _WebViewXState extends State<WebViewX> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadContent();
  }

  Future<void> _loadContent() async {
    final url = widget.url;
    if (url.startsWith('web://')) {
      final assetPath = url.replaceFirst('web://', 'web/');
      final htmlContent = await rootBundle.loadString(assetPath);
      await _controller.loadHtmlString(htmlContent);
    } else {
      await _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}
