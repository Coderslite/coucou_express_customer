import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String tag = '/ForgotPasswordScreen';

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> forgoPassword() async {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      await forgotPassword(email: emailController.text.validate()).then((value) {
        toast(appStore.translate('reset_password_mail'));
        finish(context);
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
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(appStore.translate('forgot_password'), color: context.cardColor),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: emailController,
                  textFieldType: TextFieldType.EMAIL,
                  errorThisFieldRequired: appStore.translate('this_field_is_required'),
                  decoration: inputDecoration(labelText: appStore.translate('email')),
                  textStyle: primaryTextStyle(),
                ),
                60.height,
                AppButton(
                  text: appStore.translate('submit'),
                  textStyle: boldTextStyle(color: white),
                  color: colorPrimary,
                  onTap: () {
                    forgoPassword();
                  },
                  width: context.width(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
