import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController(); // ฟิลด์สำหรับชื่อ
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController(); // ฟิลด์สำหรับยืนยันรหัสผ่าน

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose(); // ล้างฟิลด์ชื่อ
    passwordController.dispose();
    passwordConfirmController.dispose(); // ล้างฟิลด์ยืนยันรหัสผ่าน
    super.dispose();
  }

  Future<void> _register() async {
    final pb = PocketBase('http://127.0.0.1:8090');
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != passwordConfirmController.text) {
        // ตรวจสอบว่ารหัสผ่านและยืนยันรหัสผ่านตรงกันหรือไม่
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      try {
        // เปลี่ยนไปเก็บข้อมูลใน collection 'members' แทน 'users'
        await pb.collection('members').create(body: {
          'email': emailController.text,
          'username': nameController.text, // ใช้ฟิลด์ username ใน members
          'first': nameController.text, // เก็บชื่อในฟิลด์ first
          'password': passwordController.text,
          'passwordConfirm': passwordConfirmController.text,
          'picture': 'https://picsum.photos/id/111/256/256', // ใช้ URL รูปภาพเป็นค่า default
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordConfirmController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
