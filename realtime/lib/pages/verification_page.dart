import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../methods/loading_page.dart';
import 'read_examples.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  Timer? emailVerificationTimer;
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    emailVerification();
  }

  @override
  void dispose() {
    emailVerificationTimer?.cancel();
    super.dispose();
  }

  void emailVerification() {
    emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await checkEmailVerified();
    });
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      emailVerificationTimer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoadingPage(nextPage: ReadExample())),
      );
    } else {
      setState(() {
        isEmailVerified = false;
      });
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blueAccent.shade400,
              Colors.blueAccent.shade700,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Un e-mail de vérification vous a été envoyé.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    sendVerificationEmail();
                  },
                  child: const Text('Renvoyer l\'e-mail de vérification'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
