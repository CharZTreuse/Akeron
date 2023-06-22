class Esp32 {
  //Sel
  final num salt;
  final num calibrationSalt;
  final num seuilAlerteSalt;
  //Température
  final num temperature;
  final num calibrationTemperature;
  final num mesureTemperature;
  final num seuilAlerteTemperature;
  //REDOX
  final num rx;
  final num calibrationRX;
  final num seuilAlerteRX;
  final num consigneRX;
  //pH
  final num pH;
  final num calibrationPH;
  final num consignePH;
  final num seuilAlerteBasPH;
  final num seuilAlerteHautPH;
  //Autres
  final num alarme1;
  final num alarme2;
  final num production;

  Esp32({
    //Sel
    required this.salt,
    required this.calibrationSalt,
    required this.seuilAlerteSalt,
    //Température
    required this.temperature,
    required this.calibrationTemperature,
    required this.mesureTemperature,
    required this.seuilAlerteTemperature,
    //REDOX
    required this.rx,
    required this.calibrationRX,
    required this.seuilAlerteRX,
    required this.consigneRX,
    //pH
    required this.pH,
    required this.calibrationPH,
    required this.consignePH,
    required this.seuilAlerteBasPH,
    required this.seuilAlerteHautPH,
    //Autres
    required this.alarme1,
    required this.alarme2,
    required this.production,
  });    

  factory Esp32.fromRTDB(Map<String, dynamic> data) {
    return Esp32(
      //Température
      temperature: _parseNum(data['temperature']?['temperature']),
      calibrationTemperature: _parseNum(data['temperature']?['calibrationTemperature']),
      mesureTemperature: _parseNum(data['temperature']?['mesureTemperature']),
      seuilAlerteTemperature: _parseNum(data['temperature']?['seuilAlerteTemperature']),
      //Sel
      salt: _parseNum(data['salt']?['salt']),
      calibrationSalt: _parseNum(data['salt']?['calibrationSalt']),
      seuilAlerteSalt: _parseNum(data['salt']?['seuilAlerteSalt']),
      //REDOX
      rx: _parseNum(data['RX']?['RX']),
      calibrationRX: _parseNum(data['RX']?['calibrationRX']),
      seuilAlerteRX: _parseNum(data['RX']?['seuilAlerteRX']),
      consigneRX: _parseNum(data['RX']?['consigneRX']),
      //pH
      pH: _parseNum(data['pH']?['pH']),
      calibrationPH: _parseNum(data['pH']?['calibrationPH']),
      consignePH: _parseNum(data['pH']?['consignePH']),
      seuilAlerteBasPH: _parseNum(data['pH']?['seuilAlerteBasPH']),
      seuilAlerteHautPH: _parseNum(data['pH']?['seuilAlerteHautPH']),
      //Autres
      alarme1: _parseNum(data['alarmes']?['alarme1']),
      alarme2: _parseNum(data['alarmes']?['alarme2']),
      production: _parseNum(data['production']?['production']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    } else if (value is String) {
      return num.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }
}