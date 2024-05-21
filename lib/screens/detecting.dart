import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

import 'package:sayosayo_client/api/SayoSayoApi.dart';

class Detecting extends StatefulWidget {
  const Detecting({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  State<Detecting> createState() => _DetectingState();
}

class _DetectingState extends State<Detecting> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  FlutterTts flutterTts = FlutterTts();
  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  String serverResponse = '';

  Timer? _frameTimer;
  int frameInterval = 1000; // 1000 milliseconds = 1 second

  @override
  void initState() {
    super.initState();
    initTts();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream((CameraImage image) {
        if (_frameTimer == null || !_frameTimer!.isActive) {
          _frameTimer = Timer(Duration(milliseconds: frameInterval), () {
            sendImageToServer(image);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  initTts() async {
    await initTtsIosOnly(); // iOS 설정
    flutterTts.setLanguage(language);
    flutterTts.setVoice(voice);
    flutterTts.setEngine(engine);
    flutterTts.setVolume(volume);
    flutterTts.setPitch(pitch);
    flutterTts.setSpeechRate(rate);
  }

  Future<void> initTtsIosOnly() async {
    // iOS 전용 옵션 : 공유 오디오 인스턴스 설정
    await flutterTts.setSharedInstance(true);

    // 배경 음악와 인앱 오디오 세션을 동시에 사용
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  Future _speak(voiceText) async {
    flutterTts.speak(voiceText);
  }

  Future<void> sendImageToServer(CameraImage image) async {
  final bytes = concatenatePlanes(image.planes);
  print("Bytes length: ${bytes.length}"); // 추가된 로그

  try {
    final response = await http.post(
      Uri.parse('${API.hostConnect}/test'),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      setState(() {
        serverResponse = response.body;
      });
      print("Response from server: ${response.body}");
    } else {
      print("Failed to send image to server: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error sending image to server: $e");
  }
}


  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    Uint8List result = allBytes.done().buffer.asUint8List();
    print("Concatenated bytes length: ${result.length}"); // 추가된 로그
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // 미리보기
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Center(
            child: Text(
              serverResponse,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _speak(serverResponse);
        },
        onLongPress: () async {
          Navigator.pushNamedAndRemoveUntil(
              context, '/onboarding', (route) => false);
        },
        child: Container(
          color: Colors.amber,
          width: double.maxFinite,
          height: 150,
          child: Center(
            child: Text(
              '음성',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
