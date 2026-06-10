import 'package:equatable/equatable.dart';

class SplashState extends Equatable {
  const SplashState({this.isCompleted = false});

  final bool isCompleted;

  SplashState copyWith({bool? isCompleted}) {
    return SplashState(
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object> get props => [isCompleted];
}
