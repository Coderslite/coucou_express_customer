import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'DashboardScreen.dart';

class RegisterScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : Colors.white);

    saveOneSignalPlayerId();
  }

  Future<void> signUp() async {
    hideKeyboard(context);
    if (getStringAsync(PLAYER_ID).isEmpty) {
      await saveOneSignalPlayerId();
      //if (getStringAsync(PLAYER_ID).isEmpty) return toast(errorMessage);
    }
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      await signUpWithEmail(nameController.text.trim(), emailController.text.trim(), passwordController.text.trim(), phoneController.text).then((value) {
        appStore.setLoading(false);

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((e) {
        toast(e.toString());

        appStore.setLoading(false);
      });
    }
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : Colors.white);

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      appBar: appBarWidget(appStore.translate('register'), color: context.cardColor),
      body: Container(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        AppTextField(
                          controller: nameController,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: appStore.translate('this_field_is_required'),
                          decoration: inputDecoration(labelText: appStore.translate('full_name')),
                          nextFocus: emailFocus,
                          textStyle: primaryTextStyle(),
                        ),
                        16.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          errorThisFieldRequired: appStore.translate('this_field_is_required'),
                          decoration: inputDecoration(labelText: appStore.translate('email')),
                          nextFocus: phoneFocus,
                          textStyle: primaryTextStyle(),
                          suffixIconColor: colorPrimary,
                        ),
                        16.height,
                        AppTextField(
                          controller: phoneController,
                          textFieldType: TextFieldType.PHONE,
                          focus: phoneFocus,
                          maxLength: 10,
                          nextFocus: passFocus,
                          errorThisFieldRequired: appStore.translate('this_field_is_required'),
                          decoration: inputDecoration(labelText: appStore.translate('phone_number')).copyWith(counterText: ''),
                          autoFillHints: [AutofillHints.newPassword],
                        ),
                        16.height,
                        AppTextField(
                          controller: passwordController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passFocus,
                          nextFocus: confirmPasswordFocus,
                          errorThisFieldRequired: appStore.translate('this_field_is_required'),
                          errorMinimumPasswordLength: appStore.translate('minimum_password_length'),
                          decoration: inputDecoration(labelText: appStore.translate('password')),
                          autoFillHints: [AutofillHints.newPassword],
                        ),
                        16.height,
                        AppTextField(
                          controller: confirmPasswordController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: confirmPasswordFocus,
                          decoration: inputDecoration(labelText: appStore.translate('confirm_password')),
                          onFieldSubmitted: (s) {
                            signUp();
                          },
                          validator: (value) {
                            if (value!.trim().isEmpty) return appStore.translate('this_field_is_required');
                            if (value.trim().length < passwordLengthGlobal) return appStore.translate('password_length');
                            return passwordController.text == value.trim() ? null : appStore.translate('password_not_match');
                          },
                          autoFillHints: [AutofillHints.newPassword],
                        ),
                      ],
                    ).paddingOnly(left: 16, right: 16),
                    50.height,
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
                            Text(appStore.translate('sign_up').toUpperCase(), style: primaryTextStyle(color: Colors.white)),
                            Icon(Icons.navigate_next, color: Colors.white),
                          ],
                        ),
                      ).onTap(() {
                        signUp();
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomSheet: Container(
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: createRichText(
                list: [
                  TextSpan(text: appStore.translate('have_an_account'), style: primaryTextStyle()),
                  TextSpan(text: appStore.translate('sign_in'), style: primaryTextStyle(color: colorPrimary)),
                ],
              ).onTap(() {
                finish(context);
              }).paddingBottom(16),
            ),
          ],
        ),
      ),
    );
  }
}
