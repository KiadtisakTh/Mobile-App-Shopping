import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  String errorMessage = '';

  final pb = PocketBase('http://127.0.0.1:8090');

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      if (pb.authStore.isValid) {
        final response = await pb.collection('members').getList(page: 1, perPage: 20);
        setState(() {
          members = response.items.map((item) => item.data as Map<String, dynamic>).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load members: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      elevation: 4,
                      child: ListTile(
                        leading: member.containsKey('picture') && member['picture'] != null
                            ? Image.network(
                                member['picture'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 50),
                        title: Text(
                          '${member['username']} (${member['first']} ${member['last'] ?? ''})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(member['email'] ?? 'No Email'),
                      ),
                    );
                  },
                ),
    );
  }
}
