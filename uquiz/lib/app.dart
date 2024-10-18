import 'package:flutter/material.dart';
import 'package:uquiz/controllers.dart';
import 'package:uquiz/home.dart';
import 'package:uquiz/members.dart';
import 'package:get/get.dart';

// import 'home.dart';
// import 'shopping.dart';
import 'login.dart';

class UQuizBindings implements Bindings {
  @override
  void dependencies() {
    // Get.put(() => UQuizController());
    Get.lazyPut(() => UQuizController());
  }

}
class UQuizApp extends StatefulWidget {
  const UQuizApp({super.key});

  @override
  State<UQuizApp> createState() => _UQuizAppState();
}

class _UQuizAppState extends State<UQuizApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UQuiz App',
      initialBinding: UQuizBindings(),
      home: Home(),
      // home: MemberListPage(), //Shopping(),
      // home: const LoginPage(),
    );
  }
}
