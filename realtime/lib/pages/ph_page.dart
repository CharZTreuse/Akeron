import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realtime/methods/diamond_divider.dart';
import 'package:realtime/methods/esp32_class.dart';

class PhPage extends StatefulWidget {
  const PhPage({Key? key}) : super(key: key);

  @override
  PhPageState createState() => PhPageState();
}

class PhPageState extends State<PhPage> {
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
          'Modification valeur pH',
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
//                                                         pH              
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
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
                              widget.getData!.pH.toStringAsFixed(1),
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
                      'pH :',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 24 : 24,
                        color: Colors.black,
                      ),
                            textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(620, 86, 0, 0),
                    child: Image.asset(
                      'assets/images/logo_ph.png',
                      width: 40,
                      height: 40,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), //spacer
//                                                         pH
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
                      widget.getData!.calibrationPH.toStringAsFixed(1),
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
                        sliderValue = widget.getData!.calibrationPH.toDouble();
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
                                            sliderValue = sliderValue.clamp(6.5, 8.5);
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
                                          min: 6.5,
                                          max: 8.5,
                                          divisions: 1000,
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
                                            sliderValue = sliderValue.clamp(6.5, 8.5);
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          calibrationUpdate();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
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
//                                                      Consigne
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.arrow_right,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'Consigne',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      widget.getData!.consignePH.toStringAsFixed(1),
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
                        sliderValue = widget.getData!.consignePH.toDouble();
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
                                    'Consigne',
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
                                            sliderValue = sliderValue.clamp(6.2, 8.2);
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
                                          min: 6.2,
                                          max: 8.2,
                                          divisions: 1000,
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
                                            sliderValue = sliderValue.clamp(6.2, 8.2);
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          consigneUpdate();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                ],
                              );
                            });
                          });
                    }, //BottomSheet
                  ),
                ),
              ),
              const SizedBox(height: 20), //spacer
//                                                      Consigne             
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                   Seuil Alerte Bas
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.arrow_right,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'Seuil Alerte Bas',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      widget.getData!.seuilAlerteBasPH.toStringAsFixed(1),
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
                        sliderValue = widget.getData!.seuilAlerteBasPH.toDouble();
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
                                    'Seuil Alerte Bas',
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
                                            sliderValue = sliderValue.clamp(5.5, 7.0);
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
                                          min: 5.5,
                                          max: 7.0,
                                          divisions: 1000,
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
                                            sliderValue = sliderValue.clamp(5.5, 7.0);
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
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          seuilAlerteBasUpdate();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                ],
                              );
                            });
                          });
                    }, //BottomSheet
                  ),
                ),
              ),
              const SizedBox(height: 20), //spacer
//                                                   Seuil Alerte Bas
//------------------------------------------------------------------------------------------------------------------------------------------              
//                                                   Seuil Alerte Haut
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.6,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.arrow_right,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'Seuil Alerte Haut',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      widget.getData!.seuilAlerteHautPH.toStringAsFixed(1),
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
                        sliderValue = widget.getData!.seuilAlerteHautPH.toDouble();
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
                                    'Seuil Alerte Haut',
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
                                            sliderValue = sliderValue.clamp(7.0, 9.5);
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
                                          min: 7.0,
                                          max: 9.5,
                                          divisions: 1000,
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
                                            sliderValue = sliderValue.clamp(7.0, 9.5);
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
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider".toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        onPressed: () {
                                          seuilAlerteHautUpdate();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                ],
                              );
                            });
                          });
                    }, //BottomSheet
                  ),
                ),
              ),
//                                                   Seuil Alerte Haut
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

  Future<void> phUpdate() async {
    final calibrationRef = widget.database.child('root/${widget.uid}/appareil1/pH/');
    try {
      double calibrationValue = sliderValue;
      calibrationValue = double.parse(calibrationValue.toStringAsFixed(1));

      await calibrationRef.update({
        'pH': calibrationValue,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$calibrationValue");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> calibrationUpdate() async {
    final calibrationRef = widget.database.child('root/${widget.uid}/appareil1/pH/');
    try {
      double calibrationValue = sliderValue;
      calibrationValue = double.parse(calibrationValue.toStringAsFixed(1));

      await calibrationRef.update({
        'calibrationPH': calibrationValue,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$calibrationValue");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> consigneUpdate() async {
    final calibrationRef = widget.database.child('root/${widget.uid}/appareil1/pH/');
    try {
      double calibrationValue = sliderValue;
      calibrationValue = double.parse(calibrationValue.toStringAsFixed(1));

      await calibrationRef.update({
        'consignePH': calibrationValue,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$calibrationValue");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> seuilAlerteBasUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/pH/');
    try {
      double value = sliderValue;
      value = double.parse(value.toStringAsFixed(1));

      await databaseRef.update({
        'seuilAlerteBasPH': value,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$value");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> seuilAlerteHautUpdate() async {
    final databaseRef = widget.database.child('root/${widget.uid}/appareil1/pH/');
    try {
      double value = sliderValue;
      value = double.parse(value.toStringAsFixed(1));

      await databaseRef.update({
        'seuilAlerteHautPH': value,
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
