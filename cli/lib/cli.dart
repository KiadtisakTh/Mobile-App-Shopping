import 'package:pocketbase/pocketbase.dart';
import 'package:requests/requests.dart';

void main() async {
  const url = "https://randomuser.me/api/?results=20";
  // dart pub add requests
  var r = await Requests.get(url);
  var memberData = r.json()['results'];
  // dart pub add pocketbase
  final pb = PocketBase('http://127.0.0.1:8090');
  final admin = 'admin@ubu.ac.th';
  final password = 'admin@dssi'; // '1234';
  //var authData = await pb.admins.authWithPassword(admin, password);
  final e = 'anna@ubu.ac.th';
  final p = 'anna@dssi';
  var authData = await pb.collection('users').authWithPassword(e, p);
  print('isValid: ${pb.authStore.isValid}');
  print('token: ${pb.authStore.token}'); // Json Web Token (jwt)
  print('user.id: ${pb.authStore.model.id}');

  for (int i = 0; i < 20; i++) {
    var data = memberData[i];
    print('add new member: ${data["email"]}');
    await pb.collection('members').create(body: {
      'username': data['login']['username'],
      'email': data['email'],
      'picture': data['picture']['large'],
      'first': data['name']['first'],
      'last': data['name']['last']
    });
  }
}
