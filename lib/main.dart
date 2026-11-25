import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'viewmodels/weather_view_model.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CuacaKitaApp());
}

class CuacaKitaApp extends StatefulWidget {
  const CuacaKitaApp({super.key});

  @override
  State<CuacaKitaApp> createState() => _CuacaKitaAppState();
}

class _CuacaKitaAppState extends State<CuacaKitaApp> {
  late final WeatherViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WeatherViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca Kita',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeScreen(viewModel: _viewModel),
    );
  }
}
