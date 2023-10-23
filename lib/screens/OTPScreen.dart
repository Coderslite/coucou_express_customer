import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/services/AuthService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import 'CompleteProfileScreen.dart';
import 'DashboardScreen.dart';

class OTPScreen extends StatefulWidget {
  static String tag = '/OTPScreen';

  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;
  final int? resendToken;

  OTPScreen({this.verificationId, this.isCodeSent, this.phoneNumber, this.credential, this.resendToken});

  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  TextEditingController numberController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  String? countryCode = '';
  String otpCode = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark);
  }

  Future<void> sendOTP({int? forceResendingToken}) async {
    if (numberController.text.trim().isEmpty) {
      return toast(appStore.translate('this_field_is_required'));
    } else if (numberController.text.length < 9) {
      return toast(appStore.translate('enter_valid_number'));
    }

    String number = '+$countryCode${numberController.text.trim()}';
    if (!number.startsWith('+')) {
      number = '+$countryCode${numberController.text.trim()}';
    }

    await loginWithOTP(context, number, forceResendingToken: forceResendingToken).then((value) {
      //
    }).catchError((e) {
      toast(e.toString());
    });
  }

  Future<void> resendOtp({int? forceResendingToken}) async {
    await loginWithOTP(context, widget.phoneNumber!, forceResendingToken: forceResendingToken).then((value) {
      //
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> submit() async {
    appStore.setLoading(true);
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: otpCode.validate());

    await auth.signInWithCredential(credential).then((result) async {
      User currentUser = result.user!;

      await userDBService.getUserByPhone(phone: currentUser.phoneNumber).then((user) async {
        appStore.setLoading(false);

        await saveUserDetails(user, LoginTypeOTP);
        if (user.email.isEmptyOrNull) {
          CompleteProfileScreen(user: currentUser).launch(context);
        } else {
          DashboardScreen().launch(context, isNewTask: true);
        }
      }).catchError((e) {
        if (e == no_user_found) {
          CompleteProfileScreen(user: currentUser).launch(context);
        }
      });
      appStore.setLoading(false);
      return null;
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
    return;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBarWidget('', showBack: true, elevation: 0, color: context.cardColor),
      backgroundColor: context.scaffoldBackgroundColor,
      bottomNavigationBar: !widget.isCodeSent.validate()
          ? otpNextWidget(context, onTap: () {
              sendOTP();
            }).paddingOnly(left: 16, right: 16, bottom: 16)
          : otpNextWidget(context, onTap: () {
              submit();
            }).paddingOnly(left: 16, right: 16, bottom: 16),
      body: SingleChildScrollView(
        child: Container(
          width: context.width(),
          child: !widget.isCodeSent.validate()
              ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(appStore.translate('enter_phone_no'), style: boldTextStyle(size: 20)),
                        16.height,
                        Container(
                          decoration: boxDecorationWithShadow(boxShadow: defaultBoxShadow(spreadRadius: 0.0), backgroundColor: context.scaffoldBackgroundColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryCodePicker(
                                padding: EdgeInsets.all(0),
                                showDropDownButton: true,
                                initialSelection: 'IN',
                                favorite: ['+91', 'IN'],
                                showCountryOnly: false,
                                showFlag: true,
                                textStyle: primaryTextStyle(),
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                onInit: (c) {
                                  countryCode = c!.dialCode;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode;
                                },
                              ),
                              AppTextField(
                                textFieldType: TextFieldType.PHONE,
                                controller: numberController,
                                maxLines: 1,
                                errorThisFieldRequired: appStore.translate('this_field_is_required'),
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                                autoFocus: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: appStore.translate('phone_number'),
                                    hintStyle: secondaryTextStyle()),
                                onFieldSubmitted: (s) {
                                  sendOTP();
                                },
                              ).expand()
                            ],
                          ),
                        ),
                        16.height,
                        Text(appStore.translate('agree_phone_number'), style: secondaryTextStyle()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(appStore.translate('term_condition'), style: secondaryTextStyle(color: colorPrimary)).onTap(() {
                              launchUrl(getStringAsync(TERMS_AND_CONDITION_PREF), forceWebView: true);
                            }),
                            4.width,
                            Text(appStore.translate('and'), style: secondaryTextStyle()),
                            4.width,
                            Text(appStore.translate('privacy_policy'), style: secondaryTextStyle(color: colorPrimary)).onTap(() {
                              launchUrl(getStringAsync(PRIVACY_POLICY_PREF), forceWebView: true);
                            }),
                          ],
                        ),
                      ],
                    ).paddingAll(16),
                    Positioned(
                      child: Observer(builder: (_) => Loader().visible(appStore.isLoading)),
                    ),
                  ],
                )
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(appStore.translate('enter_your_text_you'), style: boldTextStyle(size: 22), textAlign: TextAlign.center),
                        30.height,
                        Container(
                          decoration: boxDecorationWithShadow(boxShadow: defaultBoxShadow(spreadRadius: 0.0)),
                          child: TextField(
                            obscureText: true,
                            controller: codeController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            autofocus: true,
                            maxLines: 1,
                            cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 16, right: 16),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: appStore.translate('hint_enter_pin'),
                              hintStyle: secondaryTextStyle(),
                            ),
                            onSubmitted: (pin) {
                              otpCode = pin;
                              submit();
                            },
                          ),
                        ),
                        30.height,
                        Text(appStore.translate('did_not_receive_otp'), style: secondaryTextStyle()).onTap(() {
                          resendOtp(forceResendingToken: widget.resendToken);
                        }),
                      ],
                    ).paddingAll(16),
                    Positioned(
                      child: Observer(builder: (_) => Loader().visible(appStore.isLoading)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
