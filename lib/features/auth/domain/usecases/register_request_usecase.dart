import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterRequestUseCase {
  final IAuthRepository repository;
  RegisterRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RegisterRequestParams params) {
    return repository.registerRequest(
      email: params.email,
      password: params.password,
      userName: params.userName,
    );
  }
}

class RegisterRequestParams extends Equatable {
  final String email;
  final String password;
  final String userName;
  const RegisterRequestParams({
    required this.email,
    required this.password,
    required this.userName,
  });
  @override
  List<Object?> get props => [email, password, userName];
}


