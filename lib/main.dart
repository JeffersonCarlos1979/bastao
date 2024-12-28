import 'dart:async';
import 'dart:io';

import 'package:bastao/constantes/wtbt.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'auxiliar/alerta.dart';
import 'auxiliar/funcoes.dart';
import 'modelo/permissao.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Teste com bastão de leitura PT280'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isScannig = false;
  bool encontrouDevice = false;
  int maxRssi = -1000;

  BluetoothDevice? _device;

  bool _manterConectado = true;

  BluetoothCharacteristic? _brincoCharacteristic;

  var _posicao = 0;

  final _buffer = List.filled(255, 0);
  late List<int> _data = [];

  String _brinco = '';
  bool _conectado = false;

  String _pacote = '';

  TipoBastao tipoBastao = TipoBastao.pt280;

  @override
  void initState() {
    _iniciarConexao();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //int n = 991005004369272;
    //Funcoes.decodeFdxb('899D482AC1F70080000000');
    //print(int.parse('0011', radix: 2).toRadixString(10));

    final cor = _conectado ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.barcode_reader,
                  color: cor,
                  size: 40,
                ),
                const Padding(padding: EdgeInsets.only(right: 20)),
                Text(
                  _conectado ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 30,
                    color: cor,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 30,
              ),
            ),
            Text(
              'Ultima leitura:  ${DateFormat.Hm().format(DateTime.now())}',
            ),
            Text(
              _pacote,
            ),
            Text(
              _brinco,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _iniciarConexao,
      //   tooltip: 'Iniciar',
      //   child: const Icon(Icons.play_arrow),
      // ),
    );
  }

  Future _procurarPlataformas() async {
    if (_isScannig) return;

    if (kDebugMode) {
      print("inicio _procurarPlataformas()");
    }

    StreamSubscription<List<ScanResult>>? subscription;
    encontrouDevice = false;
    maxRssi = -1000;

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 3))
        .then((value) async {
      //print('Terminei scan');
      _isScannig = false;
      subscription?.cancel();

      if (!encontrouDevice) {
        Future.delayed(const Duration(seconds: 4)).then((value) {
          _procurarPlataformas();
        });
      }
    }).onError((error, stackTrace) {
      Future.delayed(const Duration(seconds: 4)).then((value) {
        _procurarPlataformas();
      });
    });

    _isScannig = true;

    subscription = FlutterBluePlus.scanResults.listen((results) {
      if (kDebugMode) {
        Funcoes.printD('wtapp:---Encontrei ${results.length} dispositivos---');
      }
      for (ScanResult r in results) {
        if (kDebugMode) {
          Funcoes.printD('wtapp: dispositivo:${r.device.platformName}---');
        }
        for (var serviceUuid in r.advertisementData.serviceUuids) {
          if (kDebugMode) {
            Funcoes.printD(
                'wtapp:---ServiceUuid: ${serviceUuid.toString().toUpperCase()}---');
          }
          var uuId = serviceUuid.toString().toUpperCase().split('-');

          var encontrado = false;
          if (uuId.isNotEmpty) {
            if (uuId[0].endsWith(BastaoPt280.atBrincoServiceCurto)) {
              tipoBastao = TipoBastao.pt280;
              encontrado = true;
            } else if (uuId[0].endsWith(BastaoTruTest.atBrincoServiceCurto)) {
              tipoBastao = TipoBastao.truTest;
              encontrado = true;
            }
          }

          if (encontrado) {
            if (kDebugMode) {
              Funcoes.printD(
                  'wtapp:Encontrei o bastão: ${r.device.platformName}');
            }

            _device = r.device;

            FlutterBluePlus.stopScan;
            if (!encontrouDevice) {
              encontrouDevice = true;
              _conectar();
            }
            break;
          }
        }

        if (r.rssi > maxRssi) {
          maxRssi = r.rssi;
          //_device = r.device;
          //_tratarPeso.tipoIndicador = tipoIndicador;
        }
      }
    });
    Funcoes.printD("fim _procurarPlataformas()");
  }

  Future<bool> _conectar() async {
    Funcoes.printD("_conectar()");

    if (_device == null) {
      return false;
    }

    _manterConectado = true;
    try {
      await _device!.connect(
        autoConnect: false,
      );
      Funcoes.printD("_conectar() conectou");
      setState(() {
        _conectado = true;
      });
    } catch (e) {
      //isAtivado = false;
      Funcoes.printD("_conectar() não conectou");
      return false;
    }

    await _localizarServicos();
    await abrirNotificacoes();

    _brincoCharacteristic?.lastValueStream.listen((data) {
      if (dadoCompleto(data)) {
        data = _data;
        final pacote = 'Pacote: ${String.fromCharCodes(data, 0)}';
        if (_data.length == 25 || _data.length == 24) {
          /*
          25 bytes--> FDXB-S=
          24 bytes--> HDX-S=
          */
          var brinco =
              String.fromCharCodes(data, _data.length - 17, _data.length - 2);

          setState(() {
            _brinco = brinco;
            _pacote = pacote;
          });
        } else if (_data.length == 30 || _data.length == 29) {
          /*
          30 bytes--> FDXB=789D482AC1F70080000000
          29 bytes--> HDX=
          */
          Funcoes.printD(String.fromCharCodes(data, 0));
          final fdxb =
              String.fromCharCodes(data, _data.length - 24, _data.length - 2);
          var brinco = Funcoes.decodeFdxb(fdxb);
          setState(() {
            _brinco = brinco;
            _pacote = pacote;
          });
        } else {
          setState(() {
            _pacote = pacote;
          });
        }
      }
    });

    _device?.connectionState.listen((event) {
      if (event == BluetoothConnectionState.connected) {
        if (kDebugMode) {
          print('wtapp:---Conectou, vou abrir notificações---');
        }
        setState(() {
          _conectado = true;
        });
        abrirNotificacoes();
      } else if (event == BluetoothConnectionState.disconnected) {
        setState(() {
          _conectado = false;
        });
        Funcoes.printD('Desconectou');
        _device?.disconnect();
        if (_manterConectado) {
          Funcoes.printD('---Chamei procurarPlataformas()');
          _procurarPlataformas();
        }
      }

      Funcoes.printD("_conectar() fim");
    });

    return true;
  }

  bool dadoCompleto(List<int> data) {
    bool completo = false;

    for (var b in data) {
      if (_posicao >= _buffer.length) _posicao = 0;
      _buffer[_posicao++] = b;

      if (_posicao > 1) {
        if ((_buffer[_posicao - 2]) == 13 && (_buffer[_posicao - 1]) == 10) {
          completo = true;
          _data = _buffer.sublist(0, _posicao);
          _posicao = 0;
        }
      }
    }

    return completo;
  }

  Future<void> _localizarServicos() async {
    if (_device == null) {
      return;
    }
    Guid uuidBrincoService = BastaoPt280.uuidBrincoService;
    Guid uuidBrincoCharacteristic = BastaoPt280.uuidPesoCharacteristic;

    switch (tipoBastao) {
      case TipoBastao.pt280:
        uuidBrincoService = BastaoPt280.uuidBrincoService;
        uuidBrincoCharacteristic = BastaoPt280.uuidPesoCharacteristic;
        break;
      case TipoBastao.truTest:
        uuidBrincoService = BastaoTruTest.uuidBrincoService;
        uuidBrincoCharacteristic = BastaoTruTest.uuidPesoCharacteristic;
        break;
    }

    List<BluetoothService> services = await _device!.discoverServices();

    for (var service in services) {
      if (service.uuid == uuidBrincoService) {
        // Reads all characteristics
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid == uuidBrincoCharacteristic) {
            _brincoCharacteristic = c;
            break;
          }
        }
      }
    }
  }

  Future<void> abrirNotificacoes() async {
    try {
      await _brincoCharacteristic?.setNotifyValue(true);
    } catch (e) {
      Funcoes.printD(e);
    }
  }

  Future<void> fecharNotificacoes() async {
    try {
      await _brincoCharacteristic?.setNotifyValue(false);
    } catch (e) {
      Funcoes.printD(e);
    }

    Funcoes.printD('---Fechei notificações---');
  }

  Future<bool> _verificarPermissoes() async {
    if (Platform.isIOS) {
      return true;
    }

    Funcoes.printD("_verificarPermissoes()");
    String? msg;
    var permissoes = [
      const Permissao(
        permission: Permission.locationWhenInUse,
        descricao: 'Localização',
      ),
    ];
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      //Se for android 12 (31), precisa solicitar as permissões abaixo

      if ((deviceInfo.version.sdkInt) >= 31) {
        permissoes.addAll([
          const Permissao(
            permission: Permission.bluetoothScan,
            descricao: 'Localizar dispositivos bluetooth',
          ),
          const Permissao(
            permission: Permission.bluetoothConnect,
            descricao: 'Conectar a dispositivos bluetooth',
          ),
        ]);
      }
    }

    var exibiuMsgPerm = false;
    for (var permissao in permissoes) {
      if (!await permissao.permission.isGranted) {
        if (!exibiuMsgPerm) {
          exibiuMsgPerm = true;
          var msgPerm = ''
              'O app precisa de permissões para localizar e conectar a '
              'um dispositivo bluetooth';

          var ok = await Alerta.exibirAlerta(
                context,
                titulo: 'Permissões para conecão bluetooth',
                mensagem: msgPerm,
                tipoBotoes: TipoBotoes.okCancel,
              ) ??
              false;

          if (!ok) {
            //_msgStatusNotifier.value = 'Permitir conexão com a plataforma';
            return false;
          }
        }

        var permissionStatus = await permissao.permission.request();

        if (permissionStatus.isPermanentlyDenied) {
          msg = ''
              'A permissão ${permissao.descricao} foi negada permanentemente.\n'
              'Ela é nescessária para a conexão com o módulo de pesagem\n'
              'Essa permissão precisa ser habilitada nas configurações.';
          //await openAppSettings();
        } else if (permissionStatus.isRestricted) {
          msg = ''
              'A permissão ${permissao.descricao} está restrita.\n'
              'Ela é nescessária para a conexão com o módulo de pesagem\n'
              'Essa permissão precisa ser habilitada nas configurações.';
        }

        if (msg != null) {
          var ok = await Alerta.exibirAlerta(
                context,
                titulo: 'Permissões para conexão Bluetooth',
                mensagem: msg,
                tipoBotoes: TipoBotoes.okCancel,
              ) ??
              false;

          if (ok) {
            openAppSettings();
          }
        }

        if (!permissionStatus.isGranted) {
          //_msgStatusNotifier.value = 'Permitir conexão com a plataforma';
          return false;
        }
      }
    }

    Funcoes.printD("_verificarPermissoes() GeoLocator");
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      msg = ''
          'Para que o applicativo possa encontrar e se conectar a plataforma, '
          'por favor ative o serviço de localização do seu dispositivo (GPS).';

      var ok = await Alerta.exibirAlerta(
            context,
            titulo: 'Serviço de localização desativado',
            mensagem: msg,
            tipoBotoes: TipoBotoes.okCancel,
          ) ??
          false;

      if (ok) {
        await Geolocator.openLocationSettings();
      }
    }

    if (msg != null) {
      //_msgStatusNotifier.value = 'Permitir conexão com a plataforma';
    } else {
      //_msgStatusNotifier.value = AGUARDANDO_CONEXAO;
    }
    Funcoes.printD("_verificarPermissoes() fim");
    return true;
  }

  Future _iniciarConexao() async {
    if (await _verificarPermissoes()) {
      _procurarPlataformas();
    }
  }
}
