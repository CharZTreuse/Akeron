import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realtime/methods/diamond_divider.dart';
import 'package:realtime/methods/esp32_class.dart';

class SaltPage extends StatefulWidget {
  const SaltPage({Key? key}) : super(key: key);

  @override
  SaltPageState createState() => SaltPageState();
}

class SaltPageState extends State<SaltPage> {
  Esp32? getData;
  final database = FirebaseDatabase.instance.ref();
  late StreamSubscription _esp32Stream;
  late final String uid;

  @override
  void initState() {
    super.initState();
    activateListeners();
  }

  void activateListeners() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      _esp32Stream = database.child('root/$uid/appareil1').onValue.listen((event) {
        final value = event.snapshot.value;
        debugPrint('Received data from Firebase: $value');
        if (value is Map<dynamic, dynamic>) {
          final data = Map<String, dynamic>.from(value);
          final displayESP32 = Esp32.fromRTDB(data);
          setState(() {
            getData = displayESP32;
          });
        }
      });
    } else {
      debugPrint('Erreur ReadExamples - Ecouteur');
    }
  }

  @override
  void deactivate() {
    _esp32Stream.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modification valeur sel',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth >= 480) {
                    // Taille minimale pour afficher les Card en taille fixe
                    return InputSection(
                      getData: getData,
                      isResponsive: constraints.maxWidth <= 1000,
                      uid: uid,
                    );
                  } else {
                    // Affichage adaptatif pour les écrans plus petits
                    return InputSection(
                      getData: getData,
                      isResponsive: true,
                      uid: uid,
                    );
                  }
                }),
                const SizedBox(height: 150), //spacer
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputSection extends StatefulWidget {
  final Esp32? getData;
  final database = FirebaseDatabase.instance.ref();
  final textField = TextEditingController();
  final bool isResponsive;
  final String uid;

  InputSection({Key? key, this.getData, required this.isResponsive, required this.uid})
      : super(key: key);

  @override
  State<InputSection> createState() => InputSectionState();
}

