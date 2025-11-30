import 'package:flutter/material.dart';
import 'package:levelup_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'services/api.dart';
import 'screens/login_page.dart';
import 'screens/product_list_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

      NotificationService.showNativeNotification(
  "Teste Funciona",
  "Se isso apareceu, tá tudo OK!",
);

  runApp(LevelUpApp());
}


class LevelUpApp extends StatelessWidget {

  final String baseUrl = 'http://localhost:5151';

  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Api(baseUrl);
    return MultiProvider(
      providers: [Provider<Api>.value(value: api)],
      child: MaterialApp(
        title: 'LevelUp',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (_) => LoginPage(api: api),
          '/products': (_) => ProductListPage(api: api),
        },
      ),
    );
  }
}
