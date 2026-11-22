import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'services/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.carregarTema();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PrefsService.tema,
      builder: (_, modo, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Atividade JWT',
        themeMode: modo,
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}