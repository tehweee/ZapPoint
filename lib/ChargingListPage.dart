import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HttpService.dart';
import 'Chargers.dart';
import 'RouteScreen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class ChargerListScreen extends StatefulWidget {
  @override
  _ChargerListScreenState createState() => _ChargerListScreenState();
}

class _ChargerListScreenState extends State<ChargerListScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  LatLng _initialPosition = LatLng(1.438, 103.786);

  bool _locationPermissionGranted = false;
  bool _isLoadingLocation = true;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  Datum? _selectedCharger;
  bool _isRouting = false;

  final String googleApiKey = 'AIzaSyDpwW-F7znMozHqzomo1q24dNhJ2G9I5Bs';

  @override
  void initState() {
    super.initState();
    _determinePosition();
    // _loadChargers();
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
    final chargers = await HttpService.getCarparks();
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

  void _showChargerBottomSheet(Datum charger) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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

              if (charger.rating != null || charger.reviewCount != null) ...[
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
                icon: Icon(Icons.directions, color: Colors.black),
                label: Text('Route Now', style: TextStyle(color: Colors.black)),
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startRoutingTo(Datum charger) async {
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

          if (distance < 20) {
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
    final chargers = await HttpService.getCarparks();
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
      appBar: AppBar(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Colors.black87,
        title: Text("EV Chargers Near You"),
        elevation: 0,
      ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Color(0xFF1A1A40),
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.login),
        backgroundColor: const Color(0xFFFFDD00), // Yellow background
        foregroundColor: const Color(0xFF1A1A40), // Dark blue icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
