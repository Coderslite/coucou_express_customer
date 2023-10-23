import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'DashboardScreen.dart';
import 'LoginScreen.dart';
import 'WalkThroughScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 2.seconds.delay;
    appStore.setAppLocalization(context);

    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : Colors.transparent,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.light,
    );

    if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
      WalkThroughScreen().launch(context, isNewTask: true);
    } else {
      if (appStore.isLoggedIn) {
        appStore.clearCart();
        await myCartDBService.getCartList().then((value) {
          value.forEach((element) {
            appStore.addToCart(element);
          });
        });

        await setFavouriteRestaurant();

        DashboardScreen().launch(context, isNewTask: true);
      } else {
        LoginScreen().launch(context, isNewTask: true);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      body: Container(
        child: Text(mAppName,
            style: primaryTextStyle(size: 36, color: Colors.white)),
      ).center(),
    );
  }
}
