import 'package:flutter/foundation.dart';

class Funcoes {
  ///Print debug
  static void printD(Object s) {
    if (kDebugMode) {
      print(s);
    }
  }

  static String decodeFdxb(String fdxb) {
    //https://www.priority1design.com.au/fdx-b_animal_identification_protocol.html
    var bin = '';
    for (int i = 0; i < fdxb.length; i++) {
      bin += int.parse(fdxb[i], radix: 16).toRadixString(2).padLeft(4, '0');
    }

    // bin.substring(0, 7);
    // bin.substring(8, 15);
    // bin.substring(16, 23);
    // bin.substring(24, 31);

    var nId = bin.substring(34, 40);

    for (var i = 3; i >= 0; i--) {
      nId += bin.substring(i * 8, i * 8 + 8);
      printD(bin.substring(i * 8, i * 8 + 8));
    }

    final nCountry = bin.substring(40, 48) + bin.substring(32, 34);
    final country = int.parse(nCountry, radix: 2).toRadixString(10);
    final id = int.parse(nId, radix: 2).toRadixString(10).padLeft(12, '0');

    final idNumerico = country + id;

    return idNumerico;
  }
}
