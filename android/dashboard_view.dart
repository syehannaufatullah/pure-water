import 'dart:async';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Timer _timer;
  late String _currentTime = '';
  late String _currentTemperature = '0';
  late String _currentTurbidity = '0';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id');
    _startTimer();

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    // Listen for changes in the database
    databaseReference.child('temperature').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          // Update the current temperature from Firebase
          _currentTemperature = event.snapshot.value.toString();
        });
      }
    });

    // Listen for changes in the 'turbidity' node
    databaseReference.child('Turbidity').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          // Update the current turbidity from Firebase
          var turbidityValue = event.snapshot.value;

          // Check if turbidityValue is not null and is int
          if (turbidityValue != null && turbidityValue is int) {
            if (turbidityValue < 20) {
              _currentTurbidity = 'JERNIH';
            } else if (turbidityValue >= 20 && turbidityValue <= 50) {
              _currentTurbidity = 'KERUH';
            } else {
              _currentTurbidity = 'KOTOR';
            }
          } else {
            // Handle the case where snapshot value is not an integer
            _currentTurbidity = 'Unknown'; // or any default value you want
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
    _currentTime = _getCurrentTime();
  }

  String _getCurrentTime() {
    return DateFormat('EEEE, d MMMM y HH:mm:ss', 'id').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(vertical: 50),
          decoration: const BoxDecoration(
            color: Color(0xffFFFFFF),
            image: DecorationImage(
              image: AssetImage('assets/images/background1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Image.asset(
                'assets/images/logodashboard.png',
                width: 350,
                height: 200,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 450.0,
                      decoration: BoxDecoration(
                          color: const Color(0xffFFFFFF),
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000).withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xffD9D9D9),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text(
                                  _currentTime,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'PaytoneOne',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: _buildCircularContainerWithText(
                                      "$_currentTemperature°C", "SUHU AIR"),
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: _buildCircularContainerWithText(
                                      _currentTurbidity, "KEJERNIHAN"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCircularContainerWithText(String containerText, String text) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: Color(0xff1F8ECC),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            containerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'PaytoneOne',
              fontSize: 21,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 5.0,
      ),
      Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'PaytoneOne',
          fontSize: 20,
        ), // Ubah warna teks di sini
      ),
    ],
  );
}
