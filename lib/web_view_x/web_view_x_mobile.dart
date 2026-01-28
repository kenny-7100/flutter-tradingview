import 'dart:io';
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
  late InAppWebViewSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = InAppWebViewSettings(
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      // Android: 使用 WebViewAssetLoader 以 http 形式加载本地资源
      webViewAssetLoader: Platform.isAndroid && widget.assetPath != null
          ? WebViewAssetLoader(
              pathHandlers: [
                AssetsPathHandler(path: '/assets/'),
              ],
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    // 如果指定了远程 URL，直接加载
    if (widget.url != null) {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url!)),
        initialSettings: _settings,
      );
    }

    // 如果指定了本地资源路径
    if (widget.assetPath != null) {
      if (Platform.isAndroid) {
        // Android: 使用 WebViewAssetLoader，通过 http URL 加载
        final assetUrl =
            'https://appassets.androidplatform.net/assets/flutter_assets/${widget.assetPath}';
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(assetUrl)),
          initialSettings: _settings,
        );
      } else {
        // iOS: 直接使用 initialFile 加载本地文件
        return InAppWebView(
          initialFile: widget.assetPath,
          initialSettings: _settings,
        );
      }
    }

    // 默认显示空白页
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: '<html><body></body></html>'),
      initialSettings: _settings,
    );
  }
}
