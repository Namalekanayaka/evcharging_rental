import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'data/datasource/api_client.dart';
import 'data/datasources/secure_token_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/charger/charger_bloc.dart';
import 'presentation/bloc/booking/booking_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Secure Storage
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<SecureTokenStorage>(
    SecureTokenStorage(secureStorage: secureStorage),
  );

  // API Client
  final apiClient = ApiClient(
    tokenStorage: getIt<SecureTokenStorage>(),
  );
  getIt.registerSingleton<ApiClient>(apiClient);

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(
      apiClient: getIt<ApiClient>(),
      tokenStorage: getIt<SecureTokenStorage>(),
    ),
  );

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ChargerBloc>(ChargerBloc());
  getIt.registerSingleton<BookingBloc>(BookingBloc());
}
