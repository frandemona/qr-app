import 'dart:io';

// import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/services.dart';

class ScanPage extends StatefulWidget {
  createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  AuthService auth = AuthService();
  // ScanResult _scanResult;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  String _qrText;
  bool _alreadyUploaded = false;
  QRViewController controller;

  // final _flashOnController = TextEditingController(text: "Prender Flash");
  // final _flashOffController = TextEditingController(text: "Apagar Flash");
  // final _cancelController = TextEditingController(text: "Cancelar");

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // num _aspectTolerance = 0.00;
  // // num _numberOfCameras = 0;
  // // num _selectedCamera = -1;
  // bool _useAutoFocus = true;
  // // bool _autoEnableFlash = false;
  // bool _scanResultCorrect = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  // static final _possibleFormats = BarcodeFormat.values.toList()
  //   ..removeWhere((e) => e == BarcodeFormat.unknown);

  // List<BarcodeFormat> selectedFormats = [BarcodeFormat.qr];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();

    if (auth.getUser == null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (_) => false,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Attendee> attendees = Provider.of<List<Attendee>>(context);
    String attendeesText = '';
    if (attendees != null) {
      int menAttendeesScanned = 0;
      int womenAttendeesScanned = 0;
      int menAttendeesToScan = 0;
      int womenAttendeesToScan = 0;
      attendees.forEach((element) {
        if (!element.scanned) {
          if (element.sexo == "Masculino") menAttendeesToScan += 1;
          if (element.sexo == "Femenino") womenAttendeesToScan += 1;
        } else {
          if (element.sexo == "Masculino") menAttendeesScanned += 1;
          if (element.sexo == "Femenino") womenAttendeesScanned += 1;
        }
      });
      attendeesText =
          'Hombres Faltantes: $menAttendeesToScan Mujeres Faltantes: $womenAttendeesToScan\nHombres Escaneadas: $menAttendeesScanned Mujeres Escaneadas: $womenAttendeesScanned';
    }
    Text textoAMostrar;
    Attendee scannedAttendee;
    if (_qrText != null) {
      scannedAttendee = attendees
          .firstWhere((attendee) => _qrText == attendee.id, orElse: () => null);
      if (scannedAttendee != null && !scannedAttendee.scanned) {
        textoAMostrar = Text(
          'ID: $_qrText\n${scannedAttendee.firstName} ${scannedAttendee.lastName}\n${scannedAttendee.dni}\n${scannedAttendee.email}\n${scannedAttendee.whatsapp}\nInvitado de ${scannedAttendee.invitadoDe}',
          textAlign: TextAlign.center,
        );
      } else if (scannedAttendee != null && scannedAttendee.scanned) {
        textoAMostrar = Text(
          'Ya escaneado\nID: $_qrText\n${scannedAttendee.firstName} ${scannedAttendee.lastName}\n${scannedAttendee.dni}',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        );
      } else {
        textoAMostrar = Text(
          'Inexistente',
          style: TextStyle(color: Colors.red),
        );
      }
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            // To ensure the Scanner view is properly sizes after rotation
            // we need to listen for Flutter SizeChanged notification and update controller
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                Future.microtask(() => controller?.updateDimensions(qrKey));
                return false;
              },
              child: SizeChangedLayoutNotifier(
                key: const Key('qr-size-notifier'),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: (_qrText != null)
                  ? textoAMostrar
                  : Text('Escanear un código'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                attendeesText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: (_qrText != null &&
                    !_alreadyUploaded &&
                    scannedAttendee != null &&
                    !scannedAttendee.scanned)
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RaisedButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Text(
                          'Aceptar Ingreso',
                          textScaleFactor: 1.3,
                        ),
                      ),
                      onPressed: () async {
                        await Global.attendeeRef(_qrText)
                            .upsert({'scanned': true});
                        setState(() {
                          _alreadyUploaded = true;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  )
                : SizedBox(),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print(scanData.code);
      setState(() {
        result = scanData;
        _qrText = scanData.code;
        _alreadyUploaded = false;
      });
    });
  }

  /*@override
  Widget build(BuildContext context) {
    List<Attendee> attendees = Provider.of<List<Attendee>>(context);
    var contentList = <Widget>[
      if (_scanResult != null && _error != '')
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            _error,
            textScaleFactor: 1.3,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      if (_scanResult != null && _error == '')
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            _scanResult.rawContent,
            textScaleFactor: 1.3,
            textAlign: TextAlign.center,
          ),
        ),
      SizedBox(
        height: 20,
      ),
      if (_scanResult != null)
        Center(
          child: RaisedButton(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                'Escanear Nuevamente',
                textScaleFactor: 1.3,
              ),
            ),
            textColor: Colors.white,
            onPressed: () => scan(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.transparent),
            ),
          ),
        ),
    ];

    if (_scanResultCorrect) {
      Attendee scannedAttendee = attendees.firstWhere(
          (attendee) => _scanResult.rawContent == attendee.id,
          orElse: () => null);
      if (scannedAttendee != null && !scannedAttendee.scanned) {
        contentList.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              '${scannedAttendee.firstName} ${scannedAttendee.lastName}\n${scannedAttendee.dni}\n${scannedAttendee.email}\n${scannedAttendee.whatsapp}\nInvitado de ${scannedAttendee.invitadoDe}',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
            ),
          ),
        );
        contentList.add(
          Center(
            child: RaisedButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                  'Marcar como Entrado',
                  textScaleFactor: 1.3,
                ),
              ),
              onPressed: () async {
                await Global.attendeeRef(scannedAttendee.id)
                    .upsert({'scanned': true});
                await scan();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        );
      } else if (scannedAttendee != null && scannedAttendee.scanned) {
        contentList.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              'Ya escaneado',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      } else {
        contentList.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              'Inexistente',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado'),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.home),
          //   tooltip: "Volver al Login",
          //   onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
          //     '/',
          //     (_) => false,
          //   ),
          // ),
          IconButton(
            icon: Icon(Icons.camera),
            tooltip: "Escanear Nuevamente",
            onPressed: () => scan(),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: contentList,
      ),
    );
  }

  Future scan() async {
    setState(() {
      _error = '';
      _scanResultCorrect = false;
    });
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        // useCamera: _selectedCamera,
        // autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);
      String supposedUrl = result.rawContent;
      print(supposedUrl);
      if (result.type == ResultType.Cancelled) {
        setState(() {
          _error = '';
          _scanResult = result;
        });
      } else {
        setState(() {
          _error = '';
          _scanResult = result;
          _scanResultCorrect = true;
        });
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          _error = 'Necesitamos que aceptes los permisos de la camara';
          _scanResult = result;
        });
      } else {
        result.rawContent = 'Error desconocido: $e';
        setState(() {
          _error = 'Ocurrió un error desconocido';
          _scanResult = result;
        });
      }
    }
  }*/
}
