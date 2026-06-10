import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  Future<void> start() async {
    await Future<void>.delayed(AppConstants.splashDelay);
    emit(state.copyWith(isCompleted: true));
  }
}
