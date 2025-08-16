import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'GetVehicles.dart';
import 'httpservice_vehicle.dart' hide HttpServiceVehicles;
import 'httpservice_vehicledetails.dart';
import 'httpservice_vehicle.dart';
import 'GetVehicleDetails.dart';
import 'ChargingListPage.dart';

class SelectVehiclePage extends StatefulWidget {
  const SelectVehiclePage({Key? key}) : super(key: key);

  @override
  _SelectVehiclePageState createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  List<Result> vehicles = [];
  Result? selectedVehicle;
  bool isLoading = true;
  @override
  @override
  void initState() {
    super.initState();
    _checkVehicle();
  }

  void _checkVehicle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final userVehicle = data?['vehicle'];

    _loadVehicles(userVehicle);
  }

  Future<void> _loadVehicles(userVehicle) async {
    final data = await HttpServiceVehicles.getVehicles();
    if (mounted) {
      setState(() {
        vehicles = data ?? [];
        selectedVehicle = vehicles.isNotEmpty ? vehicles[0] : null;
        isLoading = false;
      });
    }
  }

  Future<void> addVehicle(carId) async {
    GetVehicleDetails? vehicle =
        await HttpServiceVehicleDetails.getVehicleDetails(selectedVehicle?.id);

    final uid = await FirebaseAuth.instance.currentUser?.uid;
    final vehicleData = {
      'id': vehicle!.id,
      'title': selectedVehicle!.title,
      'content': selectedVehicle!.content,
      'additional': selectedVehicle!.additional,
      'wr': selectedVehicle!.wr,

      'mainImage': vehicle.mainImage,
      'otherImages': vehicle.otherImages!
          .map((img) => {'alt': img.alt, 'src': img.src})
          .toList(),

      'specifications': {
        'title': vehicle.specifications!.title,

        'generalInformation': {
          'brand': vehicle.specifications!.generalInformation!.brand,
          'model': vehicle.specifications!.generalInformation!.model,
          'generation': vehicle.specifications!.generalInformation!.generation,
          'modificationEngine':
              vehicle.specifications!.generalInformation!.modificationEngine,
          'startOfProduction':
              vehicle.specifications!.generalInformation!.startOfProduction,
          'powertrainArchitecture': vehicle
              .specifications!
              .generalInformation!
              .powertrainArchitecture,
          'bodyType': vehicle.specifications!.generalInformation!.bodyType,
          'seats': vehicle.specifications!.generalInformation!.seats,
          'doors': vehicle.specifications!.generalInformation!.doors,
        },

        'performanceSpecs': {
          'fuelType': vehicle.specifications!.performanceSpecs!.fuelType,
          'acceleration0100KmH':
              vehicle.specifications!.performanceSpecs!.acceleration0100KmH,
          'acceleration062Mph':
              vehicle.specifications!.performanceSpecs!.acceleration062Mph,
          'acceleration060MphCalculatedByAutoDataNet': vehicle
              .specifications!
              .performanceSpecs!
              .acceleration060MphCalculatedByAutoDataNet,
          'maximumSpeed':
              vehicle.specifications!.performanceSpecs!.maximumSpeed,
          'weightToPowerRatio':
              vehicle.specifications!.performanceSpecs!.weightToPowerRatio,
          'weightToTorqueRatio':
              vehicle.specifications!.performanceSpecs!.weightToTorqueRatio,
        },

        'dimensions': {
          'length': vehicle.specifications!.dimensions!.length,
          'width': vehicle.specifications!.dimensions!.width,
          'height': vehicle.specifications!.dimensions!.height,
          'wheelbase': vehicle.specifications!.dimensions!.wheelbase,
          'rideHeightGroundClearance':
              vehicle.specifications!.dimensions!.rideHeightGroundClearance,
        },

        'drivetrainBrakesSuspensionSpecs': {
          'drivetrainArchitecture': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .drivetrainArchitecture,
          'driveWheel': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .driveWheel,
          'numberOfGearsAndTypeOfGearbox': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .numberOfGearsAndTypeOfGearbox,
          'frontSuspension': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .frontSuspension,
          'rearSuspension': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .rearSuspension,
          'frontBrakes': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .frontBrakes,
          'rearBrakes': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .rearBrakes,
          'assistingSystems': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .assistingSystems,
          'steeringType': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .steeringType,
          'powerSteering': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .powerSteering,
          'tiresSize': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .tiresSize,
          'wheelRimsSize': vehicle
              .specifications!
              .drivetrainBrakesSuspensionSpecs!
              .wheelRimsSize,
        },

        'spaceVolumeWeights': {
          'kerbWeight': vehicle.specifications!.spaceVolumeWeights!.kerbWeight,
          'trunkBootSpaceMinimum':
              vehicle.specifications!.spaceVolumeWeights!.trunkBootSpaceMinimum,
          'trunkBootSpaceMaximum':
              vehicle.specifications!.spaceVolumeWeights!.trunkBootSpaceMaximum,
        },
      },
    };
    await FirebaseFirestore.instance.collection('account').doc(uid).update({
      'vehicle': vehicleData,
    });
  }

  Future<String?> getVehicleTitle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['title'] as String?;
  }

  Future<String?> getVehicleAdditional() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['additional'] as String?;
  }

  Future<String?> getVehicleContent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['content'] as String?;
  }

  Future<String?> getVehicleId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['id'] as String?;
  }

  Future<String?> getVehicleImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['mainImage'] as String;
  }

  Future<String?> getVehicleWR() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['wr'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF00BFFF);
    const darkTextColor = Color(0xFF1A1A40);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkTextColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChargerListScreen()),
            );
          },
        ),
        title: const Text(
          'Select Vehicle',
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await addVehicle(selectedVehicle!.id);
        },
        label: const Text('Set Vehicle'),
        icon: const Icon(Icons.check),
        backgroundColor: const Color(0xFF00C851),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedVehicle == null
          ? const Center(child: Text('No vehicles found'))
          : Column(
              children: [
                Container(
                  color: Colors.white.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      FutureBuilder<String?>(
                        future: getVehicleImage(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(
                                selectedVehicle!.image,
                              ),
                            );
                          }

                          final imageUrl =
                              snapshot.data ?? selectedVehicle!.image;

                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(imageUrl),
                          );
                        },
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String?>(
                              future: getVehicleTitle(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(fontSize: 20),
                                  );
                                }
                                final title = snapshot.data;
                                return Text(
                                  title ?? selectedVehicle!.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String?>(
                              future: getVehicleAdditional(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(fontSize: 20),
                                  );
                                }
                                final title = snapshot.data;
                                return Text(
                                  title ?? selectedVehicle!.additional,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String?>(
                              future: getVehicleContent(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(fontSize: 20),
                                  );
                                }
                                final title = snapshot.data;
                                return Text(
                                  title ?? selectedVehicle!.content,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                );
                              },
                            ),
                            FutureBuilder<String?>(
                              future: getVehicleWR(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(fontSize: 20),
                                  );
                                }
                                final title = snapshot.data;
                                if (title != null && title.isNotEmpty) {
                                  return Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: darkTextColor,
                                    ),
                                  );
                                }
                                if (selectedVehicle != null &&
                                    selectedVehicle!.wr.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'WR: ${selectedVehicle!.wr}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: darkTextColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }
                                return const Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: darkTextColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white54, thickness: 1),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final isSelected = vehicle.id == selectedVehicle!.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVehicle = vehicle;
                          });
                        },
                        child: Card(
                          color: isSelected ? Colors.white70 : Colors.white,
                          elevation: isSelected ? 6 : 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? BorderSide(
                                    color: const Color(0xFF00C851),
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(vehicle.image),
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey[800],
                                        ),
                                      ),
                                      if (vehicle.additional.isNotEmpty)
                                        Text(
                                          vehicle.additional,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSelected
                                                ? Colors.black87
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      if (vehicle.content.isNotEmpty)
                                        Text(
                                          vehicle.content,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSelected
                                                ? Colors.black87
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      if (vehicle.wr.isNotEmpty)
                                        Text(
                                          'WR: ${vehicle.wr}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.black54
                                                : Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
