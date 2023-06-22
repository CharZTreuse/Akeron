import 'dart:async';
import 'package:flutter/material.dart';
import 'package:realtime/methods/esp32_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoadingPage extends StatefulWidget {
  final Widget nextPage;

  const LoadingPage({Key? key, required this.nextPage}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late StreamSubscription dataLoading;
  Esp32? esp32Data;
  final database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    dataLoading.cancel();
    super.dispose();
  }

  void loadData() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String uid = user.uid;
    //UID pour récupérer les données de l'appareil dans la base de données
    dataLoading = database.child('root').child(uid).child('appareil1').onValue.listen((event) {
    final value = event.snapshot.value;
      debugPrint('Received data from Firebase: $value');
      if (value is Map<dynamic, dynamic>) {
        final data = Map<String, dynamic>.from(value);
        final displayESP32 = Esp32.fromRTDB(data);
        setState(() {
          esp32Data = displayESP32;
        });
      }
    });
  } else {
    debugPrint('Erreur LoadingPage');
  }
  //J'utilise un délai pour voir la page de chargement
  Future.delayed(const Duration(seconds: 1), () {
    //Redirection vers la page suivante
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.nextPage));
  });
}

  //Corps page de chargement
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), //Cercle de chargement
      ),
    );
  }
}

