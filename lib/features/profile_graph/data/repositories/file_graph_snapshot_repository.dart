import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';

class FileGraphSnapshotRepository implements GraphSnapshotRepository {
  @override
  Future<void> saveSnapshot(GraphSnapshot snapshot) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Graph Snapshot',
      fileName: 'graph_snapshot.lmsn',
      type: FileType.custom,
      allowedExtensions: ['lmsn'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      final jsonString = jsonEncode(snapshot.toJson());
      await file.writeAsString(jsonString);
    }
  }

  @override
  Future<GraphSnapshot?> loadSnapshot() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['lmsn'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GraphSnapshot.fromJson(jsonMap);
    }
    return null;
  }
}
