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
          appBar: AppBar(
            title: Image.asset(
              'assets/images/logo.png',
              scale: 6,
            ),
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: Divider(
                height: 0.8,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
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
                                  icon: Icon(Icons.search),
                                  color: Colors.black,
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.person),
                                  color: Colors.black,
                                ),
                                IconButton(
                                  onPressed: () {
                                    statedialog(context, 70);
                                  },
                                  icon: Icon(Icons.stop),
                                  color: Colors.red,
                                ),
                                IconButton(
                                  onPressed: _toggleExpansion,
                                  icon: Icon(Icons.menu),
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
                                  child:
                                      Icon(Icons.refresh, color: Colors.black),
                                  elevation: 0,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    '${selectedDate.hour}:${selectedDate.minute}:${selectedDate.second}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                FloatingActionButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  onPressed: _toggleExpansion,
                                  backgroundColor: Colors.white,
                                  heroTag: "menuButton",
                                  child: Icon(Icons.menu, color: Colors.black),
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
      ),
    );
  }
}

void statedialog(BuildContext context, int state) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          margin: EdgeInsets.all(10),
          width: 400,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text(
                "도착하였습니다 \n Waypoint가 기록됩니다",
                style: TextStyle(fontFamily: "bm", fontSize: 20),
              ),
              const SizedBox(
                height: 15,
              ),
              Image.asset(
                "assets/images/turtle.png",
                scale: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "대단해요!",
                style: TextStyle(fontFamily: "bma", fontSize: 20),
              ),
              const Text(
                "앞으로도 멋진 모습 기대할게요!",
                style: TextStyle(fontFamily: "bma", fontSize: 16),
              ),
              const SizedBox(
                height: 15,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
    },
  );
}
