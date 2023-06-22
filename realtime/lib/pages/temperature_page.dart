import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realtime/methods/diamond_divider.dart';
import 'package:realtime/methods/esp32_class.dart';

//classe principale de cette page
class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  TemperaturePageState createState() => TemperaturePageState();
}

class TemperaturePageState extends State<TemperaturePage> {
  //récupération des données de l'appareil
  Esp32? getData;
  //définition d'une reference vers la bdd
  final database = FirebaseDatabase.instance.ref();
  //mise en place d'un écouteur
  late StreamSubscription _esp32Stream;
  late final String uid;

  @override
  void initState() {
    super.initState();
    activateListeners();
  }

//mise en place de l'écouteur
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
  //fin de l'écouteur et suppression
  @override
  void deactivate() {
    _esp32Stream.cancel();
    super.deactivate();
  }

  //Partie design de l'app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //titre de la page
        title: const Text(
          'Modification valeur temperature',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      //corps de la page
      //mise en place du fond dégradé de couleur
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            //dégradé de couleur
            colors: [
              Colors.blue.shade200,
              Colors.blueAccent.shade400,
              Colors.blueAccent.shade700,
            ],
          ),
        ),
        child: Center(
          //permet de pouvoir scroller
          child: SingleChildScrollView(
            child: Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  // Taille minimale pour afficher les Card en taille fixe
                  if (constraints.maxWidth >= 480) {
                    //Affichage de la classe qui contient le contenu textuel
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

//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                      Section Input                                                                     --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------

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

  void increaseSliderValue() {
    setState(() {
      if (sliderValue <= 99.9) {
        sliderValue += 0.1;
      }
    });
  }

  void decreaseSliderValue() {
    setState(() {
      if (sliderValue >= 0.1) {
        sliderValue -= 0.1;
      }
    });
  }

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
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                      Température
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
                              '${widget.getData!.temperature.toStringAsFixed(1)} °C',
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
                      'Température :',
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
                      Icons.thermostat,
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), //spacer
//                                                      Température
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                      Calibration
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
                      '${widget.getData!.calibrationTemperature}',
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
                        sliderValue = widget
                            .getData!.calibrationTemperature
                            .toDouble();
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
                                            sliderValue = sliderValue.clamp(15.0, 35.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                                255, 214, 211, 211),
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
                                          min: 15.0,
                                          max: 35.0,
                                          divisions: 1000,
                                          label: sliderValue
                                              .round()
                                              .toStringAsFixed(1),
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
                                            sliderValue = sliderValue.clamp(15.0, 35.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                                255, 214, 211, 211),
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
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              textFieldFocusNode);
                                                    },
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 60,
                                                        width: 198,
                                                        child: TextFormField(
                                                          focusNode:
                                                              textFieldFocusNode,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
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
                                          const SizedBox(height: 30), //spacer                                          
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
                                            if (value >= 15 && value <= 35) {
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
                                                      "Veuillez saisir une valeur entre 15 et 35.",
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

//                                                      Calibration
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                      Seuil Alerte
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
                      '${widget.getData!.seuilAlerteTemperature}',
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
                        sliderValue = widget
                            .getData!.seuilAlerteTemperature
                            .toDouble();
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
                                            sliderValue = sliderValue.clamp(12.0, 20.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                                255, 214, 211, 211),
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
                                          min: 12.0,
                                          max: 20.0,
                                          divisions: 1000,
                                          label: sliderValue
                                              .round()
                                              .toStringAsFixed(1),
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
                                            sliderValue = sliderValue.clamp(12.0, 20.0);
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                                255, 214, 211, 211),
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
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              textFieldFocusNode);
                                                    },
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 60,
                                                        width: 198,
                                                        child: TextFormField(
                                                          focusNode:
                                                              textFieldFocusNode,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
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
                                          const SizedBox(height: 30), //spacer                                          
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
                                            if (value >= 12 && value <= 20) {
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
                                                      "Veuillez saisir une valeur entre 12 et 20.",
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

//                                                      Seuil Alerte
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
//---------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> calibrationUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/temperature/');
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
        'calibrationTemperature': value,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$value");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> seuilAlerteUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/temperature/');
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
        'seuilAlerteTemperature': value,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$value");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}
