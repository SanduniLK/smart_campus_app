import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthStudentSignUpRequested>(_onStudentSignUp);
    on<AuthStaffSignUpRequested>(_onStaffSignUp);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthEmailVerified>(_onEmailVerified);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onStudentSignUp(
    AuthStudentSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.signUpStudent(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        indexNumber: event.indexNumber,
        campusId: event.campusId,
        nic: event.nic,
        phone: event.phone,
        dob: event.dob,
        department: event.department,
        degree: event.degree,
        intake: event.intake,
      );
      
      if (user != null) {
        emit(AuthEmailVerificationRequired(user.email));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onStaffSignUp(
    AuthStaffSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.signUpStaff(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        staffId: event.staffId,
        faculty: event.faculty,
        department: event.department,
      );
      
      if (user != null) {
        emit(AuthEmailVerificationRequired(user.email));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEmailVerified(
    AuthEmailVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}