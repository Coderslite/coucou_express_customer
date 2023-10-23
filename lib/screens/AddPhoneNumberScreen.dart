import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import 'DashboardScreen.dart';

class AddPhoneNumberScreen extends StatefulWidget {
  static String tag = '/AddPhoneNumberScreen';

  @override
  AddPhoneNumberScreenState createState() => AddPhoneNumberScreenState();
}

class AddPhoneNumberScreenState extends State<AddPhoneNumberScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController phoneController = TextEditingController();

  FocusNode phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 1.milliseconds.delay;
    setStatusBarColor(colorPrimary, statusBarIconBrightness: Brightness.light);
  }

  Future<void> validate() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      appStore.setLoading(false);
      setState(() {});

      formKey.currentState!.save();
      Map<String, dynamic> data = {
        UserKeys.number: phoneController.text,
        CommonKeys.updatedAt: DateTime.now(),
      };
      userDBService.updateDocument(data, appStore.userId).then((res) async {
        await setValue(IS_PROFILE_COMPLETED, true);
        await setValue(PHONE_NUMBER, phoneController.text);

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    if (appStore.isDarkMode)
      setStatusBarColor(scaffoldColorDark, statusBarIconBrightness: Brightness.light);
    else
      setStatusBarColor(Colors.white, statusBarIconBrightness: Brightness.dark);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(appStore.translate('add_phone_number'), color: colorPrimary, textColor: Colors.white, showBack: false),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            AppTextField(
              controller: phoneController,
              textFieldType: TextFieldType.PHONE,
              decoration: inputDecoration(labelText: PHONE_NUMBER),
              textStyle: primaryTextStyle(),
              focus: phoneFocus,
              maxLines: 1,
              autoFocus: false,
            ),
            60.height,
            AppButton(
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
              text: appStore.translate('save'),
              textStyle: boldTextStyle(color: white),
              color: colorPrimary,
              onTap: () {
                validate();
              },
              width: context.width(),
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
