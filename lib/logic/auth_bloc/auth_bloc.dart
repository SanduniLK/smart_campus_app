import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthEmailVerified>(_onEmailVerified);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = FirebaseService.currentUser;
      
      if (user != null) {
        if (user.emailVerified) {
          final userData = await DatabaseService().getUserByUid(user.uid);
          
          emit(AuthAuthenticated(
            userId: user.uid,
            userRole: userData?['role'] ?? 'student',
            userName: user.displayName ?? 'User',
          ));
        } else {
          emit(AuthEmailVerificationRequired(user.email!));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await FirebaseService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        if (user.emailVerified) {
          final userData = await DatabaseService().getUserByUid(user.uid);
          
          emit(AuthAuthenticated(
            userId: user.uid,
            userRole: userData?['role'] ?? 'student',
            userName: user.displayName ?? 'User',
          ));
        } else {
          emit(AuthEmailVerificationRequired(user.email!));
        }
      } else {
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // After signup, verification required
    emit(AuthEmailVerificationRequired(event.email));
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await FirebaseService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout: $e'));
    }
  }

  Future<void> _onEmailVerified(
    AuthEmailVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final userData = await DatabaseService().getUserByUid(user.uid);
        
        emit(AuthAuthenticated(
          userId: user.uid,
          userRole: userData?['role'] ?? 'student',
          userName: user.displayName ?? 'User',
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to load user data: $e'));
    }
  }
}