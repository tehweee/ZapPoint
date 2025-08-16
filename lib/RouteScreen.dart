import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'const.dart';

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
  final String googleApiKey = GOOGLE_MAP_API;

  PolylinePoints get polylinePoints => PolylinePoints(apiKey: googleApiKey);
  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  void _getRoute() async {
    final v2Response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(widget.start.latitude, widget.start.longitude),
        destination: PointLatLng(
          widget.destination.latitude,
          widget.destination.longitude,
        ),
        travelMode: TravelMode.driving,
      ),
    );
    final legacyResult = polylinePoints.convertToLegacyResult(v2Response);

    if (legacyResult.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in legacyResult.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.teal,
            width: 6,
            points: polylineCoordinates,
          ),
        );
      });
    } else {
      print('Error fetching route: ${legacyResult.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: widget.start, zoom: 14),
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
