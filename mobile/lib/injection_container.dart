import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'data/datasource/api_client.dart';
import 'data/datasources/secure_token_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/charger_repository.dart';
import 'src/modules/search/data/datasources/search_remote_data_source.dart';
import 'src/modules/search/data/repositories/search_repository.dart';
import 'src/modules/search/domain/usecases/search_usecases.dart';
import 'src/modules/search/presentation/bloc/search_bloc.dart';
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
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  // Device Info
  final deviceInfo = DeviceInfoPlugin();
  getIt.registerSingleton<DeviceInfoPlugin>(deviceInfo);

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(
      apiClient: getIt<ApiClient>(),
      tokenStorage: getIt<SecureTokenStorage>(),
      deviceInfo: getIt<DeviceInfoPlugin>(),
    ),
  );

  getIt.registerSingleton<ChargerRepository>(
    ChargerRepository(apiClient: getIt<ApiClient>()),
  );

  // Search Module
  getIt.registerSingleton<SearchRemoteDataSource>(
    SearchRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
      baseUrl: 'http://localhost:5000/api',
    ),
  );

  getIt.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(remoteDataSource: getIt<SearchRemoteDataSource>()),
  );

  // Search Use Cases
  getIt.registerSingleton<SearchNearbyChargersUseCase>(
    SearchNearbyChargersUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<GetRecommendedChargerUseCase>(
    GetRecommendedChargerUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<SearchByLocationUseCase>(
    SearchByLocationUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<GetChargerAvailabilityUseCase>(
    GetChargerAvailabilityUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<GetChargersInAreaUseCase>(
    GetChargersInAreaUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<CalculateRouteUseCase>(
    CalculateRouteUseCase(repository: getIt<SearchRepository>()),
  );

  getIt.registerSingleton<GetTrendingChargersUseCase>(
    GetTrendingChargersUseCase(repository: getIt<SearchRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ChargerBloc>(
    ChargerBloc(chargerRepository: getIt<ChargerRepository>()),
  );
  getIt.registerSingleton<SearchBloc>(
    SearchBloc(
      searchNearbyChargersUseCase: getIt<SearchNearbyChargersUseCase>(),
      getRecommendedChargerUseCase: getIt<GetRecommendedChargerUseCase>(),
      searchByLocationUseCase: getIt<SearchByLocationUseCase>(),
      getChargerAvailabilityUseCase: getIt<GetChargerAvailabilityUseCase>(),
      getChargersInAreaUseCase: getIt<GetChargersInAreaUseCase>(),
      calculateRouteUseCase: getIt<CalculateRouteUseCase>(),
      getTrendingChargersUseCase: getIt<GetTrendingChargersUseCase>(),
    ),
  );
  getIt.registerSingleton<BookingBloc>(BookingBloc());
}
