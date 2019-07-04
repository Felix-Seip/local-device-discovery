import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';

import './device_list_item.dart';
import './device.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Local Device Scanner',
      ),
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
  List<Device> devices = [];

  Future<Null> _scanDevices() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port);
    http.Client client = http.Client();
    stream.listen((NetworkAddress addr) {
      _testConnection(client, addr.ip);
    });

    return null;
  }

  void _testConnection(final http.Client client, final String ip) async {
    try {
      final response = await client.get(Uri.parse('http://$ip/helloWorld'));

      if (response.statusCode == 200) {
        if (!response.body.startsWith("<")) {
          if (!devices.contains(ip)) {
            print('Found a device with ip $ip! Adding it to list of devices');
            List<Device> containedDevices = [];
            for (Device device in devices) {
              if (device.ipAddress.compareTo(ip) == 0) {
                containedDevices.add(device);
              }
            }

            if (containedDevices.length == 0) {
              setState(() {
                devices.add(
                  Device(ip),
                );
              });
            }
          }
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: RefreshIndicator(
        onRefresh: () {},
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return DeviceListItem(devices[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
