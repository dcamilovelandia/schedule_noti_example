import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notification/screens/second_screen.dart';
import 'package:flutter_local_notification/services/local_notification_service.dart';
import 'package:optimize_battery/optimize_battery.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final NotificationHelper service;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    service = NotificationHelper();
    service.initializeNotification();
    super.initState();
  }
  Future<void> pickTime() async {

    final res = await showTimePicker(
      initialTime: TimeOfDay(
        hour: TimeOfDay.now().hour,
        minute: TimeOfDay.now().minute + 1,
      ),
      context: context,
      confirmText: 'SET ALARM',
    );

    if (res == null) return;
    setState(() => selectedTime = res);
    await service.scheduledNotification(
        id: 0,
        hour: selectedTime!.hour,
        minutes: selectedTime!.minute,
        sound:''
    );

    print('${selectedTime!.hour} ${selectedTime!.minute}');
  }


  validation() async {
    if(Platform.isAndroid) {
      await DisableBatteryOptimization.isBatteryOptimizationDisabled.then((value) async {
        print(value);
        if(value != null && !value) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Column(
                children: [
                const Text(
                    'Es necesario desactivar el ahorro de bateria de tu dispositivo para que podamos ofrecerte un mejor rendimiento en nuestra aplicación'
                        ', será neceario reiniciar la aplicación para aplicar el cambio.',
                    style: TextStyle(color: Colors.black)
                ),
                  const SizedBox(height: 30,),
                  RawMaterialButton(
                    onPressed: () async{
                      Navigator.pop(context);
                      bool? res = await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                      print('Value => $res');
                      // Restart.restartApp();
                      // print('no se ha concedido el permiso, es posible que las notificaciónes programadas no se ejecuten');
                      // pickTime();
                    },
                    fillColor: Colors.black,
                    child: const Text('Open setting',style: TextStyle(color: Colors.white),),
                  )
                ],
              ),
            ),
          );
        } else {
          print('ignoring battry saver');
          pickTime();
        }
      });
    } else {
      pickTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Notification Demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'This is a demo of how to use local notifications in Flutter.',
                    style: TextStyle(fontSize: 20),
                  ),
                  RawMaterialButton(
                    onPressed: validation,
                    fillColor: Colors.black,
                    child: const Text('Pick time',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void onNoticationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('payload $payload');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => SecondScreen(payload: payload))));
    }
  }
}
