import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:wplant_junior/src/ble/ble_device_connector.dart';
import 'package:wplant_junior/src/ble/ble_scanner.dart';
import 'package:wplant_junior/src/ui/device_interactor_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, bleDeviceConnector, __) =>
            _DeviceList(
              scannerState: bleScannerState ??
                  const BleScannerState(
                    discoveredDevices: [],
                    scanIsInProgress: false,
                  ),
              startScan: bleScanner.startScan,
              stopScan: bleScanner.stopScan,
              deviceConnector: bleDeviceConnector,
            ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
  });

  final BleDeviceConnector deviceConnector;
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  @override
  __DeviceListState createState() => __DeviceListState();
}

class __DeviceListState extends State<_DeviceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 25), // Add space between top of the screen and logo placeholder
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Image.asset(
                'assets/logoi.png', // Replace 'your_image.png' with the path to your PNG image
                height: 100, // Adjust the height of the image
                width: 600, // Adjust the width of the image
                fit: BoxFit.contain, // Adjust the fit of the image within its container
              ),
            ),
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .where((device) => device.name != "") // Filter devices with non-null names
                    .map(
                      (device) => ListTile(
                    title: Text(device.name),
                    subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                    leading: const Icon(Icons.bluetooth),
                    onTap: () async {
                      widget.stopScan();
                      widget.deviceConnector.connect(device.id);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceInteractorScreen(
                            deviceId: device.id,
                          ),
                        ),
                      );
                      widget.deviceConnector.disconnect(device.id);
                      widget.startScan([]);
                    },
                  ),
                ).toList(), // Convert Iterable to List
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: !widget.scannerState.scanIsInProgress
                      ? () => widget.startScan([])
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), // Adjust the size according to your requirement
                    backgroundColor: Colors.lightGreenAccent,
                    disabledBackgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Adjust the radius for less roundness
                    ),
                  ),
                  child: Center(
                    child: const Text.rich(
                      TextSpan(
                        text: '', // default text style
                        children: <TextSpan>[
                          TextSpan(text: 'Pretraži\n', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          TextSpan(text: 'uređaje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.scannerState.scanIsInProgress
                      ? widget.stopScan
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50), // Adjust the size according to your requirement
                    backgroundColor: Colors.lightGreenAccent,
                    disabledBackgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Adjust the radius for less roundness
                    ),
                  ),
                  child: Center(
                    child: const Text.rich(
                      TextSpan(
                        text: '', // default text style
                        children: <TextSpan>[
                          TextSpan(text: 'Zaustavi\n', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          TextSpan(text: 'pretraživanje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}