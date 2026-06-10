import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/sample_item_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<SampleItemModel>> getSampleItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const [
      SampleItemModel(
        id: 1,
        title: 'Clean Architecture',
        description:
            'Feature-first folders with core services shared app-wide.',
      ),
      SampleItemModel(
        id: 2,
        title: 'Bloc/Cubit Ready',
        description: 'Predictable loading, success, and error state handling.',
      ),
      SampleItemModel(
        id: 3,
        title: 'API Layer',
        description: 'Dio client, interceptors, storage-backed token support.',
      ),
    ];

    // Example API usage:
    // final response = await _dioClient.get('/posts');
    // return (response.data as List<dynamic>)
    //     .take(10)
    //     .map((json) => SampleItemModel.fromJson(json as Map<String, dynamic>))
    //     .toList();
  }
}
