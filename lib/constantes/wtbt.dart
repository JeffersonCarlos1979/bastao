import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum TipoIndicador {
  wt3000Ir,
  wt3000IPro,
  wTBtBr,
}

enum TipoBastao {
  pt280,
  truTest,
}

class NomeIndicador {
  static String wTBtBr = "WT-BT-BR";
  static String wt3000IPro = "WT3k I-PRO";
  static String wt3000Ir = "EXCEL-C2";
}

class WtbtBr {
  static String teste = "teste";
  //Serviços
  static String clientCharacteristicConfig =
      "00002902-0000-1000-8000-00805F9B34FB";
  static const String atWtBtService = "0000181D-0000-1000-8000-00805F9B34FB";
  static const String aTDeviceInformationService =
      "0000180A-0000-1000-8000-00805F9B34FB";
  //Characteristcs
  static const String atCharComando = "00002B26-0000-1000-8000-00805F9B34FB";
  static const String atCharStatus = "00002b21-0000-1000-8000-00805F9B34FB";
  static const String atCharPeso = "00002A98-0000-1000-8000-00805F9B34FB";
  static const String atCharSoftwareRevision =
      "00002A28-0000-1000-8000-00805F9B34FB";
  //Guid serviços
  static final Guid uuidWtbtService = Guid(atWtBtService);
  static final Guid uuidDeviceInformationService =
      Guid(aTDeviceInformationService);
  //Guid characteristics
  static final Guid uuidCharComando = Guid(atCharComando);
  static final Guid uuidCharStatus = Guid(atCharStatus);
  static final Guid uuidCharPeso = Guid(atCharPeso);
  static final Guid uuidCharSoftwareRevision = Guid(atCharSoftwareRevision);
  //Bateria
  static const int bateriaSemStatus = -1;
  static const int bateria25 = 0;
  static const int bateria50 = 1;
  static const int bateria75 = 2;
  static const int bateria100 = 3;

  static const int bluetooth = 3;
}

class Wt3kIR {
  //Serviços
  static const String atPesoService = "0000E711-0000-1000-8000-00805f9b34fb";
  //Characteristcs
  static const String atePesoCharacteristic =
      "0000E813-0000-1000-8000-00805f9b34fb";
  //Guid serviços
  static final Guid uuidPesoService = Guid(atPesoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atePesoCharacteristic);
}

class Wt3kPRO {
  //Serviços
  static const String atPesoService = "0000FFE0-0000-1000-8000-00805f9b34fb";
  //Characteristcs
  static const String atPesoCharacteristic =
      "0000FFE1-0000-1000-8000-00805f9b34fb";
  //Guid serviços
  static final Guid uuidPesoService = Guid(atPesoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atPesoCharacteristic);
}

class BastaoPt280 {
  //Serviços
  static const String atBrincoService = "0003cdd0-0000-1000-8000-00805f9b0131";
  static const String atBrincoServiceCurto = "3CDD0";
  //Characteristcs
  static const String atBrincoCharacteristic =
      "0003cdd1-0000-1000-8000-00805f9b0131";
  //Guid serviços
  static final Guid uuidBrincoService = Guid(atBrincoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atBrincoCharacteristic);
}

class BastaoTruTest {
/*
Scan for BLE devices, check their Complete Local Name and Service Class UUIDs to
check that they match those described above (XRP2i + last four digit of serial number
and 6E400001-B5A3-F393-E0A9-E50E24DCCA9E)
- Connect to the device
- Negotiate MTU with the highest value supported by phone (this should happen
automatically on iOS devices, it must be explicitly required by the app on Android)
- Retrieve service with ID 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
- Retrieve characteristic 6E400002-B5A3-F393-E0A9-E50E24DCCA9E that will be used
to write data sent to the device. You can use write or write without response operations
to write as many bytes as the negotiated MTU per each write operation.
- Retrive characteristic 6E400003-B5A3-F393-E0A9-E50E24DCCA9E and activate
notifications on it, it will be used to receive data from the device
*/

  //Serviços
  static const String atBrincoService = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String atBrincoServiceCurto = "6E400001";
  //TX
  static const String atTxCharacteristic =
      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  //RX
  static const String atBrincoCharacteristic =
      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  //Guid serviços
  static final Guid uuidBrincoService = Guid(atBrincoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atBrincoCharacteristic);
}
