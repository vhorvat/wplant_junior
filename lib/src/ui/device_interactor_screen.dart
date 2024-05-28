import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:wplant_junior/src/ble/ble_device_interactor.dart';

import 'dart:math';

class DeviceInteractorScreen extends StatelessWidget {
  final String deviceId;
  const DeviceInteractorScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, connectionStateUpdate, deviceInteractor, __) {
            if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              return DeviceInteractor(
                deviceId: deviceId,
                deviceInteractor: deviceInteractor,
              );
            } else if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connecting) {
              return const Text('Spajanje!');
            } else {
              return const Text('GATT error!');
            }
          },
        ),
      ),
    );
  }
}

class DeviceInteractor extends StatefulWidget {
  final BleDeviceInteractor deviceInteractor;

  final String deviceId;
  const DeviceInteractor(
      {Key? key, required this.deviceInteractor, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceInteractor> createState() => _DeviceInteractorState();
}

class _DeviceInteractorState extends State<DeviceInteractor> {
  final Uuid _myServiceUuid =
  Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Uuid _myCharacteristicUuid =
  Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  final Uuid _anotherServiceUuid =  Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c3319141");
  final Uuid _anotherCharacteristicUuid =  Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a9");

  Stream<List<int>>? subscriptionStream;
  Stream<List<int>>? anotherSubscriptionStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 150),
        // Add space between the top of the screen and the "connected" text
        const Text('Status: Spojen!',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 50),
        subscriptionStream != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(width: 5),
            Image.asset(
              'assets/light_icon.png', // Path to your asset image
              width: 80, // Adjust the size of the image
              height: 80, // Adjust the size of the image
            ),
            SizedBox(width: 10),
            // Adjust the spacing between the image and the text object
            Container(
              padding: EdgeInsets.all(5),
              child: StreamBuilder<List<int>>(
                stream: subscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Assuming data is a List<int>
                    var value = (snapshot.data![1] <<
                        8) |
                    snapshot
                        .data![0]; // Little Endian Uint16 conversion
                    return Text(value.toString() + "  lux", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black87));
                  }
                  return Text('Nema novih podataka!');
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        )
            : const Text('Niste pretplaćeni na nove podatke svijetla!'),
        SizedBox(height: 25),
        anotherSubscriptionStream != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround ,
          children: [
            SizedBox(width: 5),
            Image.asset(
              'assets/moisture_icon.png', // Path to your asset image
              width: 80, // Adjust the size of the image
              height: 80, // Adjust the size of the image
            ),
            SizedBox(width: 10),
            // Adjust the spacing between the image and the text object
            Container(
              padding: EdgeInsets.all(10),
              child: StreamBuilder<List<int>>(
                stream: anotherSubscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Assuming data is a List<int>
                    var value = (snapshot.data![1] <<
                        8) |
                    snapshot
                        .data![0]; // Little Endian Uint16 conversion
                    return Text(value.toString() + " %", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black87));
                  }
                  return Text('Nema podataka!');
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        )
            : const Text('Niste pretplaćeni na nove podatke vlage!'),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: subscriptionStream != null
                        ? null
                        : () async {
                      setState(() {
                        subscriptionStream = widget.deviceInteractor
                            .subScribeToCharacteristic(
                          QualifiedCharacteristic(
                              characteristicId: _myCharacteristicUuid,
                              serviceId: _myServiceUuid,
                              deviceId: widget.deviceId),
                        ).map((data) {
                          // Assuming data is a List<int>
                          var value = (data[1] <<
                              8) |
                          data[0]; // Little Endian Uint16 conversion
                          return [
                            value & 0xFF,
                            (value >> 8) & 0xFF
                          ]; // Return as List<int>
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      // Adjust the size according to your requirement
                      backgroundColor: Colors.lightGreenAccent,
                      disabledBackgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius for less roundness
                      ),
                    ),
                    child: Center(
                      child: const Text.rich(
                        TextSpan(
                          text: '', // default text style
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Pretplati se\n',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            TextSpan(
                                text: 'na svjetlost',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: anotherSubscriptionStream != null
                        ? null
                        : () async {
                      setState(() {
                        anotherSubscriptionStream = widget.deviceInteractor
                            .subScribeToCharacteristic(
                          QualifiedCharacteristic(
                              characteristicId: _anotherCharacteristicUuid,
                              serviceId: _myServiceUuid,
                              deviceId: widget.deviceId),
                        ).map((data) {
                          // Assuming data is a List<int>
                          var value = (data[1] <<
                              8) |
                          data[0]; // Little Endian Uint16 conversion
                          return [
                            value & 0xFF,
                            (value >> 8) & 0xFF
                          ]; // Return as List<int>
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      // Adjust the size according to your requirement
                      backgroundColor: Colors.lightGreenAccent,
                      disabledBackgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius for less roundness
                      ),
                    ),
                    child: Center(
                      child: const Text.rich(
                        TextSpan(
                          text: '', // default text style
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Pretplati se\n',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            TextSpan(
                                text: 'na vlagu',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                  // Adjust the size according to your requirement
                  backgroundColor: Colors.lightGreenAccent,
                  disabledBackgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius for less roundness
                  ),
                ),
                child: const Text('Odspoji se!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



