// To parse this JSON data, do
//
//     final getVehicleDetails = getVehicleDetailsFromJson(jsonString);

import 'dart:convert';

GetVehicleDetails getVehicleDetailsFromJson(String str) =>
    GetVehicleDetails.fromJson(json.decode(str));

String getVehicleDetailsToJson(GetVehicleDetails data) =>
    json.encode(data.toJson());

class GetVehicleDetails {
  String? id;
  String? title;
  String? mainImage;
  List<OtherImage>? otherImages;
  Specifications? specifications;

  GetVehicleDetails({
    this.id,
    this.title,
    this.mainImage,
    this.otherImages,
    this.specifications,
  });

  factory GetVehicleDetails.fromJson(Map<String, dynamic> json) =>
      GetVehicleDetails(
        id: json["id"],
        title: json["title"],
        mainImage: json["main_image"],
        otherImages: json["other_images"] == null
            ? []
            : List<OtherImage>.from(
                json["other_images"]!.map((x) => OtherImage.fromJson(x)),
              ),
        specifications: json["specifications"] == null
            ? null
            : Specifications.fromJson(json["specifications"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "main_image": mainImage,
    "other_images": otherImages == null
        ? []
        : List<dynamic>.from(otherImages!.map((x) => x.toJson())),
    "specifications": specifications?.toJson(),
  };
}

class OtherImage {
  String? alt;
  String? src;

  OtherImage({this.alt, this.src});

  factory OtherImage.fromJson(Map<String, dynamic> json) =>
      OtherImage(alt: json["alt"], src: json["src"]);

  Map<String, dynamic> toJson() => {"alt": alt, "src": src};
}

class Specifications {
  String? title;
  GeneralInformation? generalInformation;
  PerformanceSpecs? performanceSpecs;
  EngineSpecs? engineSpecs;
  SpaceVolumeWeights? spaceVolumeWeights;
  Dimensions? dimensions;
  DrivetrainBrakesSuspensionSpecs? drivetrainBrakesSuspensionSpecs;

  Specifications({
    this.title,
    this.generalInformation,
    this.performanceSpecs,
    this.engineSpecs,
    this.spaceVolumeWeights,
    this.dimensions,
    this.drivetrainBrakesSuspensionSpecs,
  });

  factory Specifications.fromJson(Map<String, dynamic> json) => Specifications(
    title: json["title"],
    generalInformation: json["general_information"] == null
        ? null
        : GeneralInformation.fromJson(json["general_information"]),
    performanceSpecs: json["performance_specs"] == null
        ? null
        : PerformanceSpecs.fromJson(json["performance_specs"]),
    engineSpecs: json["engine_specs"] == null
        ? null
        : EngineSpecs.fromJson(json["engine_specs"]),
    spaceVolumeWeights: json["space_volume_weights"] == null
        ? null
        : SpaceVolumeWeights.fromJson(json["space_volume_weights"]),
    dimensions: json["dimensions"] == null
        ? null
        : Dimensions.fromJson(json["dimensions"]),
    drivetrainBrakesSuspensionSpecs:
        json["drivetrain_brakes_suspension_specs"] == null
        ? null
        : DrivetrainBrakesSuspensionSpecs.fromJson(
            json["drivetrain_brakes_suspension_specs"],
          ),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "general_information": generalInformation?.toJson(),
    "performance_specs": performanceSpecs?.toJson(),
    "engine_specs": engineSpecs?.toJson(),
    "space_volume_weights": spaceVolumeWeights?.toJson(),
    "dimensions": dimensions?.toJson(),
    "drivetrain_brakes_suspension_specs": drivetrainBrakesSuspensionSpecs
        ?.toJson(),
  };
}

class Dimensions {
  String? length;
  String? width;
  String? height;
  String? wheelbase;
  String? rideHeightGroundClearance;

  Dimensions({
    this.length,
    this.width,
    this.height,
    this.wheelbase,
    this.rideHeightGroundClearance,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    length: json["Length"],
    width: json["Width"],
    height: json["Height"],
    wheelbase: json["Wheelbase"],
    rideHeightGroundClearance: json["Ride height (ground clearance)"],
  );

  Map<String, dynamic> toJson() => {
    "Length": length,
    "Width": width,
    "Height": height,
    "Wheelbase": wheelbase,
    "Ride height (ground clearance)": rideHeightGroundClearance,
  };
}

class DrivetrainBrakesSuspensionSpecs {
  String? drivetrainArchitecture;
  String? driveWheel;
  String? numberOfGearsAndTypeOfGearbox;
  String? frontSuspension;
  String? rearSuspension;
  String? frontBrakes;
  String? rearBrakes;
  String? assistingSystems;
  String? steeringType;
  String? powerSteering;
  String? tiresSize;
  String? wheelRimsSize;

  DrivetrainBrakesSuspensionSpecs({
    this.drivetrainArchitecture,
    this.driveWheel,
    this.numberOfGearsAndTypeOfGearbox,
    this.frontSuspension,
    this.rearSuspension,
    this.frontBrakes,
    this.rearBrakes,
    this.assistingSystems,
    this.steeringType,
    this.powerSteering,
    this.tiresSize,
    this.wheelRimsSize,
  });

  factory DrivetrainBrakesSuspensionSpecs.fromJson(Map<String, dynamic> json) =>
      DrivetrainBrakesSuspensionSpecs(
        drivetrainArchitecture: json["Drivetrain Architecture"],
        driveWheel: json["Drive wheel"],
        numberOfGearsAndTypeOfGearbox:
            json["Number of gears and type of gearbox"],
        frontSuspension: json["Front suspension"],
        rearSuspension: json["Rear suspension"],
        frontBrakes: json["Front brakes"],
        rearBrakes: json["Rear brakes"],
        assistingSystems: json["Assisting systems"],
        steeringType: json["Steering type"],
        powerSteering: json["Power steering"],
        tiresSize: json["Tires size"],
        wheelRimsSize: json["Wheel rims size"],
      );

  Map<String, dynamic> toJson() => {
    "Drivetrain Architecture": drivetrainArchitecture,
    "Drive wheel": driveWheel,
    "Number of gears and type of gearbox": numberOfGearsAndTypeOfGearbox,
    "Front suspension": frontSuspension,
    "Rear suspension": rearSuspension,
    "Front brakes": frontBrakes,
    "Rear brakes": rearBrakes,
    "Assisting systems": assistingSystems,
    "Steering type": steeringType,
    "Power steering": powerSteering,
    "Tires size": tiresSize,
    "Wheel rims size": wheelRimsSize,
  };
}

class EngineSpecs {
  EngineSpecs();

  factory EngineSpecs.fromJson(Map<String, dynamic> json) => EngineSpecs();

  Map<String, dynamic> toJson() => {};
}

class GeneralInformation {
  String? brand;
  String? model;
  String? generation;
  String? modificationEngine;
  String? startOfProduction;
  String? powertrainArchitecture;
  String? bodyType;
  String? seats;
  String? doors;

  GeneralInformation({
    this.brand,
    this.model,
    this.generation,
    this.modificationEngine,
    this.startOfProduction,
    this.powertrainArchitecture,
    this.bodyType,
    this.seats,
    this.doors,
  });

  factory GeneralInformation.fromJson(Map<String, dynamic> json) =>
      GeneralInformation(
        brand: json["Brand"],
        model: json["Model"],
        generation: json["Generation"],
        modificationEngine: json["Modification (Engine)"],
        startOfProduction: json["Start of production"],
        powertrainArchitecture: json["Powertrain Architecture"],
        bodyType: json["Body type"],
        seats: json["Seats"],
        doors: json["Doors"],
      );

  Map<String, dynamic> toJson() => {
    "Brand": brand,
    "Model": model,
    "Generation": generation,
    "Modification (Engine)": modificationEngine,
    "Start of production": startOfProduction,
    "Powertrain Architecture": powertrainArchitecture,
    "Body type": bodyType,
    "Seats": seats,
    "Doors": doors,
  };
}

class PerformanceSpecs {
  String? fuelType;
  String? acceleration0100KmH;
  String? acceleration062Mph;
  String? acceleration060MphCalculatedByAutoDataNet;
  String? maximumSpeed;
  String? weightToPowerRatio;
  String? weightToTorqueRatio;

  PerformanceSpecs({
    this.fuelType,
    this.acceleration0100KmH,
    this.acceleration062Mph,
    this.acceleration060MphCalculatedByAutoDataNet,
    this.maximumSpeed,
    this.weightToPowerRatio,
    this.weightToTorqueRatio,
  });

  factory PerformanceSpecs.fromJson(Map<String, dynamic> json) =>
      PerformanceSpecs(
        fuelType: json["Fuel Type"],
        acceleration0100KmH: json["Acceleration 0 - 100 km/h"],
        acceleration062Mph: json["Acceleration 0 - 62 mph"],
        acceleration060MphCalculatedByAutoDataNet:
            json["Acceleration 0 - 60 mph (Calculated by Auto-Data.net)"],
        maximumSpeed: json["Maximum speed"],
        weightToPowerRatio: json["Weight-to-power ratio"],
        weightToTorqueRatio: json["Weight-to-torque ratio"],
      );

  Map<String, dynamic> toJson() => {
    "Fuel Type": fuelType,
    "Acceleration 0 - 100 km/h": acceleration0100KmH,
    "Acceleration 0 - 62 mph": acceleration062Mph,
    "Acceleration 0 - 60 mph (Calculated by Auto-Data.net)":
        acceleration060MphCalculatedByAutoDataNet,
    "Maximum speed": maximumSpeed,
    "Weight-to-power ratio": weightToPowerRatio,
    "Weight-to-torque ratio": weightToTorqueRatio,
  };
}

class SpaceVolumeWeights {
  String? kerbWeight;
  String? trunkBootSpaceMinimum;
  String? trunkBootSpaceMaximum;

  SpaceVolumeWeights({
    this.kerbWeight,
    this.trunkBootSpaceMinimum,
    this.trunkBootSpaceMaximum,
  });

  factory SpaceVolumeWeights.fromJson(Map<String, dynamic> json) =>
      SpaceVolumeWeights(
        kerbWeight: json["Kerb Weight"],
        trunkBootSpaceMinimum: json["Trunk (boot) space - minimum"],
        trunkBootSpaceMaximum: json["Trunk (boot) space - maximum"],
      );

  Map<String, dynamic> toJson() => {
    "Kerb Weight": kerbWeight,
    "Trunk (boot) space - minimum": trunkBootSpaceMinimum,
    "Trunk (boot) space - maximum": trunkBootSpaceMaximum,
  };
}
