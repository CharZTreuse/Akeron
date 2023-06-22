//Librairies
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtime/pages/read_examples.dart';

//Pages
import 'forgot_password.dart';
import '../methods/loading_page.dart';
import 'sign_up.dart';

FirebaseAuth auth = FirebaseAuth.instance;

//Page de connection
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              akeronIcon,
              titleSection,
              textSection,
              const InputSection(),
              bottomSection,
              const ForgetPasswordLink(),
            ],
          ),
        ),
      ),
    ));
  }
}

Widget akeronIcon = Container(
  height: 140,
  width: 250,
  margin: const EdgeInsets.only(top: 20),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(60),
    color: const Color.fromRGBO(255, 255, 255, 0.1),
  ),
  child: Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 15,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Image.asset('assets/images/logo_akeron.png'),
  ),
);

Widget titleSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Connexion',
        style: GoogleFonts.exo(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    ],
  ),
);

Widget textSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
  child: Text(
    'Page de connexion à Akeron',
    style: GoogleFonts.comfortaa(
      fontSize: 16,
      fontWeight: FontWeight.bold,
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
  const InputSection({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _InputSectionState createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FocusNode textFieldEmailFocusNode = FocusNode();
  FocusNode textFieldPwdFocusNode = FocusNode();

  @override
  void dispose() {
    textFieldEmailFocusNode.dispose();
    textFieldPwdFocusNode.dispose();
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
                            .requestFocus(textFieldEmailFocusNode);
                      },
                      child: SizedBox(
                        height: 60,
                        width: 198,
                        child: TextFormField(
                          focusNode: textFieldEmailFocusNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp('[á-ú Á-Ú]')),
                          ],
                          controller: emailField,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.comfortaa(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Adresse mail',
                            hintStyle:
                                GoogleFonts.comfortaa(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez saisir votre adresse mail';
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
                          textAlign: TextAlign.left,
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
                            if (value!.isEmpty) {
                              return 'Veuillez saisir votre mot de passe';
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
                  "Connexion".toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  if(formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connexion...')));
                      loginToFirebase();
                  } else {
                    debugPrint('Erreur Connexion - Sign In');
                  }
                },
              ),
            ),
//                                                       Password
//------------------------------------------------------------------------------------------------------------------------------------------              
          ],
        ),
      ),
    );
  }

  void loginToFirebase() {
    debugPrint(emailField.text.trim());
    debugPrint(passwordField.text.trim());
    try {
      auth.signInWithEmailAndPassword(
        email: emailField.text.trim(),
        password: passwordField.text.trim())
        .then((userCredential) {
          debugPrint(userCredential.toString());

          // Utilisateur connecté avec succès
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoadingPage(nextPage: ReadExample())),
          );
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}

Widget bottomSection = Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'Pas encore de compte ?',
      style: GoogleFonts.comfortaa(color: Colors.white),
    ),
    const SignupButton(),
  ],
);

class SignupButton extends StatelessWidget {
  const SignupButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      child: Text(
        "Inscrivez-vous",
        style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class ForgetPasswordLink extends StatelessWidget {
  const ForgetPasswordLink({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPassword()),
        );
      },
      child: Text(
        'Mot de passe oublié ?',
        style:
          GoogleFonts.comfortaa(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
      ),
    );
  }
}