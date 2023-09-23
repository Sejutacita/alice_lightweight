import 'package:alice_lightweight/alice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Alice _alice;

  @override
  void initState() {
    _alice = Alice(
      darkTheme: false,
    );

    super.initState();
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Demo Alice HTTP Inspector'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    getWeather();
                  },
                  child: const Text('Hit API')),
              ElevatedButton(
                  onPressed: () {
                    _runHttpInspector();
                  },
                  child: const Text('Open HTTP Inspector')),
            ],
          ),
        ),
      ),
    );
  }

  // Error hit to show the errorId
  Future<void> getWeather() async {
    final response = await http.post(
      Uri.parse('Please use your own API'),
    );
    _alice.onHttpResponse(response);
  }
}
