import 'package:advanced_flutter/main/factories/ui/pages/next_event_page_factory.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorSchema = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        dividerTheme: const DividerThemeData(space: 0),
        appBarTheme: AppBarTheme(color: colorSchema.primaryContainer),
        brightness: Brightness.dark,
        colorScheme: colorSchema,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: makeNextEventPage(),
    );
  }
}
