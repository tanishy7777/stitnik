import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';




void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: "basic_channel",
        channelName: "basic_channel",
        channelDescription: "channelDescription"
        ),
    ],
    debug: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Timer? timer;

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<bool> getBabyStatus() async {
    final response = await http
        .get(Uri.parse('http://192.168.230.216:3000/baby'));

    if (response.statusCode == 204) {
      return false;
    } else if (response.statusCode == 404) {
      return true;
    }

    throw Exception('Server returned a weird error');
  }

  sendNotification() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      late Future<bool> status = getBabyStatus();
      status.then((value) {
        if (!value) {
          AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 9166,
            channelKey: 'basic_channel',
            title: 'First Notification',
            body: 'Baby found',
            ) 
          );
        }
      });
    });
  }

  playSound() async {
    final player = AudioPlayer();
    await player.play(UrlSource('https://example.com/my-audio.wav'));
  }
  
  triggerNotification() {
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) => sendNotification());
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: triggerNotification,
          child: const Text('Trigger Notification'),
          ), 
        ),
      );
  }   
}