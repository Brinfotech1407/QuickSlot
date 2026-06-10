import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository) : super(const HomeState());

  final HomeRepository _homeRepository;

  Future<void> loadItems() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final items = await _homeRepository.getSampleItems();
      emit(
        state.copyWith(
          status: HomeStatus.success,
          items: items,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Unable to load items. Please try again.',
        ),
      );
    }
  }
}
