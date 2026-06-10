import '../../data/models/sample_item_model.dart';

abstract class HomeRepository {
  Future<List<SampleItemModel>> getSampleItems();
}
