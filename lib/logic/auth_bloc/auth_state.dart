import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String userRole;
  final String userName;

  const AuthAuthenticated({
    required this.userId,
    required this.userRole,
    required this.userName,
  });
  
  @override
  List<Object?> get props => [userId, userRole, userName];
}

class AuthUnauthenticated extends AuthState {}

class AuthEmailVerificationRequired extends AuthState {
  final String email;

  const AuthEmailVerificationRequired(this.email);
  
  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}