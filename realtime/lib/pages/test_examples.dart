import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:realtime/methods/esp32_class.dart';
import 'package:url_launcher/url_launcher.dart';

extension IterableExtensions<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E element, int index) f) {
    var currentIndex = 0;
    return map((element) => f(element, currentIndex++));
  }
}

class DataExample extends StatefulWidget {
  const DataExample({Key? key}) : super(key: key);

  @override
  DataExampleState createState() => DataExampleState();
}

class DataExampleState extends State<DataExample> {
  Esp32? esp32Data;
  final database = FirebaseDatabase.instance.ref();
  late StreamSubscription _esp32Stream;
  String filtration = "Off";
  String spot = "Off";
  String selectedValues = '';
  String selectedValuesTwo = '';
  String selectedValuesMinuteur = '';
  int maxSelectionCount = 2;
  int maxSelectionCountMinuteur = 1;
  int selectedCountOne = 0;
  int selectedCountMinuteur = 0;
  int selectedCountTwo = 0;
  List<bool> checkboxStates = [];
  List<bool> checkboxStatesMinuteur = [];
  List<bool> checkboxStatesTwo = [];
    List<String> listeMinuteur = [
    '00h15',
    '00h30',
    '00h45',
    '01h00', //01h
    '01h15',
    '01h30',
    '01h45',
    '02h00', //02h
    '02h15',
    '02h30',
    '02h45',
    '03h00', //03h
    '03h15',
    '03h30',
    '03h45',
    '04h00', //04h
    '04h15',
    '04h30',
    '04h45',
    '05h00', //05h
    '05h15',
    '05h30',
    '05h45',
    '06h00', //06h
    '06h15',
    '06h30',
    '06h45',
    '07h00', //07h
    '07h15',
    '07h30',
    '07h45',
    '08h00', //08h
  ];
  List<String> listePlageHoraire = [
    '00h00', //24h
    '00h15',
    '00h30',
    '00h45',
    '01h00', //01h
    '01h15',
    '01h30',
    '01h45',
    '02h00', //02h
    '02h15',
    '02h30',
    '02h45',
    '03h00', //03h
    '03h15',
    '03h30',
    '03h45',
    '04h00', //04h
    '04h15',
    '04h30',
    '04h45',
    '05h00', //05h
    '05h15',
    '05h30',
    '05h45',
    '06h00', //06h
    '06h15',
    '06h30',
    '06h45',
    '07h00', //07h
    '07h15',
    '07h30',
    '07h45',
    '08h00', //08h
    '08h15',
    '08h30',
    '08h45',
    '09h00', //09h
    '09h15',
    '09h30',
    '09h45',
    '10h00', //10h
    '10h15',
    '10h30',
    '10h45',
    '11h00', //11h
    '11h15',
    '11h30',
    '11h45',
    '12h00', //12h
    '12h15',
    '12h30',
    '12h45',
    '13h00', //13h
    '13h15',
    '13h30',
    '13h45',
    '14h00', //14h
    '14h15',
    '14h30',
    '14h45',
    '15h00', //15h
    '15h15',
    '15h30',
    '15h45',
    '16h00', //16h
    '16h15',
    '16h30',
    '16h45',
    '17h00', //17h
    '17h15',
    '17h30',
    '17h45',
    '18h00', //18h
    '18h15',
    '18h30',
    '18h45',
    '19h00', //19h
    '19h15',
    '19h30',
    '19h45',
    '20h00', //20h
    '20h15',
    '20h30',
    '20h45',
    '21h00', //21h
    '21h15',
    '21h30',
    '21h45',
    '22h00', //22h
    '22h15',
    '22h30',
    '22h45',
    '23h00', //23h
    '23h15',
    '23h30',
    '23h45',
  ];
  final Uri linkedinURL = Uri.parse('https://www.linkedin.com/company/corelec-akeron/');
  final Uri facebookURL = Uri.parse('https://www.facebook.com/akeronofficiel');
  final Uri akeronURL = Uri.parse('https://www.akeron.fr/');
  final Uri youtubeURL = Uri.parse('https://www.youtube.com/channel/UCnE3Jz8v4VoWZ1kqbj5bzCg');

  @override
  void initState() {
    super.initState();
    checkboxStates = List<bool>.filled(listePlageHoraire.length, false);
    checkboxStatesTwo = List<bool>.filled(listePlageHoraire.length, false);
    checkboxStatesMinuteur = List<bool>.filled(listeMinuteur.length, false);
    activateListeners();
  }

