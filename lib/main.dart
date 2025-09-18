import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/map_bloc/map_bloc.dart';
// import 'package:web_flutter/bloc/notification_bloc/notification_bloc.dart'; // À réactiver après corrections
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/router/router.dart';
import 'package:web_flutter/widget/error/favorite_error_widget.dart';
import 'package:web_flutter/widget/websocket/simple_websocket_initializer.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/service/cache/conversation_cache_service.dart';
import 'package:web_flutter/util/json_constructors_registry.dart';

void main() async {
  // Initialiser les constructeurs JSON avant de démarrer l'app
  initializeJsonConstructors();

  // Initialiser le cache Hive
  WidgetsFlutterBinding.ensureInitialized();
  await ConversationCacheService.instance.initialize();

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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (context) => UserBloc()),
          BlocProvider<AppartementBloc>(create: (context) => AppartementBloc()),
          BlocProvider<BookingBloc>(create: (context) => BookingBloc()),
          BlocProvider<ConversationBloc>(create: (context) => ConversationBloc()),
          BlocProvider<FavoriteBloc>(create: (context) => FavoriteBloc()),
          BlocProvider<MapBloc>(create: (context) => MapBloc()),
          // BlocProvider<NotificationBloc>(create: (context) => NotificationBloc()), // À réactiver après corrections
        ],
        child: SimpleWebSocketInitializer(
          child: FavoriteSnackBarHandler(
            child: MaterialApp.router(
              theme: theme,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            ),
          ),
        ),
      ),
    );
  }
}
