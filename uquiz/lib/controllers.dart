import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uquiz/home.dart';
import 'models.dart';

class UQuizController extends GetxController {
  var appName = 'uQuiz'.obs;
  var memberCount = 0.obs;
  var isAdmin = false.obs;
  var isAuthenticated = false.obs;
  var memberList = <Member>[].obs;

  final pb = PocketBase('http://127.0.0.1:8090');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ฟังก์ชันสำหรับการล็อกอิน
  Future<bool> authen(String email, String password) async {
    try {
      await pb.admins.authWithPassword(email, password);
      isAdmin.value = true;
      if (pb.authStore.isValid) {
        isAuthenticated.value = true;
        await getAllMembers();
        return true;
      }
    } catch (e) {
      try {
        await pb.collection('users').authWithPassword(email, password);
        isAdmin.value = false;
        if (pb.authStore.isValid) {
          isAuthenticated.value = true;
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // ฟังก์ชันสำหรับการดึงข้อมูลสมาชิกทั้งหมด
  Future<void> getAllMembers() async {
    try {
      final result = await pb.collection('members').getFullList();
      memberList.value = result.map((user) {
        return Member.fromJson({
          'id': user.id,
          'username': user.data['username'],
          'first': user.data['first'],
          'last': user.data['last'],
          'email': user.data['email'],
          'picture': user.data['picture'],
        });
      }).toList();
      memberCount.value = memberList.length;
    } catch (e) {
      print('Failed to fetch members: $e');
    }
  }

  // ฟังก์ชันสำหรับการเพิ่มสมาชิก
  Future<void> addMember(Member member) async {
    try {
      final record = await pb.collection('members').create(body: {
        'username': member.username,
        'first': member.first,
        'last': member.last,
        'email': member.email,
        'picture': member.picture,
      });

      // อัปเดต memberList ทันทีที่มีการเพิ่มสมาชิกใหม่
      member.id = record.id; // รับ id ที่สร้างขึ้นจากฐานข้อมูล
      await getAllMembers(); // อัปเดตข้อมูลสมาชิกใหม่หลังจากเพิ่มสำเร็จ
      print('Member added: ${member.username}');
    } catch (e) {
      print('Failed to add member: $e');
    }
  }

  // ฟังก์ชันสำหรับการสมัครสมาชิกใหม่
  Future<bool> registerMember({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String pictureUrl,
  }) async {
    try {
      // เพิ่มข้อมูลผู้ใช้ใหม่ไปยัง collection 'members'
      await pb.collection('members').create(body: {
        'username': username,
        'first': firstName,
        'last': lastName,
        'email': email,
        'password': password, // เพิ่มรหัสผ่านในการสร้างสมาชิก
        'passwordConfirm': password,
        'picture': pictureUrl,
      });

      print('Registration successful for: $username');
      return true;
    } catch (e) {
      print('Failed to register member: $e');
      return false;
    }
  }

  // ฟังก์ชันสำหรับการลบสมาชิก
  Future<void> deleteMember(String id) async {
    try {
      // ตรวจสอบว่า `id` นั้นไม่ว่าง
      if (id.isNotEmpty) {
        await pb.collection('members').delete(id);
        await getAllMembers(); // อัปเดตข้อมูลสมาชิกหลังจากลบสำเร็จ
        print('Member deleted by id: $id');
      } else {
        print('Cannot delete member with empty id');
      }
    } catch (e) {
      print('Failed to delete member: $e');
    }
  }

  // ฟังก์ชันสำหรับการล็อกเอาต์
  void logout() {
    isAuthenticated.value = false;
    isAdmin.value = false;
    pb.authStore.clear();
    Get.offAll(Home());
  }
}
