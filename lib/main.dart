import 'package:flutter/material.dart';

void main() {
  runApp(VirtualAquariumApp());
}

class VirtualAquariumApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override 
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  //Animation controller to handle fish movement
  late AnimationController _controller;

  //Position and movement details
  double _fishXPosition = 50.0;
  double _fishYPosition = 50.0;
  double _fishSpeed = 2.0;

  @override 
  void initState() {
    super.initState();

    //Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      )..addListener(() {
        setState(() {
          //moves the fish in random directions
          _fishXPosition += _fishSpeed;
          _fishYPosition += _fishSpeed;

          //checks if the fish hits the edge of the container and bounce back
          if (_fishXPosition >= 250.0 || _fishXPosition <= 0.0) {
            _fishSpeed = -_fishSpeed;
          }
          if (_fishYPosition >= 250.0 || _fishYPosition <= 0.0) {
            _fishSpeed = -_fishSpeed;
          }
        });
      });
    //starts the animation loop
    _controller.repeat();
  }

  @override
  void dispose() {
    //cleans up the controller when the widget is disposed
    _controller.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Center(
        child: Stack(
          children: [
            //Aquarium Container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Stack(
                children: [
                  //Animated fish movement
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    top: _fishYPosition,
                    left: _fishXPosition,
                    child: Image.asset(
                      'assets/images/fish1.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}