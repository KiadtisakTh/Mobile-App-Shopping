import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uquiz/controllers.dart'; // Import UQuizController
import 'package:uquiz/models.dart'; // Import Member class

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final uQuizController = Get.put(UQuizController());

  @override
  void initState() {
    super.initState();
    uQuizController.getAllMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Dialog สำหรับการเพิ่มสมาชิกใหม่
              showDialog(
                context: context,
                builder: (context) {
                  final usernameController = TextEditingController();
                  final firstController = TextEditingController();
                  final lastController = TextEditingController();
                  final emailController = TextEditingController();
                  final pictureController = TextEditingController();

                  return AlertDialog(
                    title: const Text('Add New Member'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(labelText: 'Username'),
                          ),
                          TextField(
                            controller: firstController,
                            decoration: const InputDecoration(labelText: 'First Name'),
                          ),
                          TextField(
                            controller: lastController,
                            decoration: const InputDecoration(labelText: 'Last Name'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          TextField(
                            controller: pictureController,
                            decoration: const InputDecoration(labelText: 'Picture URL'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // เพิ่มสมาชิกใหม่โดยเรียกใช้ฟังก์ชันใน controller
                          final newMember = Member(
                            username: usernameController.text,
                            first: firstController.text,
                            last: lastController.text,
                            email: emailController.text,
                            picture: pictureController.text, 
                            id: '',
                          );
                          uQuizController.addMember(newMember);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (uQuizController.memberList.isEmpty) {
          return const Center(
            child: Text(
              'No members available.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: uQuizController.memberList.length,
            itemBuilder: (context, index) {
              final member = uQuizController.memberList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                elevation: 4,
                child: ListTile(
                  leading: Image.network(
                    member.picture,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    '${member.username} (${member.first} ${member.last ?? ''})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(member.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // ลบสมาชิก
                      uQuizController.deleteMember(member.username);
                    },
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
