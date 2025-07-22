import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteScreen extends StatefulWidget {
  final LatLng start;
  final LatLng destination;

  RouteScreen({required this.start, required this.destination});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  final PolylinePoints polylinePoints = PolylinePoints();

  // Replace with your own Google Maps API key with Directions API enabled
  final String googleApiKey = 'AIzaSyDpwW-F7znMozHqzomo1q24dNhJ2G9I5Bs';

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  void _getRoute() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(widget.start.latitude, widget.start.longitude),
      PointLatLng(widget.destination.latitude, widget.destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId("route"),
          color: Colors.teal,
          width: 6,
          points: polylineCoordinates,
        ));
      });
    } else {
      print('Error fetching route: ${result.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.start,
          zoom: 14,
        ),
        markers: {
          Marker(markerId: MarkerId("start"), position: widget.start),
          Marker(markerId: MarkerId("end"), position: widget.destination),
        },
        polylines: _polylines,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
