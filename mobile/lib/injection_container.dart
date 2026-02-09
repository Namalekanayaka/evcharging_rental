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
import 'src/modules/payment/data/datasources/payment_remote_data_source.dart';
import 'src/modules/payment/data/repositories/payment_repository.dart';
import 'src/modules/payment/domain/usecases/payment_usecases.dart';
import 'src/modules/payment/presentation/bloc/payment_bloc.dart';
import 'src/modules/pricing/data/datasources/pricing_remote_data_source.dart';
import 'src/modules/pricing/data/repositories/pricing_repository.dart';
import 'src/modules/pricing/presentation/bloc/pricing_bloc.dart';
import 'src/modules/review/data/datasources/review_remote_data_source.dart';
import 'src/modules/review/data/repositories/review_repository.dart';
import 'src/modules/review/presentation/bloc/review_bloc.dart';
import 'src/modules/ai/data/datasources/ai_remote_data_source.dart';
import 'src/modules/ai/data/repositories/ai_repository.dart';
import 'src/modules/ai/presentation/bloc/ai_bloc.dart';
import 'src/modules/admin/data/datasources/admin_remote_data_source.dart';
import 'src/modules/admin/data/repositories/admin_repository.dart';
import 'src/modules/admin/presentation/bloc/admin_bloc.dart';
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

  // Payment Module
  getIt.registerSingleton<PaymentRemoteDataSource>(
    PaymentRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
      baseUrl: 'http://localhost:5000/api',
    ),
  );

  getIt.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(remoteDataSource: getIt<PaymentRemoteDataSource>()),
  );

  // Payment Use Cases
  getIt.registerSingleton<GetWalletUseCase>(
    GetWalletUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<AddMoneyUseCase>(
    AddMoneyUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<GetTransactionHistoryUseCase>(
    GetTransactionHistoryUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<GetPaymentHistoryUseCase>(
    GetPaymentHistoryUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<ProcessPaymentUseCase>(
    ProcessPaymentUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<GetPaymentDetailsUseCase>(
    GetPaymentDetailsUseCase(repository: getIt<PaymentRepository>()),
  );

  getIt.registerSingleton<RefundPaymentUseCase>(
    RefundPaymentUseCase(repository: getIt<PaymentRepository>()),
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
  getIt.registerSingleton<PaymentBloc>(
    PaymentBloc(
      getWalletUseCase: getIt<GetWalletUseCase>(),
      addMoneyUseCase: getIt<AddMoneyUseCase>(),
      getTransactionHistoryUseCase: getIt<GetTransactionHistoryUseCase>(),
      getPaymentHistoryUseCase: getIt<GetPaymentHistoryUseCase>(),
      processPaymentUseCase: getIt<ProcessPaymentUseCase>(),
      getPaymentDetailsUseCase: getIt<GetPaymentDetailsUseCase>(),
      refundPaymentUseCase: getIt<RefundPaymentUseCase>(),
    ),
  );

  // Pricing Module
  getIt.registerSingleton<PricingRemoteDataSource>(
    PricingRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
    ),
  );

  getIt.registerSingleton<PricingRepository>(
    PricingRepositoryImpl(remoteDataSource: getIt<PricingRemoteDataSource>()),
  );

  getIt.registerSingleton<PricingBloc>(
    PricingBloc(repository: getIt<PricingRepository>()),
  );

  // Review Module
  getIt.registerSingleton<ReviewRemoteDataSource>(
    ReviewRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
    ),
  );

  getIt.registerSingleton<ReviewRepository>(
    ReviewRepositoryImpl(remoteDataSource: getIt<ReviewRemoteDataSource>()),
  );

  getIt.registerSingleton<ReviewBloc>(
    ReviewBloc(repository: getIt<ReviewRepository>()),
  );

  // AI Module
  getIt.registerSingleton<AIRemoteDataSource>(
    AIRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
    ),
  );

  getIt.registerSingleton<AIRepository>(
    AIRepositoryImpl(remoteDataSource: getIt<AIRemoteDataSource>()),
  );

  getIt.registerSingleton<AIBloc>(
    AIBloc(repository: getIt<AIRepository>()),
  );

  // Admin Module
  getIt.registerSingleton<AdminRemoteDataSource>(
    AdminRemoteDataSourceImpl(
      dio: getIt<ApiClient>().dio,
    ),
  );

  getIt.registerSingleton<AdminRepository>(
    AdminRepositoryImpl(remoteDataSource: getIt<AdminRemoteDataSource>()),
  );

  getIt.registerSingleton<AdminBloc>(
    AdminBloc(repository: getIt<AdminRepository>()),
  );
}
