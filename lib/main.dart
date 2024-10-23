import 'package:flutter/material.dart';
import 'database_helper.dart'; 

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
  late AnimationController _controller;
  List<Map<String, dynamic>> _fishList = [];
  double _fishSpeed = 2.0;
  Color _selectedFishColor = Colors.orange;
  final double _fishSize = 50.0;
  final int _maxFishCount = 10;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Database helper instance

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1), 
      vsync: this,
    )..addListener(() {
        setState(() {
          _fishList.forEach((fish) {
            fish['xPosition'] += _fishSpeed * fish['xDirection'];
            fish['yPosition'] += _fishSpeed * fish['yDirection'];

            if (fish['xPosition'] >= (300 - _fishSize) || fish['xPosition'] <= 0.0) {
              fish['xDirection'] = -fish['xDirection'];
            }
            if (fish['yPosition'] >= (300 - _fishSize) || fish['yPosition'] <= 0.0) {
              fish['yDirection'] = -fish['yDirection'];
            }
          });
        });
      });

    _controller.repeat();

    _loadAquariumSettings(); // Load settings when app starts
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFish() {
    if (_fishList.length < _maxFishCount) {
      setState(() {
        _fishList.add({
          'xPosition': 50.0,
          'yPosition': 50.0,
          'xDirection': 1.0,
          'yDirection': 1.0,
          'color': _selectedFishColor,
        });
      });
    }
  }

  Future<void> _saveAquariumSettings() async {
    int fishCount = _fishList.length;
    String fishColor = _selectedFishColor.toString();
    
    // Save the settings to the database
    await _dbHelper.saveAquariumSettings(fishCount, _fishSpeed, fishColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aquarium settings saved!')),
    );
  }

  Future<void> _loadAquariumSettings() async {
    // Load saved settings from the database
    Map<String, dynamic>? settings = await _dbHelper.getAquariumSettings();
    if (settings != null) {
      setState(() {
        _fishSpeed = settings['fishSpeed'];
        _selectedFishColor = Color(int.parse(settings['fishColor']));
        for (int i = 0; i < settings['fishCount']; i++) {
          _addFish();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAquariumSettings, // Save button
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Stack(
                      children: _fishList.map((fish) {
                        return AnimatedPositioned(
                          duration: Duration(milliseconds: 500),
                          top: fish['yPosition'],
                          left: fish['xPosition'],
                          child: Image.asset(
                            'assets/images/fish1.png',
                            width: _fishSize,
                            height: _fishSize,
                            color: fish['color'], 
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Fish Speed: ${_fishSpeed.toStringAsFixed(1)}'),
                Slider(
                  value: _fishSpeed,
                  min: 1.0,
                  max: 5.0,
                  onChanged: (value) {
                    setState(() {
                      _fishSpeed = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Select Fish Color: '),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFishColor = Colors.orange;
                    });
                  },
                  child: CircleAvatar(backgroundColor: Colors.orange),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFishColor = Colors.green;
                    });
                  },
                  child: CircleAvatar(backgroundColor: Colors.green),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFishColor = Colors.blue;
                    });
                  },
                  child: CircleAvatar(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _addFish,
            child: Text('Add Fish'),
          ),
        ],
      ),
    );
  }
}