  void activateListeners() {
    _esp32Stream = database.child('esp32/').onValue.listen((event) {
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
  }

  @override
  void deactivate() {
    _esp32Stream.cancel();
    super.deactivate();
  }

  void updateSelectedValues() {
    List<String> selectedItems = [];
    for (int i = 0; i < checkboxStates.length; i++) {
      if (checkboxStates[i]) {
        selectedItems.add(listePlageHoraire[i]);
      }
    }
    setState(() {
      selectedValues = selectedItems.join(' - ');
    });
  }

  void updateSelectedValuesMinuteur() {
    List<String> selectedItems = [];
    for (int i = 0; i < checkboxStatesMinuteur.length; i++) {
      if (checkboxStatesMinuteur[i]) {
        selectedItems.add(listePlageHoraire[i]);
      }
    }
  }

  void updateSelectedValuesTwo() {
    List<String> selectedItems = [];
    for (int i = 0; i < checkboxStatesTwo.length; i++) {
      if (checkboxStatesTwo[i]) {
        selectedItems.add(listePlageHoraire[i]);
      }
    }
    setState(() {
      selectedValuesTwo = selectedItems.join(' - ');
    });
  }

  Widget listTileOne(int index, StateSetter setState) {
    final bool isChecked = checkboxStates[index];
    return ListTile(
      title: Text(
        listePlageHoraire[index],
        textAlign: TextAlign.center,
      ),
      onTap: () {
        if (selectedCountOne < maxSelectionCount || isChecked == true) {
          setState(() {
            checkboxStates[index] = !isChecked;
            selectedCountOne += isChecked ? -1 : 1;
          });
        }
      },
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          if (selectedCountOne < maxSelectionCount || value == false) {
            setState(() {
              checkboxStates[index] = value!;
              selectedCountOne += value ? 1 : -1;
            });
          }
        },
      ),
    );
  }

