import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/screens/EmailScreen.dart';
import 'package:fooddelivery/screens/OTPScreen.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Images.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'AddPhoneNumberScreen.dart';
import 'DashboardScreen.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent,
        statusBarIconBrightness:
            appStore.isDarkMode ? Brightness.light : Brightness.dark);

    // if (getStringAsync(PLAYER_ID).isEmpty) saveOneSignalPlayerId();
  }

  Future<void> loginWithGoogle() async {
    if (getStringAsync(PLAYER_ID).isEmpty) {
      // await saveOneSignalPlayerId();
    }

    appStore.setLoading(true);

    await signInWithGoogle().then((value) {
      if (getStringAsync(PHONE_NUMBER).isNotEmpty) {
        DashboardScreen().launch(context, isNewTask: true);
      } else {
        AddPhoneNumberScreen().launch(context);
      }
    }).catchError((e) {
      toast(errorMessage);
    });

    appStore.setLoading(false);
  }

  Future<void> loginWithEmail() async {
    if (isMobile && getStringAsync(PLAYER_ID).isEmpty) {
      // await saveOneSignalPlayerId();
      //if (getStringAsync(PLAYER_ID).isEmpty) return toast(errorMessage);
    }
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      await signInWithEmail(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((e) {
        toast(e.toString());
      });

      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  80.height,
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(appStore.translate('sign_in'),
                        style: boldTextStyle(color: colorPrimary, size: 32)),
                  ).paddingLeft(16),
                  30.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    errorThisFieldRequired:
                        appStore.translate('this_field_is_required'),
                    decoration:
                        inputDecoration(labelText: appStore.translate('email')),
                    nextFocus: passFocus,
                    textStyle: primaryTextStyle(),
                    suffixIconColor: colorPrimary,
                  ).paddingOnly(left: 16, right: 16),
                  16.height,
                  AppTextField(
                    controller: passwordController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: passFocus,
                    errorThisFieldRequired:
                        appStore.translate('this_field_is_required'),
                    errorMinimumPasswordLength:
                        appStore.translate('minimum_password_length'),
                    decoration: inputDecoration(
                        labelText: appStore.translate('password')),
                    autoFillHints: [AutofillHints.password],
                    textStyle: primaryTextStyle(),
                    onFieldSubmitted: (s) {
                      loginWithEmail();
                    },
                  ).paddingOnly(left: 16, right: 16),
                  16.height,
                  Align(
                    alignment: Alignment.topRight,
                    child: Text('${appStore.translate('forgot_password')} ?',
                        style: secondaryTextStyle(color: colorPrimary)),
                  ).onTap(() {
                    ForgotPasswordScreen().launch(context);
                  }).paddingOnly(right: 16, bottom: 16),
                  30.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(left: 30, top: 16, bottom: 16),
                      width: context.width() * 0.5,
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: radiusOnly(topLeft: 30, bottomLeft: 30),
                        backgroundColor: colorPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStore.translate('sign_in').toUpperCase(),
                              style: primaryTextStyle(color: Colors.white)),
                          Icon(Icons.navigate_next, color: Colors.white),
                        ],
                      ),
                    ).onTap(() {
                      loginWithEmail();
                    }),
                  ),
                ],
              ),
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading)),
        ],
      ),
      bottomSheet: Container(
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: createRichText(
                list: [
                  TextSpan(
                      text: appStore.translate('have_an_not_account'),
                      style: primaryTextStyle()),
                  TextSpan(
                      text: appStore.translate('sign_up'),
                      style: primaryTextStyle(color: colorPrimary)),
                ],
              ).onTap(() {
                EmailScreen().launch(context);
              }),
            ),
            30.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Continue without registration",
                  style: boldTextStyle(color: seaGreen),
                ).onTap(() {
                  DashboardScreen().launch(context, isNewTask: true);
                }),
                Icon(
                  Icons.arrow_forward_ios,
                  color: seaGreen,
                ),
              ],
            ),
            30.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                loginWithOtpGoogleWidget(context,
                        image: google, title: appStore.translate("google"))
                    .onTap(() {
                  loginWithGoogle();
                }).expand(),
                16.width,
                loginWithOtpGoogleWidget(context,
                        image: loginWithOtp, title: appStore.translate('otp'))
                    .onTap(() async {
                  OTPScreen().launch(context);
                }).expand(),
              ],
            ).paddingOnly(left: 16, right: 16)
          ],
        ).paddingBottom(16),
      ),
    );
  }
}
