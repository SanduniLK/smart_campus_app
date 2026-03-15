import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String role;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });
  
  @override
  List<Object?> get props => [email, password, fullName, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthEmailVerified extends AuthEvent {}