class InputSectionState extends State<InputSection> {
  double sliderValue = 0.0;
  FocusNode textFieldFocusNode = FocusNode();

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.getData != null) {
      final orientation = MediaQuery.of(context).orientation;
      final isLandscape = orientation == Orientation.landscape;
      final screenWidth = MediaQuery.of(context).size.width;
      final margin = (screenWidth >= 800 || (isLandscape && screenWidth >= 800))
          ? 70.0
          : 30.0;
      return Form(
        child: Container(
          margin: EdgeInsets.all(margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
//                                                      Affichage
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                        Sel              
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      //border: Border.all(color: Colors.black),
                       boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          offset: const Offset(4, 4), // Décalage vers le bas et la droite
                          blurRadius: 0,
                          spreadRadius: 2,
                        ),
                        const BoxShadow(
                          color: Colors.transparent, // Couleur transparente pour supprimer l'ombre sur les autres côtés
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              '${widget.getData!.salt.toStringAsFixed(1)} g/L',
                              style: TextStyle(
                                fontSize: widget.isResponsive ? 40 : 24,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: Text(
                      'Sel :',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 24 : 24,
                        color: Colors.black,
                      ),
                            textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(620, 86, 0, 0),
                    child: Icon(
                      Icons.grain,
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), //spacer
//                                                        Sel
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                     Calibration
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'Calibration',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      widget.getData!.calibrationSalt.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    trailing: Icon(
                      Icons.more_vert,
                      color: Colors.blue[900],
                    ),

//BottomSheet
                    onTap: () {
                      setState(() {
                        sliderValue = widget.getData!.calibrationSalt.toDouble();
                      });
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                children: [
                                  const SizedBox(height: 30), //spacer
                                  Text(
                                    'Calibration',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    'Veuillez saisir une valeur avec la barre de défilement',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    sliderValue.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 20), //spacer
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            sliderValue -= 0.1;
                                            sliderValue = sliderValue.clamp(5.0, 7.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(255, 214, 211, 211),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.remove,
                                              size: 50,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: sliderValue,
                                          min: 5,
                                          max: 7,
                                          divisions: ((7 - 5) * 10).toInt(),
                                          label:
                                            sliderValue.round().toStringAsFixed(1),
                                          onChanged: (double value) {
                                            setState(() {
                                              sliderValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            sliderValue += 0.1;
                                            sliderValue = sliderValue.clamp(5.0, 7.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(255, 214, 211, 211),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.add,
                                              size: 50,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20), //spacer
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                  Text(
                                    'ou',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(width: 10), //spacer
                                  Text(
                                    'Veuillez saisir une valeur à l\'écrit',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
//Saisie valeur
                                  FractionallySizedBox(
                                    widthFactor:
                                        widget.isResponsive ? 1.0 : 0.6,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          20),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: const Color.fromARGB(
                                                  24, 168, 162, 162),
                                            ),
                                            height: 60,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.blueAccent,
                                                  ),
                                                  child: const Icon(
                                                    Icons.settings,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      FocusScope.of(context).requestFocus(textFieldFocusNode);
                                                    },
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 60,
                                                        width: 198,
                                                        child: TextFormField(
                                                          focusNode: textFieldFocusNode,
                                                          keyboardType: TextInputType.number,
                                                          controller:
                                                              widget.textField,
                                                          textAlign:
                                                              TextAlign.center,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: GoogleFonts
                                                              .comfortaa(
                                                            fontSize: 20,
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Saisir une valeur',
                                                            hintStyle: GoogleFonts
                                                                .comfortaa(
                                                                    color: Colors
                                                                        .blueAccent),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),                                          
                                        ],
                                      ),
                                    ),
                                  ),
//Fin saisie valeur                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
//Annuler                                      
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Annuler".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const SizedBox(width: 30),
//Valider
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: widget.isResponsive ? 20 : 24,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (widget.textField.text.isNotEmpty) {
                                            double value = double.parse(widget.textField.text);
                                            if (value >= 5 && value <= 7) {
                                              // La valeur saisie est dans la plage attendue
                                                await calibrationUpdate();
                                                // ignore: use_build_context_synchronously
                                                Navigator.pop(context);
                                            } else {
                                              // La valeur saisie n'est pas dans la plage attendue
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text("Erreur"),
                                                    content: const Text(
                                                      "Veuillez saisir une valeur entre 5 et 7.",
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("OK"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            // La valeur du textField n'est pas saisie
                                            // On peut procéder à la mise à jour directement avec la valeur du slider
                                            await calibrationUpdate();
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                          }); //BottomSheet
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20), //spacer

//                                                     Calibration
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                     Seuil Alerte
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'Seuil Alerte',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      widget.getData!.seuilAlerteSalt.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    trailing: Icon(
                      Icons.more_vert,
                      color: Colors.blue[900],
                    ),

//BottomSheet
                    onTap: () {
                      setState(() {
                        sliderValue = widget.getData!.seuilAlerteSalt.toDouble();
                      });
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                children: [
                                  const SizedBox(height: 30), //spacer
                                  Text(
                                    'Seuil Alerte',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    'Veuillez saisir une valeur avec la barre de défilement',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    sliderValue.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 20), //spacer
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            sliderValue -= 0.1;
                                            sliderValue = sliderValue.clamp(5.0, 7.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(255, 214, 211, 211),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.remove,
                                              size: 50,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: sliderValue,
                                          min: 0,
                                          max: 4,
                                          divisions: (4 * 10).toInt(),
                                          label:
                                            sliderValue.round().toStringAsFixed(1),
                                          onChanged: (double value) {
                                            setState(() {
                                              sliderValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            sliderValue += 0.1;
                                            sliderValue = sliderValue.clamp(0.0, 4.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(255, 214, 211, 211),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.add,
                                              size: 50,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20), //spacer
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                  Text(
                                    'ou',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(width: 10), //spacer
                                  Text(
                                    'Veuillez saisir une valeur à l\'écrit',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 22 : 26,
                                      color: Colors.blue[900],
                                    ),
                                  ),
//Saisie valeur
                                  FractionallySizedBox(
                                    widthFactor:
                                        widget.isResponsive ? 1.0 : 0.6,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          20),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: const Color.fromARGB(
                                                  24, 168, 162, 162),
                                            ),
                                            height: 60,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.blueAccent,
                                                  ),
                                                  child: const Icon(
                                                    Icons.settings,
                                                    size: 30,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      FocusScope.of(context).requestFocus(textFieldFocusNode);
                                                    },
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 60,
                                                        width: 198,
                                                        child: TextFormField(
                                                          focusNode: textFieldFocusNode,
                                                          keyboardType: TextInputType.number,
                                                          controller:
                                                              widget.textField,
                                                          textAlign:
                                                              TextAlign.center,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: GoogleFonts
                                                              .comfortaa(
                                                            fontSize: 20,
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Saisir une valeur',
                                                            hintStyle: GoogleFonts
                                                                .comfortaa(
                                                                    color: Colors
                                                                        .blueAccent),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),                                          
                                        ],
                                      ),
                                    ),
                                  ),
//Fin saisie valeur                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
//Annuler                                      
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Annuler".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const SizedBox(width: 30),
//Valider
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: widget.isResponsive ? 20 : 24,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (widget.textField.text.isNotEmpty) {
                                            double value = double.parse(widget.textField.text);
                                            if (value >= 0 && value <= 4) {
                                              // La valeur saisie est dans la plage attendue
                                                await seuilAlerteUpdate();
                                                // ignore: use_build_context_synchronously
                                                Navigator.pop(context);
                                            } else {
                                              // La valeur saisie n'est pas dans la plage attendue
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text("Erreur"),
                                                    content: const Text(
                                                      "Veuillez saisir une valeur entre 0 et 4.",
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("OK"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            // La valeur du textField n'est pas saisie
                                            // On peut procéder à la mise à jour directement avec la valeur du slider
                                            await seuilAlerteUpdate();
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                          }); //BottomSheet
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20), //spacer

//                                                        Seuil
//------------------------------------------------------------------------------------------------------------------------------------------ 

              const SizedBox(height: 20), //spacer
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: const DiamondDivider(
                  width: double.infinity,
                  height: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20), //spacer

              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: SizedBox(
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
                      "Retour".toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: widget.isResponsive ? 20 : 24,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> calibrationUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/salt/');
    try {
      double value;
      if (widget.textField.text.isNotEmpty) {
        // Utilise la valeur du textField si elle est non vide
        value = double.parse(widget.textField.text.trim());
      } else {
        // Utilise la valeur du slider
        value = sliderValue;
      }
      // Arrondit la valeur à un seul chiffre après la virgule
      value = double.parse(value.toStringAsFixed(1));

      await databaseRef.update({
        'calibrationSalt': value,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$value");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  } //calibrationUpdate

  Future<void> seuilAlerteUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/salt/');
    try {
      double value;
      if (widget.textField.text.isNotEmpty) {
        // Utilise la valeur du textField si elle est non vide
        value = double.parse(widget.textField.text.trim());
      } else {
        // Utilise la valeur du slider
        value = sliderValue;
      }
      // Arrondit la valeur à un seul chiffre après la virgule
      value = double.parse(value.toStringAsFixed(1));

      await databaseRef.update({
        'seuilAlerteSalt': value,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$value");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  } //calibrationUpdate

  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}
