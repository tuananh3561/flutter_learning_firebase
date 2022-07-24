import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Learning Firebase',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    // TODO: implement initState
    super.initState();
  }

  Future loggingEvents() async {
    await FirebaseAnalytics.instance.logBeginCheckout(
        value: 10.0,
        currency: 'USD',
        items: [
          AnalyticsEventItem(
              itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
        ],
        coupon: '10PERCENTOFF');
  }

  Future logSelectContent() async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: "image",
      itemId: "121212",
    );
  }

  Future logEvent() async {
    await FirebaseAnalytics.instance.logEvent(
      name: "select_content",
      parameters: {
        "content_type": "image",
        "item_id": '121212',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: loggingEvents,
              icon: const Icon(Icons.event),
              label: const Text('Logging Events'),
            ),
            ElevatedButton.icon(
              onPressed: logSelectContent,
              icon: const Icon(Icons.event),
              label: const Text('log Select Content'),
            ),
            ElevatedButton.icon(
              onPressed: logEvent,
              icon: const Icon(Icons.event),
              label: const Text('log Event'),
            )
          ],
        ),
      ),
    );
  }
}
