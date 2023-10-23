import 'package:flutter/material.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';

class AboutAppScreen extends StatefulWidget {
  static String tag = '/AboutAppScreen';

  @override
  AboutAppScreenState createState() => AboutAppScreenState();
}

class AboutAppScreenState extends State<AboutAppScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(
          appStore.translate('about'),
          color: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
          textColor: appStore.isDarkMode ? Colors.white : Colors.black,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mAppName, style: primaryTextStyle(size: 30)),
                16.height,
                Container(decoration: BoxDecoration(color: colorPrimary, borderRadius: radius(4)), height: 4, width: 100),
                16.height,
                Text(appStore.translate('version'), style: secondaryTextStyle()),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return Text('${snap.data!.version.validate()}', style: primaryTextStyle());
                    }
                    return SizedBox();
                  },
                ),
                16.height,
                Text(
                  mAboutApp,
                  style: primaryTextStyle(size: 14),
                  textAlign: TextAlign.justify,
                ),
                16.height,
                AppButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.contact_support_outlined, color: context.iconColor),
                      8.width,
                      Text(appStore.translate('contact'), style: boldTextStyle()),
                    ],
                  ),
                  onTap: () {
                    launchUrl('mailto:${getStringAsync(CONTACT_PREF)}');
                  },
                ),
                16.height,
                AppButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(purchase, height: 24, color: context.iconColor),
                      8.width,
                      Text(appStore.translate('purchase'), style: boldTextStyle()),
                    ],
                  ),
                  onTap: () {
                    launchUrl(mightyUrl);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
