import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/charger/charger_bloc.dart';
import 'presentation/bloc/booking/booking_bloc.dart';
import 'src/modules/search/presentation/bloc/search_bloc.dart';
import 'src/modules/payment/presentation/bloc/payment_bloc.dart';
import 'src/modules/pricing/presentation/bloc/pricing_bloc.dart';
import 'src/modules/review/presentation/bloc/review_bloc.dart';
import 'src/modules/ai/presentation/bloc/ai_bloc.dart';
import 'src/modules/admin/presentation/bloc/admin_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/auth_page.dart';
import 'presentation/pages/charger_listing_page.dart';
import 'presentation/pages/charger_detail_page.dart';
import 'presentation/pages/booking_page.dart';
import 'presentation/pages/wallet_page.dart';
import 'injection_container.dart' as di;

import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // TODO: Generate firebase_options.dart if using FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<AuthBloc>()),
        BlocProvider(create: (_) => GetIt.instance<ChargerBloc>()),
        BlocProvider(create: (_) => GetIt.instance<BookingBloc>()),
        BlocProvider(create: (_) => GetIt.instance<SearchBloc>()),
        BlocProvider(create: (_) => GetIt.instance<PaymentBloc>()),
        BlocProvider(create: (_) => GetIt.instance<PricingBloc>()),
        BlocProvider(create: (_) => GetIt.instance<ReviewBloc>()),
        BlocProvider(create: (_) => GetIt.instance<AIBloc>()),
        BlocProvider(create: (_) => GetIt.instance<AdminBloc>()),
      ],
      child: MaterialApp(
        title: 'EV Charger Rental',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/auth':
              return MaterialPageRoute(builder: (_) => const AuthPage());
            case '/chargers':
              return MaterialPageRoute(builder: (_) => const ChargerListingPage());
            case '/charger-detail':
              final chargerId = settings.arguments as int?;
              return MaterialPageRoute(
                builder: (_) => ChargerDetailPage(chargerId: chargerId ?? 0),
              );
            case '/booking':
              return MaterialPageRoute(builder: (_) => const BookingPage());
            case '/wallet':
              return MaterialPageRoute(builder: (_) => const WalletPage());
            default:
              return MaterialPageRoute(builder: (_) => const SplashPage());
          }
        },
      ),
    );
  }
}
