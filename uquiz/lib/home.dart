import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uquiz/controllers.dart';
import 'package:uquiz/login.dart';
import 'package:uquiz/models.dart';
import 'package:uquiz/register.dart';
import 'shopping.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final uQuizController = Get.put(UQuizController());

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลสมาชิกเมื่อเข้าไปในหน้า Home และผู้ใช้เป็นแอดมิน
    if (uQuizController.isAdmin.value) {
      uQuizController.getAllMembers();
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      _buildHomePage(),
      const Shopping(),
      const Center(child: Text('This is Profile Page')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('UQuizApp'),
        backgroundColor: Colors.blueAccent,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to UQuizApp!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Obx(() {
              if (uQuizController.isAuthenticated.value) {
                return Column(
                  children: [
                    const Text(
                      'You are logged in!',
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        uQuizController.logout();
                      },
                      child: const Text('Log Out'),
                    ),
                    const SizedBox(height: 20),

                    if (uQuizController.isAdmin.value) ...[
                      const Text(
                        'User List:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // เปิด Dialog สำหรับเพิ่มสมาชิกใหม่
                          _showAddMemberDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Add New Member'),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: uQuizController.memberList.length,
                          itemBuilder: (context, index) {
                            final member = uQuizController.memberList[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
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
                                    if (member.id != null && member.id!.isNotEmpty) {
                                      uQuizController.deleteMember(member.id!);
                                    } else {
                                      print('Cannot delete member with empty id');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ],
                );
              } else {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text('Log In'),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final firstController = TextEditingController();
    final lastController = TextEditingController();
    final emailController = TextEditingController();
    final pictureController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
  }
}
