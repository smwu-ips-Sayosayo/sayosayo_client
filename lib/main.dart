import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sayosayo_client/data/Onboarding_check.dart';
import 'package:sayosayo_client/screens/detecting.dart';
import 'package:sayosayo_client/screens/onboarding.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  bool? isNewUser = await checkUser();
  runApp(SayoSayo(isNewUser,firstCamera));
}
Future<bool> checkUser() async {
  bool? isnewhere = await OnboardingCheck.getUserType();
  if (isnewhere != false) {
    isnewhere = true;
  }
  return isnewhere!;
}

class SayoSayo extends StatelessWidget {
  bool isNewUser;
  dynamic firstCamera;
  SayoSayo(this.isNewUser,this.firstCamera ,{super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SayoSayo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark)),
      ),
      home: isNewUser
            ? Onboarding()
            : Detecting(camera: firstCamera!),
      routes: {
        '/onboarding':(context) => Onboarding(),
        '/detecting':(context) => Detecting(camera: firstCamera!),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}