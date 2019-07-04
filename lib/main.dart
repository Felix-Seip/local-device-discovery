import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:http/http.dart' as http;
import 'package:ping_discover_network/ping_discover_network.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Map<String, List<String>> clocks = Map();

  void _incrementCounter() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    stream.listen((NetworkAddress addr) {
      _testConnection(client, addr.ip);
    });
  }

  void _testConnection(final HttpClient client, final String ip) async {
    try {
      final request = await client
          .getUrl(Uri.parse('http://$ip/wordclock/connection/test'));
      final response =
          await request.close().timeout(const Duration(seconds: 2));
      if ('OK'.compareTo(response.reasonPhrase) == 0) {
        if (!clocks.containsKey("word-clock")) {
          clocks.addEntries([
            MapEntry(
              "word-clock",
              List(),
            )
          ]);
        }

        if (!clocks["word-clock"].contains(ip)) {
          print('Found a word clock with ip $ip! Adding it to list of clocks');
          clocks["word-clock"].add(ip);
        }
      }
    } on SocketException catch (e) {
      //NOP
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
