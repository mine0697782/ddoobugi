import 'package:flutter/material.dart';
import 'package:frontend/components/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;

  final LatLng _center = const LatLng(37.6098, 127.0737);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateTime() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        onWillPop: () async {
          if (isExpanded) {
            setState(() {
              isExpanded = false;
            });
            return false; // Back button action is handled
          }
          return true; // Default back button action
        },
        child: Scaffold(
          appBar: const CustomAppBar(),
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
                        children: isExpanded
                            ? [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.search),
                                  color: Colors.black,
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.person),
                                  color: Colors.black,
                                ),
                                IconButton(
                                  onPressed: () {
                                    statedialog(context, 70);
                                  },
                                  icon: const Icon(Icons.stop),
                                  color: Colors.red,
                                ),
                                IconButton(
                                  onPressed: _toggleExpansion,
                                  icon: const Icon(Icons.menu),
                                  color: Colors.black,
                                ),
                              ]
                            : [
                                FloatingActionButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  onPressed: _updateTime,
                                  backgroundColor: Colors.white,
                                  heroTag: "refreshButton",
                                  elevation: 0,
                                  child: const Icon(Icons.refresh,
                                      color: Colors.black),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    '${selectedDate.hour}:${selectedDate.minute}:${selectedDate.second}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                FloatingActionButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  onPressed: _toggleExpansion,
                                  backgroundColor: Colors.white,
                                  heroTag: "menuButton",
                                  elevation: 0,
                                  child: const Icon(Icons.menu,
                                      color: Colors.black),
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
      ),
    );
  }
}

void statedialog(BuildContext context, int state) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure that the column only takes up as much space as its content
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      '도착했습니다',
                      style: TextStyle(fontFamily: "Hanbit", fontSize: 25),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'WayPoint가 기록됩니다',
                      style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 180,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('이어하기',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('중지',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
