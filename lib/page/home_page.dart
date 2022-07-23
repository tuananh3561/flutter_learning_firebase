import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning_firebase/model/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final controller = TextEditingController();

  Widget buildListUser() => StreamBuilder<List<User>>(
        stream: readUser(),
        builder: (context, snapshot) {
          debugPrint(snapshot.error.toString());
          if (snapshot.hasError) {
            return Text("Something went wrong ${snapshot.error}");
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView(
              children: users.map(buildUser).toList(),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );

  Widget futureBuildUser() => FutureBuilder<User?>(
        future: readUser2(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong ${snapshot.error}");
          } else if (snapshot.hasData) {
            final user = snapshot.data;
            return user == null
                ? const Center(child: Text("Not User"))
                : buildUser(user);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(
          child: Text('${user.age}'),
        ),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
      );

  Stream<List<User>> readUser() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshots) =>
          snapshots.docs.map((doc) => User.fromJson(doc.data())).toList());

  Future<User?> readUser2() async {
    final docUser = FirebaseFirestore.instance
        .collection('users')
        .doc('jFTIfzFskgVz5tXFRCkG');
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All User"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/user');
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: buildListUser()
      // body: futureBuildUser()
    );
  }
}
