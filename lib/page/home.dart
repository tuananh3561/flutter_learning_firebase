import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Signed in as',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              user.email!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(
                Icons.arrow_back,
                size: 32,
              ),
              label: const Text(
                "Sign out",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: logOut,
            ),
          ],
        ),
      ),
    );
  }

  Future logOut()  => FirebaseAuth.instance.signOut();
}
