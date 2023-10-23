import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fooddelivery/components/ThemeSelectionDialog.dart';
import 'package:fooddelivery/screens/AboutAppScreen.dart';
import 'package:fooddelivery/screens/MyAddressScreen.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';

import '../main.dart';
import 'EditProfileScreen.dart';
import 'FavouriteRestaurantListScreen.dart';
import 'LoginScreen.dart';

class ProfileFragment extends StatefulWidget {
  static String tag = '/ProfileFragment';

  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
//
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);

    return Scaffold(
      body: Observer(
        builder: (_) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Row(
                children: [
                  appStore.userProfileImage.validate().isEmpty
                      ? Icon(Icons.person_outline, size: 60)
                      : cachedImage(
                          appStore.userProfileImage.validate(),
                          usePlaceholderIfUrlEmpty: true,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(defaultRadius),
                  8.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(appStore.userFullName.validate(), style: boldTextStyle()),
                      Text(appStore.userEmail.validate(), style: secondaryTextStyle()),
                    ],
                  ),
                ],
              ).paddingOnly(left: 16, right: 16).onTap(() {
                EditProfileScreen().launch(context);
              }).visible(appStore.isLoggedIn),
              16.height,
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(MaterialCommunityIcons.theme_light_dark),
                title: appStore.translate('select_theme'),
                onTap: () async {
                  await showInDialog(
                    context,
                    child: ThemeSelectionDialog(),
                    contentPadding: EdgeInsets.zero,
                    title: Text(appStore.translate('select_theme'), style: primaryTextStyle(size: 20)),
                  );
                  setState(() {});
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                title: appStore.translate('fav_restaurant'),
                leading: Icon(Icons.restaurant_outlined),
                onTap: () {
                  if (appStore.isLoggedIn) {
                    FavouriteRestaurantListScreen().launch(context);
                  } else {
                    LoginScreen().launch(context);
                  }
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                title: appStore.translate('my_address'),
                leading: Icon(Icons.book_outlined),
                onTap: () {
                  if (appStore.isLoggedIn) {
                    MyAddressScreen().launch(context);
                  } else {
                    LoginScreen().launch(context);
                  }
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                title: appStore.translate('app_lang'),
                leading: Icon(FontAwesome.language),
                trailing: Row(
                  children: [
                    Image.asset('${selectedLanguageDataModel!.flag.validate()}', height: 25, width: 25),
                    4.width,
                    Text('${selectedLanguageDataModel!.name.validate()}', style: boldTextStyle()),
                  ],
                ),
                onTap: () async {
                  await StatefulBuilder(builder: (context, setState) {
                    return Scaffold(
                      appBar: appBarWidget(appStore.translate('app_lang'), color: context.cardColor),
                      body: LanguageListWidget(
                        onLanguageChange: (val) async {
                          appStore.setLanguage(val.languageCode.validate());
                          await setValue(SELECTED_LANGUAGE_CODE, val.languageCode);

                          finish(context);
                        },
                      ),
                    );
                  }).launch(context);

                  setState(() {});
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.share_outlined),
                title: '${appStore.translate('share')} $mAppName',
                onTap: () {
                  PackageInfo.fromPlatform().then((value) {
                    String package = '';
                    if (isAndroid) package = value.packageName;

                    Share.share('${appStore.translate('share')} $mAppName\n\n${storeBaseURL()}$package');
                  });
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.assignment_outlined),
                title: appStore.translate('term_condition'),
                onTap: () {
                  launchUrl(Privacy_Policy, forceWebView: true);
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.rate_review_outlined),
                title: appStore.translate('rate_us'),
                onTap: () {
                  PackageInfo.fromPlatform().then((value) {
                    String package = '';
                    if (isAndroid) {
                      package = value.packageName;

                      launchUrl('$playStoreBaseURL$package');
                    }
                  });
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.assessment_outlined),
                title: appStore.translate('privacy_policy'),
                onTap: () {
                  launchUrl(Privacy_Policy, forceWebView: true);
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.support_rounded),
                title: appStore.translate('help_support'),
                onTap: () {
                  launchUrl(supportURL, forceWebView: true);
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                leading: Icon(Icons.info_outline),
                title: appStore.translate('about'),
                onTap: () {
                  AboutAppScreen().launch(context);
                },
              ),
              Divider(height: 0),
              SettingItemWidget(
                title: appStore.translate('logout'),
                leading: Icon(Icons.logout),
                onTap: () async {
                  bool? res = await showConfirmDialog(
                    context,
                    appStore.translate('do_you_want_to_logout'),
                    negativeText: appStore.translate('no'),
                    positiveText: appStore.translate('yes'),
                  );

                  if (res ?? false) {
                    logout().then((value) {
                      LoginScreen().launch(context, isNewTask: true);
                    });
                  }
                },
              ).visible(appStore.isLoggedIn),
            ],
          ),
        ),
      ),
    );
  }
}
