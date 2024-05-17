import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sayosayo_client/data/Onboarding_check.dart';
import 'package:sayosayo_client/screens/detecting.dart';
import 'package:sayosayo_client/screens/onboarding.dart';

void main() async{
  bool? isNewUser = await checkUser();
  runApp(SayoSayo(isNewUser));
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
  SayoSayo(this.isNewUser,{super.key});

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
            : Detecting(),
      routes: {
        '/onboarding':(context) => Onboarding(),
        '/detecting':(context) => Detecting(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}