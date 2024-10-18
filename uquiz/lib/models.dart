class Member {
  String? id; // เปลี่ยน id เป็น nullable เพื่อให้สามารถไม่มีได้ในกรณีที่เพิ่มใหม่
  String username;
  String first;
  String? last;
  String email;
  String picture;

  Member({
    this.id, // ทำให้ id เป็น optional
    required this.username,
    required this.first,
    this.last,
    required this.email,
    this.picture = 'https://picsum.photos/id/111/256/256',
  });

  // ฟังก์ชัน factory สำหรับแปลง JSON เป็น Member
  factory Member.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('username') &&
        json.containsKey('first') &&
        json.containsKey('email')) {
      return Member(
        id: json['id'] as String?,
        username: json['username'] as String,
        first: json['first'] as String,
        last: json['last'] as String?,
        email: json['email'] as String,
        picture: json['picture'] as String? ??
            'https://picsum.photos/id/111/256/256', // ใช้ default ถ้าไม่มี picture
      );
    } else {
      throw const FormatException('Error: Incorrect JSON format');
    }
  }
}