import 'package:equatable/equatable.dart';

import '../../data/models/sample_item_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final List<SampleItemModel> items;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<SampleItemModel>? items,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
