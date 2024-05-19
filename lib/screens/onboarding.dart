import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  /* 언어 설정
    한국어    =   "ko-KR"
    일본어    =   "ja-JP"
    영어      =   "en-US"
    중국어    =   "zh-CN"
    프랑스어  =   "fr-FR"
  */
  /* 음성 설정
      한국어 여성 {"name": "ko-kr-x-ism-local", "locale": "ko-KR"}
      영어 여성 {"name": "en-us-x-tpf-local", "locale": "en-US"}
      일본어 여성 {"name": "ja-JP-language", "locale": "ja-JP"}
      중국어 여성 {"name": "cmn-cn-x-ccc-local", "locale": "zh-CN"}
      중국어 남성 {"name": "cmn-cn-x-ccd-local", "locale": "zh-CN"}
  */
  FlutterTts flutterTts = FlutterTts();
  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;

  @override
  void initState() {
    super.initState();
    // TTS 초기 설정
    initTts();
  }

  initTts() async {
    await initTtsIosOnly(); // iOS 설정
    flutterTts.setLanguage(language);
    flutterTts.setVoice(voice);
    flutterTts.setEngine(engine);
    flutterTts.setVolume(volume);
    flutterTts.setPitch(pitch);
    flutterTts.setSpeechRate(rate);

    await _speak("안녕하세요");
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
      IosTextToSpeechAudioMode.voicePrompt);
  }

  Future _speak(voiceText) async {
    flutterTts.speak(voiceText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}