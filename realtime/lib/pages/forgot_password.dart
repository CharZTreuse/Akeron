import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialisation Mot de passe'),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageSection,
              titleSection,
              subtitleSection,
              const EntryFieldSection(),
              const SignInButton(),
            ],
          ),
        ),
      ),
    ));
  }
}

Widget imageSection = const Icon(
  Icons.mail_outline,
  size: 100,
  color: Colors.white,
);

Widget titleSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Mot de passe oublié',
        style: GoogleFonts.exo(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    ],
  ),
);

Widget subtitleSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
  child: Text(
    'Page de réinitialisation de mot de passe',
    style: GoogleFonts.comfortaa(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);

class EntryFieldSection extends StatefulWidget {
  const EntryFieldSection({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EntryFieldSection createState() => _EntryFieldSection();
}

class _EntryFieldSection extends State<EntryFieldSection> {
  final emailController = TextEditingController();
  FocusNode textFieldFocusNode = FocusNode();

    @override
  void dispose() {
    emailController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Mail envoyé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Un mail a été envoyé à l\'adresse suivante : ${emailController.text.trim()}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (error) {
      debugPrint(error.toString());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(error.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          children: [
            //Mail
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
                      Icons.mail_outline,
                      size: 30,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(textFieldFocusNode);
                      },
                        child: SizedBox(
                          height: 60,
                          width: 198,
                            child: TextFormField(
                              focusNode: textFieldFocusNode,
                              controller: emailController,
                              style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: 'Adresse mail',
                                hintStyle: GoogleFonts.comfortaa(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Veuillez saisir votre adresse mail';
                                } else if(!RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                  .hasMatch(value)) {
                                  return "Veuillez saisir une adresse mail valide";
                                } else {
                                  return null;
                                }
                              },
                            ),
                        ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), //Spacer

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
                  "Continuer".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  passwordReset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(
          context,
        );
      },
      child: Text(
        "Se connecter",
        style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}