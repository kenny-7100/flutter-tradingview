# TradingView Charting Library Flutter 集成调研报告

## 一、调研目标

### 1. React 项目接入 TV Charting Library

使用 `react-typescript/` 目录，基于 TradingView 官方 React 示例改造。

关键配置:
- `package.json` 设置 `"homepage": "."` 生成相对路径
- 构建脚本自动复制产物到 `assets/website/`
- `window.tvWidget` 暴露图表实例供 Dart 控制
- `window.flutterBridge.emit()` 向 Dart 发送事件

### 2. Bundle 产物与 gitignore

产物目录 `assets/website/` 已添加到 `.gitignore`。

构建命令:
```bash
cd react-typescript && pnpm run build
```

自动执行: `rm -rf ../assets/website && cp -r build ../assets/website`

### 3. WebView 载入与 JS 双向通信

资源加载: 使用 `InAppLocalhostServer` 启动本地 HTTP 服务器，通过 `http://localhost:8080/index.html` 加载，解决 `file://` 协议下 Blob URL 无法工作的问题。

双向通信:

| 方向 | 方法 |
|------|------|
| Dart -> JS | `controller.evaluateJavascript("window.tvWidget.setSymbol('AAPL', '1D')")` |
| JS -> Dart | `window.flutterBridge.emit('symbolChange', {symbol: 'AAPL'})` |

Dart 端 API:
```dart
WebViewX(
  assetPath: 'assets/website/index.html',
  controller: _controller,
  onEvent: (event, data) { /* 处理 JS 事件 */ },
  onReady: () { /* WebView 就绪 */ },
)
```

### 4. webview_flutter vs flutter_inappwebview

| 特性 | webview_flutter | flutter_inappwebview |
|------|-----------------|---------------------|
| 本地文件加载 | 需额外配置 | 内置 InAppLocalhostServer |
| JS 通信 | JavaScriptChannel | addJavaScriptHandler |
| 调试支持 | 有限 | Safari/Chrome DevTools |
| Blob URL | 需 HTTP 服务器 | 内置方案 |
| 控制台日志 | 不支持 | onConsoleMessage |
| 维护方 | Flutter 官方 | 社区，更新活跃 |

结论: `flutter_inappwebview` 更适合 TradingView 这类复杂 Web 应用。

## 二、现存问题

### 1. Web 端暂未完成

Flutter Web 开发服务器对嵌套目录静态资源返回错误 MIME 类型，导致 JS/CSS 无法加载。可能需要修改react项目的publicPath来做，待明确
