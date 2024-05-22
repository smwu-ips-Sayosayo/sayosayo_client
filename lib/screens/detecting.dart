import 'dart:convert';
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
  late CameraController _cameraController;
  bool _isSending = false;
  String? _serverResponse;
  Timer? _timer;

  late Future<void> _initializeControllerFuture;
  FlutterTts flutterTts = FlutterTts();
  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  String serverResponse = '';


  @override
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    setState(() {});

    // Start the timer to capture and send image every second
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isSending) {
        _captureAndSendImage();
      }
    });
  }

  Future<void> _captureAndSendImage() async {
    setState(() {
      _isSending = true;
      _serverResponse = null;
    });

    try {
      XFile? capturedImage = await _cameraController.takePicture();

      if (capturedImage != null) {
        Uint8List imageBytes = await capturedImage.readAsBytes();
        print("Image bytes length: ${imageBytes.length}");

        final response = await http.post(
          Uri.parse('${API.hostConnect}/stream'),
          headers: {
            'Content-Type': 'application/octet-stream',
          },
          body: imageBytes,
        );

        if (response.statusCode == 200) {
          setState(() {
          Map<String, dynamic> decodedResponse = jsonDecode(response.body);
          serverResponse = decodedResponse['message'];
          });
          print("Response from server: ${response.body}");
          print(serverResponse);
        } else {
          print("Failed to send image to server: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      }
    } catch (e) {
      print("Error capturing or sending image: $e");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer?.cancel();
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

  Future<String> base64String(Uint8List data) async {
  return base64Encode(data);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_cameraController.value.isInitialized)
            CameraPreview(_cameraController),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSending) CircularProgressIndicator(),
              if (_serverResponse != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Server response: $_serverResponse'),
                ),
              SizedBox(height: 20),
            ],
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


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<void>(
//               future: _initializeControllerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   // 미리보기
//                   return CameraPreview(_controller);
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//           Center(
//             child: Text(
//               serverResponse,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: () {
//           _speak(serverResponse);
//         },
//         onLongPress: () async {
//           Navigator.pushNamedAndRemoveUntil(
//               context, '/onboarding', (route) => false);
//         },
//         child: Container(
//           color: Colors.amber,
//           width: double.maxFinite,
//           height: 150,
//           child: Center(
//             child: Text(
//               '음성',
//               style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
