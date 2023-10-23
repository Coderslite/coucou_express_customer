import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/models/UserModel.dart';
import 'package:fooddelivery/screens/DashboardScreen.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class CompleteProfileScreen extends StatefulWidget {
  static String tag = '/CompleteProfileScreen';
  User? user;

  CompleteProfileScreen({this.user});

  @override
  CompleteProfileScreenState createState() => CompleteProfileScreenState();
}

class CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark);
  }

  save() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      Map<String, dynamic> req = {
        CommonKeys.updatedAt: DateTime.now(),
        UserKeys.name: fullNameController.text.validate(),
        UserKeys.email: emailController.text.validate(),
      };

      await userDBService.updateDocument(req, appStore.userId.validate()).then((value) async {
        appStore.setLoading(false);
        await appStore.setFullName(fullNameController.text);
        await appStore.setUserEmail(emailController.text);
        await appStore.setPhoneNumber(widget.user!.phoneNumber);
        await appStore.setLoggedIn(true);
        await setValue(LOGIN_TYPE, LoginTypeOTP);
        DashboardScreen().launch(context, isNewTask: true);
      });
    }
  }

  void saveOtpDetails() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (await userDBService.isUserExistByPhone(emailController.text)) {
        toast(appStore.translate('user_already_exist'));
      } else {
        UserModel userModel = UserModel();

        userModel.uid = widget.user!.uid.validate();
        userModel.name = fullNameController.text.validate();
        userModel.email = emailController.text.validate();
        userModel.number = widget.user!.phoneNumber.validate();
        userModel.updatedAt = DateTime.now();
        userModel.createdAt = DateTime.now();
        userModel.isAdmin = false;
        userModel.isTester = false;
        userModel.loginType = LoginTypeOTP;
        userModel.role = USER_ROLE;
        userModel.isDeleted = false;
        userModel.listOfAddress = [];
        userModel.favRestaurant = [];
        userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);
        userModel.password = '';
        userModel.city = '';
        userModel.photoUrl = '';

        await userDBService.addDocumentWithCustomIds(widget.user!.uid, userModel.toJson()).then((value) async {
          UserModel userModel = await value.get().then((value) => UserModel.fromJson(value.data() as Map<String, dynamic>));
          await saveUserDetails(userModel, LoginTypeOTP);
          DashboardScreen().launch(context);
        }).catchError((e) {
          toast(e.toString());
        });
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      appBar: appBarWidget(appStore.translate('complete_profile'), color: context.cardColor),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    AppTextField(
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: nameFocus,
                      decoration: inputDecoration(labelText: appStore.translate('email')),
                      textStyle: primaryTextStyle(),
                    ),
                    16.height,
                    AppTextField(
                      controller: fullNameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      decoration: inputDecoration(labelText: appStore.translate('full_name')),
                      textStyle: primaryTextStyle(),
                    ),
                    30.height,
                    AppButton(
                      text: appStore.translate('save'),
                      color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
                      textStyle: boldTextStyle(color: white),
                      onTap: () {
                        saveOtpDetails();
                      },
                      width: context.width(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
