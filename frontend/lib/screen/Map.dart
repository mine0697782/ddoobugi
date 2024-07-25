import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/app_theme.dart';
import 'package:frontend/screen/chat.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;
  bool _myLocationEnabled = false;
  final LatLng _center = const LatLng(37.6098, 127.0737);
  final List<LatLng> polylineCoordinates = [];
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addRoute();
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

  Future<void> _currentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      _myLocationEnabled = true;
    });
  }

  Future<void> _addRoute() async {
    final startLat = 37.6098;
    final startLng = 127.0737;
    final endLat = 38.968917; // Underground Coffee Works latitude
    final endLng = -77.386254; // Underground Coffee Works longitude
    final apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    print('API response: $data'); // Debugging line to check API response

    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> result = _decodePolyline(points);
      setState(() {
        polylineCoordinates.addAll(result);
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      print('Error fetching directions: ${data['error_message']}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  @override
  void initState() {
    super.initState();
    _currentLocation();
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
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: const CustomAppBar(),
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 20.0,
                ),
                myLocationEnabled: _myLocationEnabled,
                myLocationButtonEnabled: true,
                polylines: _polylines,
              ),
              isExpanded
                  ? Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                          width: 300,
                          height: isExpanded ? 95 : 70,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 10)),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: _toggleExpansion,
                                        icon: const Icon(Icons.menu),
                                        color: Colors.black,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Chat()));
                                            },
                                            icon: const Icon(Icons.search),
                                            color: Colors.black,
                                          ),
                                          Text(
                                            "AI",
                                            style: TextStyle(
                                                fontFamily: "Hanbit",
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.person),
                                            color: Colors.black,
                                          ),
                                          Text(
                                            "MyPage",
                                            style: TextStyle(
                                                fontFamily: "Hanbit",
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              statedialog(context, 70);
                                            },
                                            icon: const Icon(Icons.stop),
                                            color: Colors.red,
                                          ),
                                          Text(
                                            "stop",
                                            style: TextStyle(
                                                fontFamily: "Hanbit",
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ]),
                              ),
                            ),
                          )),
                    )
                  : Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 19),
                        child: FloatingActionButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: _toggleExpansion,
                          backgroundColor: Colors.white,
                          heroTag: "menuButton",
                          elevation: 3,
                          child: const Icon(Icons.menu, color: Colors.black),
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
