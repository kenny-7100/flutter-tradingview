import 'package:flutter/material.dart';
import 'package:web/web.dart';
import 'dart:ui_web' as ui_web;

class WebViewX extends StatefulWidget {
  const WebViewX({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
  });

  /// 远程 URL (如 http://192.168.0.114:3000)
  final String? url;

  /// 本地资源路径 (如 assets/website/index.html)
  final String? assetPath;

  final double? width;
  final double? height;

  @override
  State<WebViewX> createState() => _WebViewXState();
}

class _WebViewXState extends State<WebViewX> {
  final String _viewType = 'webview-${UniqueKey()}';

  String get _effectiveUrl {
    if (widget.url != null) {
      return widget.url!;
    }
    if (widget.assetPath != null) {
      // Web 平台直接使用相对路径访问 assets
      return widget.assetPath!;
    }
    return 'about:blank';
  }

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return HTMLIFrameElement()
        ..src = _effectiveUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
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
