import 'package:dio/dio.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';

abstract class SchemaShopRemoteDataSource {
  Future<List<PluginManifestModel>> getAvailablePlugins();
  Future<List<int>> downloadAdapter(String pluginId);
  Future<Map<String, dynamic>> downloadSchema(String pluginId, String schemaId);
}

class SchemaShopRemoteDataSourceImpl implements SchemaShopRemoteDataSource {
  final Dio _dio;

  SchemaShopRemoteDataSourceImpl(this._dio);

  @override
  Future<List<PluginManifestModel>> getAvailablePlugins() async {
    final response = await _dio.get('plugins/discover');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => PluginManifestModel.fromJson(json)).toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<List<int>> downloadAdapter(String pluginId) async {
    final response = await _dio.get(
      'plugins/$pluginId/adapter',
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      return response.data as List<int>;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<Map<String, dynamic>> downloadSchema(
    String pluginId,
    String schemaId,
  ) async {
    final response = await _dio.get('plugins/$pluginId/schemas/$schemaId');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }
}
