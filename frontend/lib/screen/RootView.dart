import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RootviewScreen extends StatefulWidget {
  const RootviewScreen({super.key});

  @override
  State<RootviewScreen> createState() => _RootviewScreenState();
}

class _RootviewScreenState extends State<RootviewScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _mapCenter = const LatLng(37.5676, 126.9802); // 기본 위치

  // 서버 URL
  final String serverUrl =
      'https://your-server-url.com/api'; // 서버 URL을 여기에 설정하세요.

  @override
  void initState() {
    super.initState();
    _fetchDataAndSetMarkers();
  }

  Future<void> _fetchDataAndSetMarkers() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/routes/66a3017d06fe7648f0f60ceb'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedData = jsonDecode(response.body);

        final List<dynamic> places =
            parsedData['data']['chat_history']['ai_chat'][0]['places'];

        setState(() {
          _markers.clear(); // 기존 마커 제거

          for (var place in places) {
            final String placeId = place['place_id'];
            final String placeName = place['이름'];
            final double placeLat = place['위도'];
            final double placeLon = place['경도'];

            _markers.add(
              Marker(
                markerId: MarkerId(placeId),
                position: LatLng(placeLat, placeLon),
                infoWindow: InfoWindow(
                  title: placeName,
                  snippet: place['주소'],
                ),
              ),
            );
          }

          // 지도 중심을 새로운 위치로 이동
          _mapCenter =
              LatLng(parsedData['data']['lat'], parsedData['data']['lon']);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
        backgroundColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "내가 가는 길",
                  style: TextStyle(fontFamily: "Hanbit", fontSize: 30),
                ),
              ),
            ),
            // 지도 들어가기
            Container(
              width: double.infinity,
              height: 300,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _mapCenter,
                  zoom: 14,
                ),
                markers: _markers,
                mapType: MapType.normal,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // 따라가기 버튼
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    '따라가기',
                    style: TextStyle(
                        fontFamily: "Hanbit",
                        fontSize: 20,
                        color: Colors.white),
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
