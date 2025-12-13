import 'package:flutter/material.dart';
import 'package:web/web.dart';
import 'dart:ui_web' as ui_web;

class WebViewX extends StatefulWidget {
  const WebViewX({super.key, required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  State<WebViewX> createState() => _WebViewXState();
}

class _WebViewXState extends State<WebViewX> {
  late final String _viewType;
  bool _viewRegistered = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'webview-${DateTime.now().millisecondsSinceEpoch}';
    if (!_viewRegistered) {
      final url = widget.url.startsWith('web://')
          ? '/${widget.url.replaceFirst('web://', '')}'
          : widget.url;
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = HTMLIFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
      _viewRegistered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
