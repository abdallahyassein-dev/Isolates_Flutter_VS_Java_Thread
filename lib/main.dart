// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Isolate Example',
      home: IsolateExample(),
    );
  }
}

class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  _IsolateExampleState createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<IsolateExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  int counter = 0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 300),
      vsync: this,
    );

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0, 3),
    ).animate(curvedAnimation);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  int startOtherTask() {
    int normalCounter = 0;
    for (int i = 0; i < 1000000000; i++) {
      normalCounter++;
    }
    log("ended on main isolate");
    return normalCounter;
  }

  Future<int> startOtherTaskOnHelperIsolate() async {
    return await Isolate.run<int>(() {
      int isolateCounter = 0;
      for (int i = 0; i < 1000000000; i++) {
        isolateCounter += 1;
        counter += 1;
      }
      log("ended on helper isolate");
      return isolateCounter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 240, 224),
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.blueAccent,
      //   title: const Text(
      //     'Isolate Exmaple',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
                bottom: 0,
                child: Container(
                  width: 600,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 76, 78, 67),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ]),
                )),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      children: [
                        const Text("🙀", style: TextStyle(fontSize: 80)),
                        SizedBox(
                          width: 180,
                          height: 60,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                counter = 0;

                                counter = startOtherTask();
                                setState(() {});
                              },
                              child: const Text(
                                "Start \n Large Computation",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("😽",
                            style: TextStyle(
                              fontSize: 80,
                            )),
                        SizedBox(
                          width: 190,
                          height: 60,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                //    counter = 0;

                                counter = await startOtherTaskOnHelperIsolate();
                                setState(() {});
                              },
                              child: const Text(
                                "Start \n Computation on Helper Isolate",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                SlideTransition(
                  position: _animation,
                  child: Column(
                    children: [
                      Center(
                          child: Text(
                        "Don't Lag Me ! \n $counter",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 76, 78, 67),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )),
                      const Text(
                        "😡",
                        style: TextStyle(fontSize: 80),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
