import 'package:flutter_blue/flutter_blue.dart';

class PT280 {
  //Serviços
  static const String atBrincoService = "0003cdd0-0000-1000-8000-00805f9b0131";
  //Characteristcs
  static const String atBrincoCharacteristic =
      "0003cdd1-0000-1000-8000-00805f9b0131";
  //Guid serviços
  static final Guid uuidBrincoService = Guid(atBrincoService);
  //Guid characteristics
  static final Guid uuidPesoCharacteristic = Guid(atBrincoCharacteristic);
}
