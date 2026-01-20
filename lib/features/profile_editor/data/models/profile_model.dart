import 'package:laminode_app/core/domain/entities/lami_profile.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

class ProfileModel {
  final String profileName;
  final List<LamiLayerEntry> layers;

  ProfileModel({required this.profileName, required this.layers});

  factory ProfileModel.fromEntity(LamiProfile<LamiLayerEntry> entity) {
    return ProfileModel(profileName: entity.profileName, layers: entity.layers);
  }

  LamiProfile<LamiLayerEntry> toEntity() {
    return LamiProfile<LamiLayerEntry>(
      profileName: profileName,
      layers: layers,
    );
  }

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
    List<LamiLayerEntry> layers,
  ) {
    return ProfileModel(
      profileName: json['profileName'] ?? 'Unnamed Profile',
      layers: layers,
    );
  }

  Map<String, dynamic> toJson() {
    return {'profileName': profileName};
  }
}
