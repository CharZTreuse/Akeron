import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

//Pages
import 'package:realtime/methods/loading_page.dart';
import 'package:realtime/pages/ph_page.dart';
import 'package:realtime/pages/rx_page.dart';
import 'package:realtime/pages/salt_page.dart';
import 'package:realtime/pages/temperature_page.dart';
import 'package:realtime/methods/esp32_class.dart';

class ReadExample extends StatefulWidget {
  const ReadExample({Key? key}) : super(key: key);

  @override
  ReadExampleState createState() => ReadExampleState();
}

class ReadExampleState extends State<ReadExample> {
  Esp32? esp32Data;
  final database = FirebaseDatabase.instance.ref();
  late StreamSubscription _esp32Stream;
  int _currentIndex = 0;
  String appBarTitle = 'Menu';
  late final String uid;

  // Méthode pour changer de page
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        appBarTitle = 'Menu';
      } else if (_currentIndex == 1) {
        appBarTitle = 'Auxiliaire';
      }
    });
  }

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
            esp32Data = displayESP32;
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

//------------------------------------------------------ Réseaux sociaux ----------------------------------------------------------------------
  final Uri linkedinURL = Uri.parse('https://www.linkedin.com/company/corelec-akeron/');
  final Uri facebookURL = Uri.parse('https://www.facebook.com/akeronofficiel');
  final Uri akeronURL = Uri.parse('https://www.akeron.fr/');
  final Uri youtubeURL = Uri.parse('https://www.youtube.com/channel/UCnE3Jz8v4VoWZ1kqbj5bzCg');
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
//------------------------------------------------------ Réseaux sociaux ------------------------------------------------------------------------------

