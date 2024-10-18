import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uquiz/controllers.dart';
import 'home.dart'; // import หน้า Home

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UQuizController>();
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Login', style: TextStyle(fontSize: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: ctrl.emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                controller: ctrl.passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // ทำการล็อกอินแล้วส่งกลับไปที่หน้าแรก
                    bool loginSuccess = await ctrl.authen(
                      ctrl.emailController.text,
                      ctrl.passwordController.text,
                    );
                    if (loginSuccess) {
                      // ถ้าล็อกอินสำเร็จ จะไปที่หน้า Home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    } else {
                      // แสดงข้อความแจ้งเตือนถ้าล็อกอินไม่สำเร็จ
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed. Please try again.')),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
