import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WriteExamples extends StatefulWidget {
  const WriteExamples({Key? key}) : super(key: key);

  @override
  WriteExamplesState createState() => WriteExamplesState();
}

class WriteExamplesState extends State<WriteExamples> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write examples',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        //centerTitle: true,
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
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: SingleChildScrollView(
                child: InputSection(),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class InputSection extends StatelessWidget {
  final database = FirebaseDatabase.instance.ref();
  final textField = TextEditingController();

  InputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            //Send data
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 1),
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromRGBO(255, 255, 255, 0.1),
              ),
              height: 60,
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.people_outline,
                      size: 30,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: 230,
                    child: Center(
                      child: TextFormField(
                        controller: textField,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Saisir une valeur',
                          hintStyle: GoogleFonts.comfortaa(color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), //spacer

            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: Text(
                  "Envoyer".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () async {
                  await firebaseUpdate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  } //Widget
  

  Future<void> firebaseUpdate() async {
    final dailySpecialRef = database.child('esp32/temperature/');

    try {
      await dailySpecialRef.update({
        'temperature': textField.text.trim(),
      });
      debugPrint("Ecriture réussie!");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  } //firebaseUpdate()
}