//--------------------------------------------------------- Affichage ---------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue[900],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Auxiliaires',
          ),
        ],
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
                  if (_currentIndex == 0) {
                    if (constraints.maxWidth >= 480) {
                      // Taille minimale pour afficher les Card en taille fixe
                      return MenuSection(
                        esp32Data: esp32Data,
                        isResponsive: constraints.maxWidth <= 1000,
                        onLaunchLinkedinURL: launchLinkedinURL,
                        onLaunchAkeronURL: launchAkeronURL, 
                        onLaunchYoutubeURL: launchYoutubeURL, 
                        onLaunchFacebookURL: launchFacebookURL,
                        uid: uid,
                      );
                    } else {
                      // Affichage adaptatif pour les écrans plus petits
                      return MenuSection(
                        esp32Data: esp32Data,
                        isResponsive: true, 
                        onLaunchLinkedinURL: launchLinkedinURL,
                        onLaunchAkeronURL: launchAkeronURL, 
                        onLaunchYoutubeURL: launchYoutubeURL, 
                        onLaunchFacebookURL: launchFacebookURL,
                        uid: uid,
                      );
                    }
                  } else {
                    return AuxiliaireSection(
                      onLaunchLinkedinURL: launchLinkedinURL, 
                      onLaunchAkeronURL: launchAkeronURL, 
                      onLaunchYoutubeURL: launchYoutubeURL,
                      onLaunchFacebookURL: launchFacebookURL,
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//--------------------------------------------------------- Affichage ---------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                       Section Menu                                                                     --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------
// ignore: must_be_immutable
class MenuSection extends StatefulWidget {
  final Esp32? esp32Data;
  final database = FirebaseDatabase.instance.ref();
  final bool isResponsive;
  final VoidCallback onLaunchLinkedinURL;
  final VoidCallback onLaunchAkeronURL;
  final VoidCallback onLaunchYoutubeURL;
  final VoidCallback onLaunchFacebookURL;
  final String uid;
  final textField = TextEditingController();

  MenuSection({Key? key, this.esp32Data, required this.isResponsive, required this.onLaunchLinkedinURL, required this.onLaunchAkeronURL, required this.onLaunchYoutubeURL, required this.onLaunchFacebookURL, required this.uid})
      : super(key: key);

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

//State
class _MenuSectionState extends State<MenuSection> {
  double sliderValue = 5.0;
  FocusNode textFieldFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    super.dispose();
  }

//productionUpdate
  Future<void> productionUpdate() async {
    final productionRef = widget.database.child('root/${widget.uid}/appareil1/production/');
    try {
      double productionValue;
      if (widget.textField.text.isNotEmpty) {
        // Utilise la valeur du textField si elle est non vide
        productionValue = double.parse(widget.textField.text.trim());
      } else {
        // Utilise la valeur du slider
        productionValue = sliderValue;
      }
      // Arrondit la valeur à un seul chiffre après la virgule
      productionValue = double.parse(productionValue.toStringAsFixed(1));

      await productionRef.update({
        'production': productionValue,
      });
      debugPrint("Ecriture réussie!");
      debugPrint("$productionValue");
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.esp32Data != null) {
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
            children: [
//--------------------------------------------------------------------------------------------------------------------------------------------
//                                                      Production
              const Text(
                "Production",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              InkWell(
                child: Stack(
                children: [
                  Image.asset(
                    'assets/images/mesure_circle.png',
                    width: 500,
                    height: 500,
                    
                  ),
/*Pourcentage*/   Positioned(
/*Production*/      top: 210, // Position verticale 
                    left: 210, // Position horizontale
                    child: Text(
                      '${widget.esp32Data!.production.toStringAsFixed(0)}%', //Pourcentage de production
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 300, // Position verticale 
                    left: 220, // Position horizontale
                    child: Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 60,
                    ),
                  ),
                ],
              ),
//BottomSheet              
                onTap: () {
                  setState(() {
                        sliderValue =
                            widget.esp32Data!.production.toDouble();
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
                                    'Production',
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    sliderValue.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: widget.isResponsive ? 24 : 28,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 20), //spacers
                                  Row(
                                    children: [
                                      const SizedBox(width: 20), //spacers
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            sliderValue -= 5;
                                            sliderValue = sliderValue.clamp(5.0, 100.0);
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
                                          min: 5,
                                          max: 100,
                                          divisions: (100.0 - 5.0) ~/ 5,
                                          label:
                                              sliderValue.round().toStringAsFixed(0),
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
                                            sliderValue += 5;
                                            sliderValue = sliderValue.clamp(5.0, 100.0);
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
                                      const SizedBox(width: 20), //spacers
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
                                          backgroundColor: Colors.green,
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
                                          productionUpdate();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20), //spacer
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

//                                                      Production
//------------------------------------------------------------------------------------------------------------------------------------------- 
//                                                         RX
              FractionallySizedBox(
                widthFactor: widget.isResponsive
                    ? 1.0
                    : 0.5,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.water_drop_outlined,
                      color: Colors.blue[900],
                      size: 40,
                    ),
                    title: Text(
                      'RX',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                          child: Text(
                            '${widget.esp32Data!.rx} mV',
                            style: TextStyle(
                              fontSize: widget.isResponsive ? 20 : 24,
                              color: Colors.blue[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                size: 30,
                                color: Colors.black,
                              ),
                              Text(
                                '${widget.esp32Data!.consigneRX} mV',
                                style: TextStyle(
                                  fontSize: widget.isResponsive ? 18 : 22,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),      
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoadingPage(nextPage: RxPage())),
                      );
                    },
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (widget.esp32Data!.rx > widget.esp32Data!.seuilAlerteRX)
                            Image.asset(
                              'assets/images/green_circle.png',
                              width: 40,
                              height: 40,
                            )
                          else
                            Image.asset(
                              'assets/images/orange_circle.png',
                              width: 40,
                              height: 40,
                            ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.more_vert,
                            color: Colors.blue[900],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), //spacer

//                                                         RX
//------------------------------------------------------------------------------------------------------------------------------------------- 
//                                                         pH
              FractionallySizedBox(
                widthFactor: widget.isResponsive
                    ? 1.0
                    : 0.5,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Image.asset(
                      'assets/images/logo_ph.png',
                      width: 40,
                      height: 40,
                      color: Colors.blue[900],
                    ),
                    title: Text(
                      'pH',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                          child: Text(
                            '${widget.esp32Data!.pH}',
                            style: TextStyle(
                              fontSize: widget.isResponsive ? 20 : 24,
                              color: Colors.blue[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                size: 30,
                                color: Colors.black,
                              ),
                              Text(
                                '${widget.esp32Data!.consignePH}',
                                style: TextStyle(
                                  fontSize: widget.isResponsive ? 18 : 22,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),         
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoadingPage(nextPage: PhPage())),
                      );
                    },
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (widget.esp32Data!.pH <= widget.esp32Data!.seuilAlerteBasPH)
                            Image.asset(
                              'assets/images/orange_circle.png',
                              width: 40,
                              height: 40,
                            )
                          else if (widget.esp32Data!.pH >= widget.esp32Data!.seuilAlerteHautPH)
                            Image.asset(
                              'assets/images/orange_circle.png',
                              width: 40,
                              height: 40,
                            )
                          else
                            Image.asset(
                              'assets/images/green_circle.png',
                              width: 40,
                              height: 40,
                            ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.more_vert,
                            color: Colors.blue[900],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), //Spacer

//                                                         pH
//------------------------------------------------------------------------------------------------------------------------------------------- 
//                                                        Salt
              FractionallySizedBox(
                widthFactor: widget.isResponsive
                    ? 1.0
                    : 0.5,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.grain,
                      color: Colors.blue[900],
                      size: 40,
                    ),
                    title: Text(
                      'Sel',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          '${widget.esp32Data!.salt} g/L',
                          style: TextStyle(
                            fontSize: widget.isResponsive ? 20 : 24,
                            color: Colors.blue[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoadingPage(nextPage: SaltPage())),
                      );
                    },
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (widget.esp32Data!.salt > widget.esp32Data!.seuilAlerteSalt)
                            Image.asset(
                              'assets/images/green_circle.png',
                              width: 40,
                              height: 40,
                            )
                          else
                            Image.asset(
                              'assets/images/orange_circle.png',
                              width: 40,
                              height: 40,
                            ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.more_vert,
                            color: Colors.blue[900],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), //spacer

//                                                        Salt
//------------------------------------------------------------------------------------------------------------------------------------------- 
//                                                     Temperature
              FractionallySizedBox(
                widthFactor: widget.isResponsive ? 1.0 : 0.5,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    leading: Icon(
                      Icons.thermostat,
                      color: Colors.blue[900],
                      size: 40,
                    ),
                    title: Text(
                      'Temperature',
                      style: TextStyle(
                        fontSize: widget.isResponsive ? 20 : 24,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          '${widget.esp32Data!.temperature} °C',
                          style: TextStyle(
                            fontSize: widget.isResponsive ? 20 : 24,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LoadingPage(nextPage: TemperaturePage()),
                        ),
                      );
                    },
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (widget.esp32Data!.temperature > widget.esp32Data!.seuilAlerteTemperature)
                            Image.asset(
                              'assets/images/green_circle.png',
                              width: 40,
                              height: 40,
                            )
                          else
                            Image.asset(
                              'assets/images/orange_circle.png',
                              width: 40,
                              height: 40,
                            ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.more_vert,
                            color: Colors.blue[900],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
//                                                       Temperature
//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                    Réseaux sociaux                                                                     --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      widget.onLaunchAkeronURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_akeron.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchFacebookURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_facebook.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchLinkedinURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_linkedin.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchYoutubeURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_ytb.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const LoadingPage(
        nextPage: ReadExample(),
      );
    }
  }
}
//                                                     Réseaux sociaux
//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                    Section Auxiliaire                                                                  --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------

class AuxiliaireSection extends StatefulWidget {
  const AuxiliaireSection({super.key, required this.onLaunchLinkedinURL, required this.onLaunchAkeronURL, required this.onLaunchYoutubeURL, required this.onLaunchFacebookURL});

  final VoidCallback onLaunchLinkedinURL;
  final VoidCallback onLaunchAkeronURL;
  final VoidCallback onLaunchYoutubeURL;
  final VoidCallback onLaunchFacebookURL;

  @override
  State<AuxiliaireSection> createState() => _AuxiliaireSectionState();
}

class _AuxiliaireSectionState extends State<AuxiliaireSection> {
  String filtration = "Off";
  String spot = "Off";
  String selectedValues = '';
  String selectedValuesTwo = '';
  int maxSelectionCount = 2;
  int selectedCountOne = 0;
  int selectedCountTwo = 0;
  List<bool> checkboxStates = [];
  List<bool> checkboxStatesTwo = [];
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

  @override
  void initState() {
    super.initState();
    checkboxStates = List<bool>.filled(listePlageHoraire.length, false);
    checkboxStatesTwo = List<bool>.filled(listePlageHoraire.length, false);
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

  void updateSelectedValuesTwo() {
    List<String> selectedItemsTwo = [];
    for (int i = 0; i < checkboxStatesTwo.length; i++) {
      if (checkboxStatesTwo[i]) {
        selectedItemsTwo.add(listePlageHoraire[i]);
      }
    }
    setState(() {
      selectedValuesTwo = selectedItemsTwo.join(' - ');
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

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          //Filtration
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
                                        const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
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
                                    220), // Ajustez la valeur pour décaler le texte vers la gauche
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

          const SizedBox(height: 40), //Spacer

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
                    Container(
                      height: 150,
                      width: 380,
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Minuteur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                                //mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 20), //spacer
//------------------------------------------------------------------------------------------------------------------------------------------
//                                                                                                                                        --
//                                                    Réseaux sociaux                                                                     --
//                                                                                                                                        --
//------------------------------------------------------------------------------------------------------------------------------------------
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      widget.onLaunchAkeronURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_akeron.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchFacebookURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_facebook.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchLinkedinURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_linkedin.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60), //spacer
                  InkWell(
                    onTap: () {
                      widget.onLaunchYoutubeURL();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 214, 211, 211),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_ytb.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

