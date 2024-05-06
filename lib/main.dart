import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/AppLocalizations.dart';
import 'package:fooddelivery/services/AdvertDBService.dart';
import 'package:fooddelivery/services/AppSettingService.dart';
import 'package:fooddelivery/services/CategoryDBService.dart';
import 'package:fooddelivery/services/FoodDBService.dart';
import 'package:fooddelivery/services/FoodItemDBService.dart';
import 'package:fooddelivery/services/MyCartService.dart';
import 'package:fooddelivery/services/MyOrderDBService.dart';
import 'package:fooddelivery/services/RestaurantDBService.dart';
import 'package:fooddelivery/services/UserDBService.dart';
import 'package:fooddelivery/store/AppStore.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'AppTheme.dart';
import 'screens/SplashScreen.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

MyCartDBService myCartDBService = MyCartDBService();
UserDBService userDBService = UserDBService();
CategoryDBService categoryDBService = CategoryDBService();
FoodDBService foodDBService = FoodDBService();
MyOrderDBService myOrderDBService = MyOrderDBService();
RestaurantDBService restaurantDBService = RestaurantDBService();
AppSettingService appSettingService = AppSettingService();
FoodItemDBService foodItemDBService = FoodItemDBService();
AdvertDBService advertDBService = AdvertDBService();

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AppStore appStore = AppStore();

List<String?> favRestaurantList = [];

String userAddressGlobal = '';
String? userCityNameGlobal = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initMethod();

  runApp(MyApp());
}

Future<void> initMethod() async {
  await initialize(aLocaleLanguageList: [
    LanguageDataModel(
        id: 1,
        name: 'English',
        languageCode: 'en',
        flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(
        id: 2,
        name: 'Hindi',
        languageCode: 'hi',
        flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(
        id: 3,
        name: 'Arabic',
        languageCode: 'ar',
        flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(
        id: 4,
        name: 'Spanish',
        languageCode: 'es',
        flag: 'assets/flag/ic_spain.png'),
    LanguageDataModel(
        id: 5,
        name: 'Afrikaans',
        languageCode: 'af',
        flag: 'assets/flag/ic_south_africa.png'),
    LanguageDataModel(
        id: 6,
        name: 'French',
        languageCode: 'fr',
        flag: 'assets/flag/ic_france.png'),
    LanguageDataModel(
        id: 7,
        name: 'German',
        languageCode: 'de',
        flag: 'assets/flag/ic_germany.png'),
    LanguageDataModel(
        id: 8,
        name: 'Indonesian',
        languageCode: 'id',
        flag: 'assets/flag/ic_indonesia.png'),
    LanguageDataModel(
        id: 9,
        name: 'Portuguese',
        languageCode: 'pt',
        flag: 'assets/flag/ic_portugal.png'),
    LanguageDataModel(
        id: 10,
        name: 'Turkish',
        languageCode: 'tr',
        flag: 'assets/flag/ic_turkey.png'),
    LanguageDataModel(
        id: 11,
        name: 'vietnam',
        languageCode: 'vi',
        flag: 'assets/flag/ic_vitnam.png'),
    LanguageDataModel(
        id: 12,
        name: 'Dutch',
        languageCode: 'nl',
        flag: 'assets/flag/ic_dutch.png'),
  ]);
  defaultLoaderAccentColorGlobal = colorPrimary;

  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: defaultLanguage);
  if (selectedLanguageDataModel != null) {
    appStore.setLanguage(selectedLanguageDataModel!.languageCode.validate());
  } else {
    selectedLanguageDataModel = localeLanguageList.first;
    appStore.setLanguage(selectedLanguageDataModel!.languageCode.validate());
  }

  if (isMobile) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Flutter Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    var prefs = await SharedPreferences.getInstance();
    var token = await _firebaseMessaging.getToken();
    prefs.setString(PLAYER_ID, token.toString());

// Handle incoming messages and display notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // Display a local notification
      _displayLocalNotification(message);
    });
  }

  appStore.setDarkMode(appStore.isDarkMode);
  appStore
      .setNotification(getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));

  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setAdmin(getBoolAsync(ADMIN));
    appStore.setFullName(getStringAsync(USER_DISPLAY_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserProfile(getStringAsync(USER_PHOTO_URL));

    myCartDBService = MyCartDBService();
  }

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
}

void _displayLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('com.coucouexpress', 'Coucou Express',
          importance: Importance.max, priority: Priority.high);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
      message.notification!.body, platformChannelSpecifics,
      payload: message.data.toString());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print('Handling a background message: ${message.messageId}');
  _displayLocalNotification(message);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setOrientationPortrait();

    return Observer(
      builder: (_) => MaterialApp(
        title: mAppName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(appStore.selectedLanguage),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        home: SplashScreen(),
        builder: scrollBehaviour(),
      ),
    );
  }
}
