// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_database/firebase_database.dart';
import 'verification_page.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final databaseRef = FirebaseDatabase.instance.ref();

//Page d'inscription
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  late DateFormat dateFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMd('fr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
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
                textSection,
                InputSection(dateFormat: dateFormat,),
                bottomSection,
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget textSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
  child: Text(
    'Création d\'un compte',
    style: GoogleFonts.comfortaa(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    ),
  ),
);

//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                      Section Input                                                                     --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------

class InputSection extends StatefulWidget {
  final DateFormat dateFormat;

  const InputSection({Key? key, required this.dateFormat}) : super(key: key);

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  final nomField = TextEditingController();
  final prenomField = TextEditingController();
  final birthdateField = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FocusNode textFieldNomFocusNode = FocusNode();
  FocusNode textFieldPrenomFocusNode = FocusNode();
  FocusNode textFieldEmailFocusNode = FocusNode();
  FocusNode textFieldPwdFocusNode = FocusNode();
  FocusNode textFieldDateFocusNode = FocusNode();

  @override
  void dispose() {
    textFieldNomFocusNode.dispose();
    textFieldPrenomFocusNode.dispose();
    textFieldEmailFocusNode.dispose();
    textFieldPwdFocusNode.dispose();
    textFieldDateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          children: [
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                          Nom
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(textFieldNomFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 198,
                        child: TextFormField(
                          focusNode: textFieldNomFocusNode,
                          controller: nomField,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.comfortaa(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nom',
                            hintStyle:
                                GoogleFonts.comfortaa(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp('[Á-Ú 0-9]'))
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez saisir votre Nom';
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

            const SizedBox(height: 30), // Spacer

//                                                         Nom
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                        Prénom
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(textFieldPrenomFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 230,
                        child: TextFormField(
                          focusNode: textFieldPrenomFocusNode,
                          controller: prenomField,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.comfortaa(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Prénom',
                            hintStyle:
                                GoogleFonts.comfortaa(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp('[Á-Ú 0-9]'))
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez saisir votre Prénom';
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

            const SizedBox(height: 30),
//                                                        Prénom
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                         Mail
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
                        FocusScope.of(context)
                            .requestFocus(textFieldEmailFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 230,
                        child: TextFormField(
                          focusNode: textFieldEmailFocusNode,
                          controller: emailField,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.comfortaa(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Adresse mail',
                            hintStyle:
                                GoogleFonts.comfortaa(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez saisir votre adresse mail';
                            } else if (!RegExp(
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
            const SizedBox(height: 30), //spacer
//                                                         Mail
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                       Password
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
                      Icons.lock_outline,
                      size: 30,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(textFieldPwdFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 198,
                        child: TextFormField(
                          focusNode: textFieldPwdFocusNode,
                          controller: passwordField,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.comfortaa(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            hintStyle:
                                GoogleFonts.comfortaa(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            //minimum 8 caractères
                            if (value!.length < 8) {
                              return 'Minimum 8 caractères';
                            } else if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                              //'Le mot de passe doit contenir au moins 1 minuscule, 1 majuscule, 1 chiffre et 1 caractère spécial.'
                              return 'Le mot de passe doit contenir au moins 1 minuscule, 1 majuscule, 1 chiffre et 1 caractère spécial.';
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
//                                                       Password  
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                       Birthday
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
                      Icons.date_range,
                      size: 30,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(textFieldDateFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 230,
                        child: Center(
                          child: TextFormField(
                            controller: birthdateField,
                            readOnly: true,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.comfortaa(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Date de naissance',
                              hintStyle: GoogleFonts.comfortaa(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez saisir votre date de naissance';
                              } else {
                                return null;
                              }
                            },
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                birthdateField.text =
                                    DateFormat.yMd(widget.dateFormat.locale)
                                        .format(pickedDate);
                              } else {
                                debugPrint('Error!');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), //spacer
//                                                       Birthday  
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                   Bouton inscription
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
                  "Inscription".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  if(formKey.currentState!.validate()) {
                      signUpToFirebase();
                  } else {
                    const SnackBar(content: Text('Identifiant ou mot de passe incorrect'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

//                                                    Bouton inscription
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                   Méthode d'inscription

Future<void> signUpToFirebase() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final addUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailField.text.trim(),
      password: passwordField.text.trim(),
    );

    await addUser.user!.sendEmailVerification();

    final dbRef = databaseRef.child('root').child(addUser.user!.uid).child('user');
    await dbRef.set({
      'uid': addUser.user!.uid,
      'nom': nomField.text.trim(),
      'prenom': prenomField.text.trim(),
      'birthdate': birthdateField.text.trim(),
    });

    Navigator.pop(context); // Ferme la boîte de dialogue de chargement
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie')));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerificationPage()),
    );
  } catch (error, stackTrace) {
    debugPrint('Erreur : $error');
    debugPrint('Trace de la pile : $stackTrace');

//S'il existe déjà un compte lié à cette adresse mail
    if (error.toString().contains('email address is already in use')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur : Compte existant'),
            content: const Text('Un compte existe déjà avec cette adresse e-mail.'),
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
    } else {
      Navigator.pop(context); // Ferme la boîte de dialogue de chargement
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'inscription')));
    }
  }
}
}

//                                                   Méthode d'inscription
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                      Bottom Section

Widget bottomSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Déjà un compte ?',
        style: GoogleFonts.comfortaa(color: Colors.white),
      ),
      const SignInButton(),
    ],
  ),
);

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