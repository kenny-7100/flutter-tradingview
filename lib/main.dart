import 'package:flutter/material.dart';
import 'package:flutter_tradingview/web_view_x/web_view_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradingView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = WebViewXController();
  bool _isReady = false;

  void _onEvent(String event, Map<String, dynamic> data) {
    debugPrint('[Dart] Received event: $event, data: $data');
  }

  void _onReady() {
    setState(() => _isReady = true);
    debugPrint('[Dart] WebView ready');
  }

  void _changeSymbol(String symbol) {
    _controller.evaluateJavascript('''
      if (window.tvWidget) {
        window.tvWidget.setSymbol('$symbol', '1D');
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TradingView Demo'),
      ),
      body: Column(
        children: [
          if (_isReady)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _changeSymbol('AAPL'),
                    child: const Text('AAPL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _changeSymbol('GOOGL'),
                    child: const Text('GOOGL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _changeSymbol('MSFT'),
                    child: const Text('MSFT'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: WebViewX(
              assetPath: 'assets/website/index.html',
              controller: _controller,
              onEvent: _onEvent,
              onReady: _onReady,
            ),
          ),
        ],
      ),
    );
  }
}
