import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/router/router.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';

void main() {
  runApp(const MyApp());
}

final theme = ThemeData(
  scaffoldBackgroundColor: Style.containerColor3,
  appBarTheme: AppBarTheme(
    backgroundColor: Style.containerColor3,
    foregroundColor: Style.containerColor2,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<AppData>(create: (_) => AppData())],
      child: MaterialApp.router(
        theme: theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