  Widget listTileMinuteur(int index, StateSetter setState) {
    final bool isChecked = checkboxStatesMinuteur[index];
    return ListTile(
      title: Text(
        listeMinuteur[index],
        textAlign: TextAlign.center,
      ),
      onTap: () {
        if (selectedCountMinuteur < maxSelectionCountMinuteur || isChecked == true) {
          setState(() {
            checkboxStatesMinuteur[index] = !isChecked;
            selectedCountMinuteur += isChecked ? -1 : 1;
          });
        }
      },
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          if (selectedCountMinuteur < maxSelectionCountMinuteur || value == false) {
            setState(() {
              checkboxStatesMinuteur[index] = value!;
              selectedCountMinuteur += value ? 1 : -1;
            });
          }
        },
      ),
    );
  }

    Widget listTileTwo(int index, StateSetter setState) {
    final bool isChecked = checkboxStatesTwo[index];
    return ListTile(
      title: Text(
        listePlageHoraire[index],
        textAlign: TextAlign.center,
      ),
      onTap: () {
        if (selectedCountTwo < maxSelectionCount || isChecked == true) {
          setState(() {
            checkboxStatesTwo[index] = !isChecked;
            selectedCountTwo += isChecked ? -1 : 1;
          });
        }
      },
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          if (selectedCountTwo < maxSelectionCount || value == false) {
            setState(() {
              checkboxStatesTwo[index] = value!;
              selectedCountTwo += value ? 1 : -1;
            });
          }
        },
      ),
    );
  }

  Future<void> launchLinkedinURL() async {
    if (!await( launchUrl(linkedinURL))) {
      throw Exception('Could not launch $linkedinURL');
    }
  }

  Future<void> launchAkeronURL() async {
    if (!await( launchUrl(akeronURL))) {
      throw Exception('Could not launch $akeronURL');
    }
  }

  Future<void> launchFacebookURL() async {
    if (!await( launchUrl(facebookURL))) {
      throw Exception('Could not launch $facebookURL');
    }
  }

  Future<void> launchYoutubeURL() async {
    if (!await( launchUrl(youtubeURL))) {
      throw Exception('Could not launch $youtubeURL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salle de jeu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Salle de jeu",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 80), //spacer
//-------------------------------------------------------------------------------------------------------------------------------------------
//                                                    
//                                                      Bloc de test 1
//
//------------------------------------------------------------------------------------------------------------------------------------------- 
              const Text(
                "Bloc de test 1",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20), //spacer
              const Text('Aucun test pour le moment'),

//                                                      Bloc de test 1
//-------------------------------------------------------------------------------------------------------------------------------------------
//                                                    
//                                                      Bloc de test 2
//
//------------------------------------------------------------------------------------------------------------------------------------------- 
              const SizedBox(height: 20), //spacer
              const Text(
                "Bloc de test 2",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20), //spacer
//-------------------------------------------------------------------------------------------------------------------------------------------
          //Spot
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spot',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.filter_alt,
                      size: 64,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20), //spacer
                                    const Text(
                                      'Minuteur',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20), //spacer
                                    const Text(
                                      'Veuillez saisir un minuteur',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 20), //spacer
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: listeMinuteur.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Column(
                                              children: [
                                                listTileMinuteur(index, setState),
                                                const SizedBox(height: 10),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    //Boutons Valider/Annuler
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(30)
                                              ),
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
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(30)
                                              ),
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
                                            updateSelectedValuesMinuteur();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            );
                          }
                        );
                      },
                      child: Container(
                        height: 150,
                        width: 380,
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Minuteur', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                selectedValues.isNotEmpty ? selectedValues : '00h00', //azerty
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                                children: [
                                  const SizedBox(height: 20), //spacer
                                  const Text(
                                    'Etat Spot',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        100, 20, 100, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.grey[200],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(0, 0),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(3, 0),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: const Text(
                                          'On',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, 'On');
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        100, 20, 100, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.grey[200],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(0, 0),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(3, 0),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: const Text(
                                          'Off',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, 'Off');
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        100, 20, 100, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.grey[200],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(0, 0),
                                          ),
                                          const BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(3, 0),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: const Text(
                                          'Minuteur',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, 'Minuteur');
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20), //spacer
                                  //button leave
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 15, 30, 15),
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
                                ]);
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            spot = value;
                          });
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 28),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: spot == 'Off' ? Colors.red : Colors.green,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.power_settings_new,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left:
                                    220), // Ajustez la valeur pour décaler le texte vers la gauche
                            child: Text(
                              spot,
                              style: TextStyle(
                                color: Colors.blue[900],
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
 
//                                                     Bloc de test 2
//-------------------------------------------------------------------------------------------------------------------------------------------
//                                                    
//                                                      Bloc de test 3
//
//-------------------------------------------------------------------------------------------------------------------------------------------    
              const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_alt,
                          size: 64,
                        ),
                        const Spacer(),
                        Container(
                          height: 150,
                          width: 380,
                          color: Colors.black,
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                            //BottomSheet
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                      return Column(
                                        children: [
                                          const SizedBox(height: 20), //spacer
                                          const Text(
                                            'Plages Filtration',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 20), //spacer
                                          const Text(
                                            'Veuillez saisir une heure de début et une heure de fin',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 20), //spacer
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: listePlageHoraire.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return Column(
                                                    children: [
                                                      listTileOne(index, setState),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        //Boutons Valider/Annuler
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 15, 10, 15),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                backgroundColor: Colors.green,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 15, 10, 15),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                updateSelectedValues();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ]);
                                    });
                                  }).then((value) {
                                if (value != null) {
                                  setState(() {
                                    filtration = value;
                                  });
                                }
                              });
                            },
                            //Texte Bouton
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                        'Plages Filtration',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  Text(
                                    selectedValues.isNotEmpty
                                        ? selectedValues
                                        : '00h00 - 00h00',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
//                                                        1er button
//-----------------------------------------------------------------------------------------------------------------------------------------
//                                                        2eme button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                            //BottomSheet
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                      return Column(
                                        children: [
                                          const SizedBox(height: 20), //spacer
                                          const Text(
                                            'Plages Filtration',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 20), //spacer
                                          const Text(
                                            'Veuillez saisir une heure de début et une heure de fin',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 20), //spacer
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: listePlageHoraire.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return Column(
                                                    children: [
                                                      listTileTwo(index, setState),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        //Boutons Valider/Annuler
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 15, 10, 15),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                backgroundColor: Colors.green,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 15, 10, 15),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                updateSelectedValuesTwo();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ]);
                                    });
                                  }).then((value) {
                                if (value != null) {
                                  setState(() {
                                    filtration = value;
                                  });
                                }
                              });
                            },
                            //Texte Bouton
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    selectedValuesTwo.isNotEmpty
                                        ? selectedValuesTwo
                                        : '00h00 - 00h00',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                            ],
                          )
                        ),
                        const SizedBox(width: 60),
                      ],
                    ),
//                                                Plages filtration
//-----------------------------------------------------------------------------------------------------------------------------
//                                                Test On/Off filtration
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Column(
                                      //mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20), //spacer
                                        const Text(
                                          'Mode Filtration',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              100, 20, 100, 0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[200],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(0, 0),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(3, 0),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              title: const Text(
                                                'On',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context, 'On');
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              100, 20, 100, 0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[200],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(0, 0),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(3, 0),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              title: const Text(
                                                'Off',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context, 'Off');
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              100, 20, 100, 0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[200],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(0, 0),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(3, 0),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              title: const Text(
                                                'Auto',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context, 'Auto');
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20), //spacer
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              100, 20, 100, 0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[200],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(0, 0),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.transparent,
                                                  spreadRadius: 0,
                                                  blurRadius: 0,
                                                  offset: Offset(3, 0),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              title: const Text(
                                                'Smart',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context, 'Smart');
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20), //spacer
                                        //button leave
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.fromLTRB(
                                                30, 15, 30, 15),
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
                                      ]);
                                });
                              }).then((value) {
                            if (value != null) {
                              setState(() {
                                filtration = value;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 28),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: filtration == 'Off'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left:
                                        220),
                                child: Text(
                                  filtration,
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

