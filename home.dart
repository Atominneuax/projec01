import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:hello_world/drawer.dart';
import 'package:mysql1/mysql1.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:hello_world/location_service.dart';
// import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  Map data = {};
  String item = 'Whatever';
  List<Marker> _markers = [];
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  late BitmapDescriptor _customMarkerIcon;
  late BitmapDescriptor _customUserMarkerIcon;
  late LatLng currentLocation;
  late GoogleMapController _mapController;
  bool isLoading = true;
  double zoom = 16;

  String username = '';
  String name = '';
  String number = '';

  Future<MySqlConnection> _connectToDatabase() async {
    final settings = ConnectionSettings(
      host: 'srv901.hstgr.io', // Replace with your MySQL host
      port: 3306, // Replace with your MySQL port (default is 3306)
      user: 'u714842824_rodney', // Replace with your MySQL username
      password: 'Rodney123', // Replace with your MySQL password
      db: 'u714842824_rodney', // Replace with your MySQL database name
    );
    return await MySqlConnection.connect(settings);
  }

  Future<void> loadCustomMarkerIcon() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/marker.png',
    );
    setState(() {
      _customMarkerIcon = icon;
    });
  }

  Future<void> loadUserCustomMarkerIcon() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/current.png',
    );
    setState(() {
      _customUserMarkerIcon = icon;
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      LatLng latLng = LatLng(position.latitude, position.longitude);
      currentLocation = latLng;
      _markers.add(Marker(
          markerId: const MarkerId('user_location'),
          position: latLng,
          icon:  _customUserMarkerIcon,
          onTap: (){
            _customInfoWindowController.addInfoWindow!(
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                child: const Center(
                  child: Text("This is your location"),
                ),
              ),
              latLng,
            );
          }
      ));
      _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
      isLoading = false;
    });
  }

  void getName (String id) async {
    final connection = await _connectToDatabase();
    final details = await connection.query('SELECT * FROM details WHERE id="$id"');
    // print(details);

    for (var row in details) {
      name = row['name'];
      number = row['number'];
      username = row['username'];
    }

    await connection.close();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }



  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadCustomMarkerIcon();
    loadUserCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    getName(data['id'].toString());
    return Scaffold(
      drawer: CustomDrawer(id: data['id'], name: name, number: number, username: username),
      appBar: AppBar(
        title: const Text('Sell It'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: isLoading ? 0.0 : 1.0,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: const LatLng(0.0, 0.0),
                      zoom: zoom,
                    ),
                    onMapCreated: (GoogleMapController mapController) {
                      _mapController = mapController;
                      setState(() {
                        _customInfoWindowController.googleMapController = mapController;
                      });
                    },
                    markers: Set<Marker>.from(_markers),
                    onTap: (position){
                      _customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (position){
                      _customInfoWindowController.onCameraMove!();
                    },
                  ),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 120,
                  width: 200,
                  offset: 44,
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          // Container - 30% of the screen height
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue, // Replace with your desired color or decoration
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            _markers = [];
                            // LatLng? location = await _getCurrentLocation();
                            dynamic result = await Navigator.pushNamed(context, '/buysell', arguments: {
                              'action': 'buy',
                            });

                            setState(() {
                              isLoading = true;
                            });

                            setState(() {
                              item = result['item'];
                              zoom = 12;

                              result.forEach((key, value){
                                if(key is! int){}
                                else{
                                  List sellerDetails = value.split('_');
                                  _markers.add(Marker(
                                      markerId: MarkerId('$key'),
                                      position: LatLng(double.parse(sellerDetails[2]), double.parse(sellerDetails[3])),
                                      icon:  _customMarkerIcon,
                                      onTap: (){
                                        _customInfoWindowController.addInfoWindow!(
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              color: Colors.white,
                                              child: Column(
                                                children: <Widget>[
                                                  Text("Seller Name: ${sellerDetails[0]}"),
                                                  const SizedBox(height: 3),
                                                  TextButton.icon(
                                                    onPressed: (){
                                                      _launchUrl("tel:${sellerDetails[1]}");
                                                    },
                                                    label: Text('${sellerDetails[1]}'),
                                                    icon: const Icon(Icons.person),
                                                  )
                                                ],
                                              ),
                                            ),
                                            LatLng(double.parse(sellerDetails[2]), double.parse(sellerDetails[3]))
                                        );
                                      }
                                  ));
                                }
                              });
                              _getCurrentLocation();
                            });

                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.all(35.0),
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 25.0,
                              )
                          ),
                          child: const Text("Buy"),
                        ),
                        const Text("or"),
                        ElevatedButton(
                          onPressed: () async {
                            // LatLng? location = await _getCurrentLocation();
                            dynamic result = await Navigator.pushNamed(context, '/buysell', arguments: {
                              'action': 'sell',
                              'id': data['id'],
                              'lat': currentLocation.latitude,
                              'lng': currentLocation.longitude,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.all(35.0),
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 25.0,
                              )
                          ),
                          child: const Text("Sell"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.all(15.0),
                    //     backgroundColor: Colors.red,
                    //       textStyle: const TextStyle(
                    //         fontSize: 15.0,
                    //       )
                    //   ),
                    //   child: const Text("Panic"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
