import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning_firebase/main.dart';
import 'package:flutter_learning_firebase/widget/utils.dart';

class SignUpWidget extends StatefulWidget {

  final VoidCallback onClickedSignIn;

  const SignUpWidget({Key? key, required this.onClickedSignIn}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: "Email"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) => email != null && !EmailValidator.validate(email) ? 'Email a valid email' : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: passwordController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => value != null && value.trim().length < 6 ? 'Enter min. 6 characters' : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: confirmPasswordController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => value != null && value.trim() != passwordController.text.trim() ? 'Confirm password does not match password' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.lock_open, size: 32),
              label: const Text(
                "Sign In",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: singUp,
            ),
            const SizedBox(height: 24,),
            RichText(text: TextSpan(
                style: const TextStyle(color: Colors.white,fontSize: 18),
                text: 'Already have an account?  ',
                children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer() ..onTap = widget.onClickedSignIn,
                      text: "Log In",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary
                      )
                  )
                ]
            ))
          ],
        ),
      ),
    );
  }

  Future singUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    }
    // Navigator.of(context) not working
    navigatorKey.currentState!.popUntil((route)=> route.isFirst);
  }
}
