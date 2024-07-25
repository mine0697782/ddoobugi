import 'package:flutter/material.dart';
import 'package:frontend/components/server.dart';
import 'package:frontend/screen/RootView.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';

Future<Map<String, dynamic>> fetchStorageData(String id) async {
  final response = await http.get(Uri.parse('$serverUrl/routes/$id'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['result'] == 'success') {
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load storage data');
    }
  } else {
    throw Exception('Failed to load storage data');
  }
}

DateTime parseDateString(String dateString) {
  try {
    final DateTime date = DateTime.parse(dateString);
    return date.toLocal();
  } catch (e) {
    print('Date parsing error: $e');
    return DateTime.now();
  }
}

Future<LocationData?> getCurrentLocation() async {
  Location location = Location();
  LocationData? locationData;

  try {
    locationData = await location.getLocation();
  } catch (e) {
    print("위치 정보 가져오기 실패: $e");
  }

  return locationData;
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Earth radius in kilometers

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c * 1000; // Distance in meters
}

double _toRadians(double degrees) {
  return degrees * pi / 180;
}

class StorageView extends StatefulWidget {
  final String id;

  const StorageView({
    super.key,
    required this.id,
  });

  @override
  _StorageViewState createState() => _StorageViewState();
}

class _StorageViewState extends State<StorageView> {
  late TextEditingController _titleController;
  bool _isEditingTitle = false;
  late Future<Map<String, dynamic>> futureStorageData;
  late GoogleMapController _mapController;
  LatLng _mapCenter = const LatLng(37.8843499, 127.0537838); // 기본 위치
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    futureStorageData = fetchStorageData(widget.id);
    _titleController = TextEditingController(text: "산책하는길");
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _onFollowButtonPressed() async {
    LocationData? currentLocation = await getCurrentLocation();

    if (currentLocation == null) {
      print("현재 위치를 가져올 수 없습니다.");
      return;
    }

    LatLng startLocation = _mapCenter;

    double distance = _calculateDistance(
      currentLocation.latitude!,
      currentLocation.longitude!,
      startLocation.latitude,
      startLocation.longitude,
    );

    if (distance < 10) {
      // 10 미터 이내
      _showFollowDialog(context, _titleController.text, startLocation);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RootviewScreen(),
        ),
      );
    }
  }

  void _showFollowDialog(BuildContext context, String title, LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 300,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style:
                            const TextStyle(fontFamily: "Hanbit", fontSize: 25),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '지도',
                        style:
                            const TextStyle(fontFamily: "Hanbit", fontSize: 15),
                      ),

                      const SizedBox(height: 20),
                      // 지도
                      SizedBox(
                        width: double.infinity,
                        height: 200, // 높이를 조절할 수 있습니다
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: location,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('location_marker'),
                              position: location,
                              infoWindow: InfoWindow(
                                title: title,
                                snippet: title,
                              ),
                            ),
                          },
                          mapType: MapType.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Buttons
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
                              child: const Text('예',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(
                            width: 70,
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
                              child: const Text('아니요',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/logo.png',
          scale: 6,
        ),
        actions: [
          _isEditingTitle
              ? IconButton(
                  icon: const Icon(Icons.save, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isEditingTitle = false;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isEditingTitle = true;
                    });
                  },
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Divider(
            height: 0.8,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureStorageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final data = snapshot.data!;
            final String title = data['name'] ?? 'No title';
            final String address = data['address'] ?? 'No address';
            final String imageUrl =
                data['image'] ?? 'assets/images/sample1.png';
            final String createdDateStr =
                data['created_date'] ?? DateTime.now().toString();

            final DateTime createdDate = parseDateString(createdDateStr);
            _titleController.text = title;

            final List<dynamic> places =
                data['chat_history']['ai_chat'][0]['places'] ?? [];
            _markers = places.map((place) {
              final placeId = place['place_id'];
              final placeName = place['이름'];
              final placeLat = place['lat'] ?? _mapCenter.latitude;
              final placeLon = place['lon'] ?? _mapCenter.longitude;

              return Marker(
                markerId: MarkerId(placeId),
                position: LatLng(placeLat, placeLon),
                infoWindow: InfoWindow(
                  title: placeName,
                  snippet: place['주소'],
                ),
              );
            }).toSet();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/sample1.png',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 16),
                  // 제목
                  _isEditingTitle
                      ? TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontFamily: "Hanbit",
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          _titleController.text,
                          style: const TextStyle(
                            fontFamily: "Hanbit",
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 8),
                  // 위치 정보
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 시간 정보
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(createdDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 지도
                  SizedBox(
                    width: double.infinity,
                    height: 300, // 높이를 조절할 수 있습니다
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _mapCenter,
                        zoom: 14,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                    ),
                  ),
                  const Spacer(),
                  // 따라가기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _onFollowButtonPressed,
                      child: const Text(
                        '따라가기',
                        style: TextStyle(
                            fontFamily: "Hanbit",
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
