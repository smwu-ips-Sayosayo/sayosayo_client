import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sayosayo_client/screens/detecting.dart';

class Onboarding extends StatefulWidget {
  Onboarding({super.key});

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
  String introduction = 
      """
안녕하세요.
앱 사요사요입니다.
사용법을 간단히 알려드리겠습니다.
편의점 내부를 비추시는 경우
하단 버튼을 누르시면 화면 내부를 구성하는 물건 범주와 위치에 대해 안내 받으실 수 있습니다.
물건에 대한 상세 설명을 원하시는 경우
물건을 집은 손을 비추고 버튼을 누르시면 됩니다.
설명을 다시 듣고 싶으신 경우 
언제든지 버튼을 길게 눌러주세요.
자 이제 시작을 위해 하단 버튼을 눌러주세요
""";

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

    await _speak(introduction);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
          Container(
            padding: const EdgeInsets.symmetric(horizontal:20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(introduction, style: TextStyle(
                  fontSize: 20
                ),),
              ],
            ),
          ),

      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, '/detecting', (route) => false);
        },
        onLongPress: () async{
          await _speak(introduction);
        },
        child: Container(
          color: Colors.amber,
          width: double.maxFinite,
          height: 150,
          child: Center(child: Text('시작하기', style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold
          ),))),
      ),
    );
  }
}