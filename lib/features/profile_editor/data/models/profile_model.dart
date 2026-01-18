import 'package:laminode_app/core/domain/entities/lami_layer.dart';
import 'package:laminode_app/core/domain/entities/lami_profile.dart';

class ProfileModel extends LamiProfile {
  ProfileModel({required super.profileName, required super.layers});

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
    List<LamiLayer> layers,
  ) {
    return ProfileModel(
      profileName: json['profileName'] ?? 'Unnamed Profile',
      layers: layers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileName': profileName,
      // Layers are stored separately in the ZIP
    };
  }
}
