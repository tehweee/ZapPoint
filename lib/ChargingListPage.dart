import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:testing_rapidapi_2/ChargersSearch.dart';
import 'package:testing_rapidapi_2/httpservice_portSeach.dart';
import 'package:url_launcher/url_launcher.dart';
import 'httpservice_ports.dart';
import 'Chargers.dart';
import 'RouteScreen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'EditProfilePage.dart';
import 'IntroPage.dart';
import 'const.dart';

class ChargerListScreen extends StatefulWidget {
  @override
  _ChargerListScreenState createState() => _ChargerListScreenState();
}

class _ChargerListScreenState extends State<ChargerListScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  final TextEditingController searchAreaController = TextEditingController();

  LatLng _initialPosition = LatLng(1.438, 103.786);

  bool _locationPermissionGranted = false;
  bool _isLoadingLocation = true;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Map<String, dynamic>? _selectedRecentCharger;

  Datum? _selectedCharger;
  DatumSearch? _selectedChargerSearch;

  bool _isRouting = false;
  TextEditingController areaQuery = TextEditingController();

  final String googleApiKey = GOOGLE_MAP_API;
  //var location = new Location();
  LocationData? userLocation;
  @override
  void initState() {
    super.initState();
    _determinePosition();
    //_loadChargers();
    _loadRecentChargers();
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            double minKWValue = 1.0;

            double maxKWValue = 300.0;
            double limitCounter = 1.0;

            int sliderIndex = 0;
            final List<String> chargerTypes = ["Type 2", "CCS", "Tesla"];
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: EdgeInsets.all(16),
                  height: 460,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: areaQuery,
                            decoration: InputDecoration(
                              hintText: 'Enter something...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "Range : ${minKWValue.toStringAsFixed(2)} - ${maxKWValue.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      RangeSlider(
                        values: RangeValues(minKWValue, maxKWValue),
                        min: 1,
                        max: 300,
                        labels: RangeLabels(
                          "${minKWValue.toStringAsFixed(0)} kW",
                          "${maxKWValue.toStringAsFixed(0)} kW",
                        ),
                        divisions: 300,
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            minKWValue = values.start;

                            maxKWValue = values.end;
                          });
                        },
                      ),
                      SizedBox(height: 4),

                      Text(
                        chargerTypes[sliderIndex],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Slider(
                        value: sliderIndex.toDouble(),
                        min: 0,
                        max: 2,
                        label: chargerTypes[sliderIndex],
                        divisions: 2,
                        onChanged: (value) {
                          setModalState(() {
                            sliderIndex = value.toInt();
                          });
                        },
                      ),
                      SizedBox(height: 4),

                      Text(
                        "Display Number of Ports",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Slider(
                        value: limitCounter,
                        min: 1,
                        max: 20,
                        label: "${limitCounter.toInt()} count",
                        divisions: 19,
                        onChanged: (value) {
                          setModalState(() {
                            limitCounter = value;
                          });
                        },
                      ),
                      SizedBox(height: 4),
                      ElevatedButton.icon(
                        icon: Icon(Icons.filter_alt, color: Colors.black),
                        label: Text(
                          'Filter Now',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD54F),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          searchByFilter(
                            chargerTypes[sliderIndex],
                            areaQuery.text,
                            minKWValue.toString(),
                            maxKWValue.toString(),
                            limitCounter.toString(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<LocationData?> _getLocaiton() async {
    var location = new Location();
    LocationData? currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<void> searchByFilter(
    String type,
    String area,
    String min_kw,
    String max_kw,
    String limit,
  ) async {
    final chargers = await HttpServicePortSearch.getFilterCarparks(
      type,
      area,
      min_kw,
      max_kw,
      limit,
    );
    print("""
    ==============================
    ==============================
    ==============================
    Charger $chargers
    ==============================
    ==============================
    ==============================
      """);
    if (chargers != null) {
      final Set<Marker> newMarkers = chargers.map((charger) {
        print("""
===================================
===================================
===================================
lat: ${charger.latitude}
long: ${charger.longitude}
===================================
===================================
===================================
""");
        return Marker(
          markerId: MarkerId(charger.id ?? ""),
          position: LatLng(charger.latitude ?? 0.0, charger.longitude ?? 0.0),
          infoWindow: InfoWindow(title: charger.name),
          onTap: () => _showChargerBottomSheetSearch(charger),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<void> searchByArea(String query) async {
    String typeContent = "";

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final engine =
        data?['vehicle']?['specifications']?['generalInformation']?['modificationEngine'];
    RegExp regex = RegExp(r'^(\d+(?:\.\d+)?)\s*kWh');
    Match? engineMacth = regex.firstMatch(engine);
    if (engineMacth != null) {
      double kWhValue = double.parse(engineMacth.group(1)!);

      if (kWhValue >= 60 && kWhValue <= 200) {
        typeContent += "Tesla,";
      }
      if (kWhValue >= 10 && kWhValue <= 80) {
        typeContent += "Type 2,";
      }
      if (kWhValue >= 50 && kWhValue <= 350) {
        typeContent += "CCS,";
      }
    }
    final chargers = await HttpServicePortSearch.getCarparks(
      typeContent,
      query,
    );
    print("""
    ==============================
    ==============================
    ==============================
    Charger $chargers
    ==============================
    ==============================
    ==============================
      """);
    if (chargers != null) {
      final Set<Marker> newMarkers = chargers.map((charger) {
        return Marker(
          markerId: MarkerId(charger.id ?? ""),
          position: LatLng(charger.latitude ?? 0.0, charger.longitude ?? 0.0),
          infoWindow: InfoWindow(title: charger.name),
          onTap: () => _showChargerBottomSheetSearch(charger),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationPermissionGranted = false;
          _isLoadingLocation = false;
        });
        return;
      }
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      if (_mapController.isCompleted) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 14),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadChargers() async {
    String typeContent = "";

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final engine =
        data?['vehicle']?['specifications']?['generalInformation']?['modificationEngine'];
    RegExp regex = RegExp(r'^(\d+(?:\.\d+)?)\s*kWh');
    Match? engineMacth = regex.firstMatch(engine);
    print("""
    ==============================
        ==============================
            ==============================
            kWhValue : $engine
                ==============================
                    ==============================
                        ==============================
                            ==============================
""");
    if (engineMacth != null) {
      double kWhValue = double.parse(engineMacth.group(1)!);

      if (kWhValue >= 60 && kWhValue <= 200) {
        typeContent += "Tesla,";
      }
      if (kWhValue >= 10 && kWhValue <= 80) {
        typeContent += "Type 2,";
      }
      if (kWhValue >= 50 && kWhValue <= 350) {
        typeContent += "CCS,";
      }
    }

    print("""
    ==============================
        ==============================
            ==============================
            Type : $typeContent
                ==============================
                    ==============================
                        ==============================
                            ==============================
""");
    userLocation = await _getLocaiton();

    final chargers = await HttpServicePort.getCarparks(
      typeContent,
      userLocation!.latitude,
      userLocation!.longitude,
    );
    if (chargers != null) {
      final Set<Marker> newMarkers = chargers.map((charger) {
        return Marker(
          markerId: MarkerId(charger.id),
          position: LatLng(charger.latitude, charger.longitude),
          infoWindow: InfoWindow(title: charger.name),
          onTap: () => _showChargerBottomSheet(charger),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<void> _loadRecentChargers() async {
    String? uid = await FirebaseAuth.instance.currentUser?.uid;
    final data = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    List chargers = List.from(data["recents"] ?? []);
    print("""
  ==========================
  ==========================
  ==========================
  Charger : $chargers
  ==========================
  ==========================
  ==========================
  """);

    if (chargers != null) {
      final Set<Marker> newMarkers = chargers.map((charger) {
        print("""
  ==========================
  ==========================
  ==========================
  Charger : $charger
  ==========================
  ==========================
  ==========================
  """);
        return Marker(
          markerId: MarkerId(charger["id"].toString()),
          position: LatLng(charger["latitude"], charger["longitude"]),
          infoWindow: InfoWindow(title: charger["name"]),
          onTap: () => _showRecentChargerBottomSheet(charger),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<void> _loadFavouriteChargers() async {
    String? uid = await FirebaseAuth.instance.currentUser?.uid;
    final data = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    List chargers = List.from(data["favourites"] ?? []);
    print("""
  ==========================
  ==========================
  ==========================
  Charger : $chargers
  ==========================
  ==========================
  ==========================
  """);
    if (chargers != null) {
      if (chargers.length == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('There no EV found in the search!'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      } else {
        final Set<Marker> newMarkers = chargers.map((charger) {
          print("""
  ==========================
  ==========================
  ==========================
  Charger : $charger
  ==========================
  ==========================
  ==========================
  """);
          return Marker(
            markerId: MarkerId(charger["id"].toString()),
            position: LatLng(charger["latitude"], charger["longitude"]),
            infoWindow: InfoWindow(title: charger["name"]),
            onTap: () => _showRecentChargerBottomSheet(charger),
          );
        }).toSet();

        setState(() {
          _markers = newMarkers;
        });
      }
    }
  }

  void _showRecentChargerBottomSheet(charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 460,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charger["name"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  if (charger['photo'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        charger["photo"]!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  SizedBox(height: 8),
                  Text(
                    charger["formattedAddress"],
                    style: TextStyle(color: Colors.black87),
                  ),

                  if (charger["phoneNumber"] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Phone: ${charger["phoneNumber"]}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],

                  if (charger["rating"] != null ||
                      charger["reviewCount"] != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (charger["rating"] != null)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text('${charger["rating"]}'),
                            ],
                          ),
                        if (charger["reviewCount"] != null) ...[
                          SizedBox(width: 10),
                          Text('(${charger["reviewCount"]} reviews)'),
                        ],
                      ],
                    ),
                  ],

                  SizedBox(height: 8),
                  Text(
                    'Connectors:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...charger["connectors"].map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.ev_station, size: 20, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c["type"]} - ${c["available"]}/${c["total"]} available, ${c["kw"]}kW (${c["speed"]})',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (charger["website"] != null) ...[
                    SizedBox(height: 8),
                    InkWell(
                      child: Text(
                        'Visit Website',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = charger["website"]!;
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],

                  if (charger["placeLink"] != null) ...[
                    SizedBox(height: 4),
                    InkWell(
                      child: Text(
                        'View on Google Maps',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = charger["placeLink"]!;
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],

                  Spacer(),

                  ElevatedButton.icon(
                    icon: Icon(Icons.directions, color: Colors.black),
                    label: Text(
                      'Route Now',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _startRecentRoutingTo(charger);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startRecentRoutingTo(charger) async {
    _getLocaiton();
    _determinePosition();
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location not available.')),
      );
      return;
    }

    await _positionStreamSubscription?.cancel();

    setState(() {
      _isRouting = true;
      _selectedRecentCharger = charger;
      _markers = {
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId(charger["id"]),
          position: LatLng(charger["latitude"], charger["longitude"]),
          infoWindow: InfoWindow(title: charger["name"]),
        ),
      };

      _polylines.clear();
      polylineCoordinates.clear();
    });

    final polylinePoints = PolylinePoints(apiKey: googleApiKey);
    final v2Response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(charger["latitude"], charger["longitude"]),
        travelMode: TravelMode.driving,
      ),
    );
    final legacyResult = polylinePoints.convertToLegacyResult(v2Response);

    if (legacyResult.points.isNotEmpty) {
      for (var point in legacyResult.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.teal,
            width: 6,
            points: polylineCoordinates,
          ),
        );
      });
    } else {
      print('Error fetching route: ${legacyResult.errorMessage}');
    }

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 14));

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          _currentPosition = position;

          LatLng currentLatLng = LatLng(position.latitude, position.longitude);

          setState(() {
            _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
            _markers.add(
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentLatLng,
                infoWindow: InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            );
          });

          await controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));

          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            charger["latitude"],
            charger["longitude"],
          );

          if (distance < 100) {
            await _positionStreamSubscription?.cancel();

            setState(() {
              _isRouting = false;
              _selectedCharger = null;
              _polylines.clear();
              polylineCoordinates.clear();
            });

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('You have reached your destination!'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _loadRecentChargers();
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_initialPosition, 14),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        });
  }

  void _showChargerBottomSheetSearch(DatumSearch charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 460,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charger.name ?? "Unknown Charger",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  if (charger.photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        charger.photo!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  SizedBox(height: 8),
                  Text(
                    charger.formattedAddress ?? "No address provided",
                    style: TextStyle(color: Colors.black87),
                  ),

                  if (charger.phoneNumber != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Phone: ${charger.phoneNumber}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],

                  if (charger.rating != null ||
                      charger.reviewCount != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (charger.rating != null)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text('${charger.rating}'),
                            ],
                          ),
                        if (charger.reviewCount != null) ...[
                          SizedBox(width: 10),
                          Text('(${charger.reviewCount} reviews)'),
                        ],
                      ],
                    ),
                  ],

                  SizedBox(height: 8),
                  Text(
                    'Connectors:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...?charger.connectors?.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.ev_station, size: 20, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c.type ?? "-"} - ${c.available ?? 0}/${c.total ?? 0} available, ${c.kw ?? 0}kW (${c.speed ?? "-"})',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (charger.website != null) ...[
                    SizedBox(height: 8),
                    InkWell(
                      child: Text(
                        'Visit Website',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = Uri.parse(charger.website!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ],

                  if (charger.placeLink != null) ...[
                    SizedBox(height: 4),
                    InkWell(
                      child: Text(
                        'View on Google Maps',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = Uri.parse(charger.placeLink!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ],

                  Spacer(),
                  ElevatedButton.icon(
                    icon: Icon(Icons.favorite, color: Colors.black),
                    label: Text(
                      'Add to Favourite',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      saveFavouriteRouteToDbSearch(charger);
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.directions, color: Colors.black),
                    label: Text(
                      'Route Now',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _startRoutingToSearch(charger);
                      saveRecentRouteToDbSearch(charger);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void saveRecentRouteToDb(Datum charger) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();

    List recents = List.from(info["recents"] ?? []);

    recents.add({
      'id': charger.id,
      'name': charger.name,
      'photo': charger.photo,
      'formattedAddress': charger.formattedAddress,
      'phoneNumber': charger.phoneNumber,
      'rating': charger.rating,
      'reviewCount': charger.reviewCount,
      'connectors': charger.connectors.map(
        (connector) => {
          'type': connector.type,
          'available': connector.available,
          'total': connector.total,
          'kw': connector.kw,
          'speed': connector.speed,
        },
      ),
      'website': charger.website,
      'placeLink': charger.placeLink,
      'latitude': charger.latitude,
      'longitude': charger.longitude,
    });

    await FirebaseFirestore.instance.collection("account").doc(uid).update({
      "recents": recents,
    });
  }

  void saveFavouriteRouteToDb(Datum charger) async {
    _polylines.clear();
    polylineCoordinates.clear();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();

    List favourites = List.from(info["favourites"] ?? []);

    favourites.add({
      'id': charger.id,
      'name': charger.name,
      'photo': charger.photo,
      'formattedAddress': charger.formattedAddress,
      'phoneNumber': charger.phoneNumber,
      'rating': charger.rating,
      'reviewCount': charger.reviewCount,
      'connectors': charger.connectors.map(
        (connector) => {
          'type': connector.type,
          'available': connector.available,
          'total': connector.total,
          'kw': connector.kw,
          'speed': connector.speed,
        },
      ),
      'website': charger.website,
      'placeLink': charger.placeLink,
      'latitude': charger.latitude,
      'longitude': charger.longitude,
    });

    await FirebaseFirestore.instance.collection("account").doc(uid).update({
      "favourites": favourites,
    });
  }

  void _showChargerBottomSheet(Datum charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 460,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charger.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  if (charger.photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        charger.photo!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  SizedBox(height: 8),
                  Text(
                    charger.formattedAddress,
                    style: TextStyle(color: Colors.black87),
                  ),

                  if (charger.phoneNumber != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Phone: ${charger.phoneNumber}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],

                  if (charger.rating != null ||
                      charger.reviewCount != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (charger.rating != null)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text('${charger.rating}'),
                            ],
                          ),
                        if (charger.reviewCount != null) ...[
                          SizedBox(width: 10),
                          Text('(${charger.reviewCount} reviews)'),
                        ],
                      ],
                    ),
                  ],

                  SizedBox(height: 8),
                  Text(
                    'Connectors:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...charger.connectors.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.ev_station, size: 20, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c.type} - ${c.available}/${c.total} available, ${c.kw}kW (${c.speed})',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (charger.website != null) ...[
                    SizedBox(height: 8),
                    InkWell(
                      child: Text(
                        'Visit Website',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = charger.website!;
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],

                  if (charger.placeLink != null) ...[
                    SizedBox(height: 4),
                    InkWell(
                      child: Text(
                        'View on Google Maps',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        final url = charger.placeLink!;
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                    ),
                  ],

                  Spacer(),
                  ElevatedButton.icon(
                    icon: Icon(Icons.favorite, color: Colors.black),
                    label: Text(
                      'Add to Favourite',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      saveFavouriteRouteToDb(charger);
                    },
                  ),
                  SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: Icon(Icons.directions, color: Colors.black),
                    label: Text(
                      'Route Now',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _startRoutingTo(charger);
                      saveRecentRouteToDb(charger);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startRoutingToSearch(DatumSearch charger) async {
    _getLocaiton();
    _determinePosition();
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location not available.')),
      );
      return;
    }

    await _positionStreamSubscription?.cancel();

    setState(() {
      _isRouting = true;
      _selectedChargerSearch = charger;

      _markers = {
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId(charger.id ?? ""),
          position: LatLng(charger.latitude ?? 0.0, charger.longitude ?? 0.0),
          infoWindow: InfoWindow(title: charger.name),
        ),
      };

      _polylines.clear();
      polylineCoordinates.clear();
    });

    final polylinePoints = PolylinePoints(apiKey: googleApiKey);
    final v2Response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(
          charger.latitude ?? 0.0,
          charger.longitude ?? 0.0,
        ),
        travelMode: TravelMode.driving,
      ),
    );
    final legacyResult = polylinePoints.convertToLegacyResult(v2Response);

    if (legacyResult.points.isNotEmpty) {
      for (var point in legacyResult.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.teal,
            width: 6,
            points: polylineCoordinates,
          ),
        );
      });
    } else {
      print('Error fetching route: ${legacyResult.errorMessage}');
    }

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 14));

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          _currentPosition = position;

          LatLng currentLatLng = LatLng(position.latitude, position.longitude);

          setState(() {
            _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
            _markers.add(
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentLatLng,
                infoWindow: InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            );
          });

          await controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));

          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            charger.latitude ?? 0.0,
            charger.longitude ?? 0.0,
          );

          if (distance < 100) {
            await _positionStreamSubscription?.cancel();

            setState(() {
              _isRouting = false;
              _selectedCharger = null;
              _polylines.clear();
              polylineCoordinates.clear();
            });

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('You have reached your destination!'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _restoreAllChargers();
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_initialPosition, 14),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        });
  }

  Future<void> _startRoutingTo(Datum charger) async {
    _getLocaiton();
    _determinePosition();
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location not available.')),
      );
      return;
    }

    await _positionStreamSubscription?.cancel();

    setState(() {
      _isRouting = true;
      _selectedCharger = charger;
      _markers = {
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId(charger.id),
          position: LatLng(charger.latitude, charger.longitude),
          infoWindow: InfoWindow(title: charger.name),
        ),
      };

      _polylines.clear();
      polylineCoordinates.clear();
    });

    final polylinePoints = PolylinePoints(apiKey: googleApiKey);
    final v2Response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(charger.latitude, charger.longitude),
        travelMode: TravelMode.driving,
      ),
    );
    final legacyResult = polylinePoints.convertToLegacyResult(v2Response);

    if (legacyResult.points.isNotEmpty) {
      for (var point in legacyResult.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.teal,
            width: 6,
            points: polylineCoordinates,
          ),
        );
      });
    } else {
      print('Error fetching route: ${legacyResult.errorMessage}');
    }

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 14));

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          _currentPosition = position;

          LatLng currentLatLng = LatLng(position.latitude, position.longitude);

          setState(() {
            _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
            _markers.add(
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentLatLng,
                infoWindow: InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            );
          });

          await controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));

          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            charger.latitude,
            charger.longitude,
          );

          if (distance < 100) {
            await _positionStreamSubscription?.cancel();

            setState(() {
              _isRouting = false;
              _selectedCharger = null;
              _polylines.clear();
              polylineCoordinates.clear();
            });

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('You have reached your destination!'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _restoreAllChargers();
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_initialPosition, 14),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        });
  }

  Future<void> _restoreAllChargers() async {
    String typeContent = "";

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final engine =
        data?['vehicle']?['specifications']?['generalInformation']?['modificationEngine'];
    RegExp regex = RegExp(r'^(\d+)\s*kWh');
    Match? engineMacth = regex.firstMatch(engine);
    if (engineMacth != null) {
      int kWhValue = int.parse(engineMacth.group(1)!);
      if (kWhValue >= 60 && kWhValue <= 200) {
        typeContent += "Tesla,";
      }
      if (kWhValue >= 10 && kWhValue <= 80) {
        typeContent += "Type 2,";
      }
      if (kWhValue >= 50 && kWhValue <= 350) {
        typeContent += "CCS,";
      }
    }
    userLocation = await _getLocaiton();
    print("""
    ==============================
        ==============================
            ==============================
            Type : $typeContent
                ==============================
                    ==============================
                        ==============================
                            ==============================
    """);
    final chargers = await HttpServicePort.getCarparks(
      typeContent,
      userLocation!.latitude,
      userLocation!.longitude,
    );
    if (chargers != null) {
      final Set<Marker> allMarkers = chargers.map((charger) {
        return Marker(
          markerId: MarkerId(charger.id),
          position: LatLng(charger.latitude, charger.longitude),
          infoWindow: InfoWindow(title: charger.name),
          onTap: () => _showChargerBottomSheet(charger),
        );
      }).toSet();

      setState(() {
        _markers = allMarkers;
      });
    }
  }

  Future<void> _endRoute() async {
    await _positionStreamSubscription?.cancel();

    setState(() {
      _isRouting = false;
      _selectedCharger = null;
      _polylines.clear();
      polylineCoordinates.clear();
    });

    await _restoreAllChargers();

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 14));
  }

  void saveRecentRouteToDbSearch(DatumSearch charger) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();

    List recents = List.from(info["recents"] ?? []);

    recents.add({
      'id': charger.id,
      'name': charger.name,
      'photo': charger.photo,
      'formattedAddress': charger.formattedAddress,
      'phoneNumber': charger.phoneNumber,
      'rating': charger.rating,
      'reviewCount': charger.reviewCount,
      'connectors': charger.connectors?.map(
        (connector) => {
          'type': connector.type,
          'available': connector.available,
          'total': connector.total,
          'kw': connector.kw,
          'speed': connector.speed,
        },
      ),
      'website': charger.website,
      'placeLink': charger.placeLink,
      'latitude': charger.latitude,
      'longitude': charger.longitude,
    });

    await FirebaseFirestore.instance.collection("account").doc(uid).update({
      "recents": recents,
    });
  }

  void saveFavouriteRouteToDbSearch(DatumSearch charger) async {
    _polylines.clear();
    polylineCoordinates.clear();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();

    List favourites = List.from(info["favourites"] ?? []);

    favourites.add({
      'id': charger.id,
      'name': charger.name,
      'photo': charger.photo,
      'formattedAddress': charger.formattedAddress,
      'phoneNumber': charger.phoneNumber,
      'rating': charger.rating,
      'reviewCount': charger.reviewCount,
      'connectors': charger.connectors
          ?.map(
            (connector) => {
              'type': connector.type.toString(),
              'available': connector.available,
              'total': connector.total,
              'kw': connector.kw,
              'speed': connector.speed.toString(),
            },
          )
          .toList(),
      'website': charger.website,
      'placeLink': charger.placeLink,
      'latitude': charger.latitude,
      'longitude': charger.longitude,
    });

    await FirebaseFirestore.instance.collection("account").doc(uid).update({
      "favourites": favourites,
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    if (!_isLoadingLocation && _locationPermissionGranted) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 14),
      );
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFE3F2FD),
          foregroundColor: Colors.black87,
          title: Text("EV Chargers Near You"),
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        color: Color(0xFFE3F2FD),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: true,
              markers: _markers,
              polylines: _polylines,
            ),

            if (_isRouting)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.stop),
                  label: Text('End Route'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    final shouldEnd = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('End Route?'),
                        content: Text(
                          'Are you sure you want to end the route?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('End'),
                          ),
                        ],
                      ),
                    );

                    if (shouldEnd == true) {
                      await _endRoute();
                    }
                  },
                ),
              ),

            Container(
              margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchAreaController,
                  decoration: InputDecoration(
                    hintText: 'Enter something...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        final value = searchAreaController.text.trim();
                        if (value.isNotEmpty) {
                          await searchByArea(value);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 10,
              bottom: 20,
              child: Container(
                width: 60,
                height: 400,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        showFilterBottomSheet();
                      },
                      icon: const Icon(Icons.filter_alt),
                    ),
                    SizedBox(height: 10),
                    IconButton(
                      onPressed: () async {
                        areaQuery.clear();
                        await _loadFavouriteChargers();
                      },
                      icon: const Icon(Icons.favorite),
                    ),
                    SizedBox(height: 10),

                    IconButton(
                      onPressed: () {
                        _loadChargers();
                      },
                      icon: const Icon(Icons.map),
                    ),

                    SizedBox(height: 10),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAccountScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                    ),
                    SizedBox(height: 10),

                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
