import 'package:flutter/material.dart';
import 'package:fooddelivery/screens/LoginScreen.dart';
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
import 'RegisterScreen.dart';

class EmailScreen extends StatefulWidget {
  static String tag = '/EmailScreen';

  @override
  EmailScreenState createState() => EmailScreenState();
}

class EmailScreenState extends State<EmailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  bool isLoading = false;

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

  handleCheckUser() async {
    try {
      isLoading = true;
      setState(() {});
      var isAvailable = await userDBService.isEmailExist(emailController.text);
      if (isAvailable) {
        snackBar(
          backgroundColor: fireBrick,
          context,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Authentication Failed",
                style: secondaryTextStyle(size: 12, color: white),
              ),
              Text(
                "This email already exist in the database",
                style: boldTextStyle(size: 16, color: white),
              )
            ],
          ),
        );
      } else {
        RegisterScreen(
          email: emailController.text,
        ).launch(context);
      }
    } finally {
      isLoading = false;
      setState(() {});
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
                    child: Text("Create Account",
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
                          Text("Continue",
                              style: primaryTextStyle(color: Colors.white)),
                          Icon(Icons.navigate_next, color: Colors.white),
                        ],
                      ),
                    ).onTap(() {
                      handleCheckUser();
                    }),
                  ),
                ],
              ),
            ),
          ),
          Loader().visible(isLoading),
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
                      text: "Already have an account? ",
                      style: primaryTextStyle()),
                  TextSpan(
                      text: "Login",
                      style: primaryTextStyle(color: colorPrimary)),
                ],
              ).onTap(() {
                LoginScreen().launch(context);
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
