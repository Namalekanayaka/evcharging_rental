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
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ),
    );
  }
}
