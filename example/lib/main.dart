import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:dio_proxy_plugin/dio_proxy_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceProxy = '';

  Future<void> _setProxy() async {
    String deviceProxy = '';
    var dio = Dio()..options.baseUrl = 'https://httpbin.org/';
    if (!kReleaseMode && Platform.isIOS) {
      try {
        deviceProxy = await DioProxyPlugin.deviceProxy;
      } on PlatformException {
        deviceProxy = '';
        print('Failed to get system proxy.');
      }
      if (null != deviceProxy && deviceProxy.isNotEmpty) {
        var arrProxy = deviceProxy.split(':');

        //设置dio proxy
        var httpProxyAdapter = HttpProxyAdapter(
            ipAddr: arrProxy[0], port: int.tryParse(arrProxy[1]));
        dio.httpClientAdapter = httpProxyAdapter;
      }

      // test dio
      var response = await dio.get('/get?a=2');
      print(response.data);
      response = await dio.post('/post', data: {'a': 2});
      print(response.data);
    }

    if (!mounted) return;

    setState(() {
      _deviceProxy = deviceProxy;
    });
  }

  @override
  void initState() {
    super.initState();
    _setProxy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Device proxy: $_deviceProxy\n'),
        ),
      ),
    );
  }
}
