import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  DateTime selectedDate = DateTime.now();

  final LatLng _center = const LatLng(37.6098, 127.0737);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateTime() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
<<<<<<< HEAD
        appBar: AppBar(
          title: Image.asset(
            'assets/images/logo.png',
            scale: 6,
          ),
          backgroundColor: Colors.white,
        ),
=======
        // appBar: AppBar(
        //   title: Image.asset(
        //     'assets/images/logo.png',
        //     scale: 6,
        //   ),
        //   backgroundColor: Colors.white,
        // ),
>>>>>>> 54546f2efb9ceb759777b8a47375568ffc3002e8
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 300,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FloatingActionButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            onPressed: _updateTime,
                            backgroundColor: Colors.white,
                            heroTag: "actionButton",
                            child: Icon(Icons.refresh),
                            elevation: 0,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, elevation: 0),
                          child: Text(
                            '${selectedDate.hour}:${selectedDate.minute}:${selectedDate.second}',
                          ),
                        ),
                        FloatingActionButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          heroTag: "actionButton",
                          child: Icon(Icons.menu),
                          elevation: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
