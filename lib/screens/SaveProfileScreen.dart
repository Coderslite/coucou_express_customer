import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/screens/DashboardScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class SaveProfileScreen extends StatefulWidget {
  static String tag = '/SaveProfileScreen';
  bool mIsShowBack = true;

  SaveProfileScreen({this.mIsShowBack = true});

  @override
  SaveProfileScreenState createState() => SaveProfileScreenState();
}

class SaveProfileScreenState extends State<SaveProfileScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController homeAddressCont = TextEditingController();
  TextEditingController workAddressCont = TextEditingController();

  String? photo = '';

  FocusNode workAddressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    userDBService.getUserByEmail(appStore.userEmail).then((res) {
      appStore.setLoading(false);

      nameCont.text = res.name!;
      emailCont.text = res.email!;
      //  homeAddressCont.text = res.homeAddress;
      // workAddressCont.text = res.workAddress;

      photo = res.photoUrl;

      setState(() {});
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
      setState(() {});
    });
  }

  Future<void> validate() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map<String, dynamic> data = {
        UserKeys.homeAddress: homeAddressCont.text,
        UserKeys.workAddress: workAddressCont.text,
        CommonKeys.updatedAt: DateTime.now(),
      };

      userDBService.updateDocument(data, appStore.userId).then((res) async {
        appStore.setLoading(false);
        await setValue(IS_PROFILE_COMPLETED, true);
        await setValue(USER_HOME_ADDRESS, homeAddressCont.text);

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(appStore.translate('save_profile'), showBack: widget.mIsShowBack),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    cachedImage(photo, height: 120, width: 120, fit: BoxFit.cover).cornerRadiusWithClipRRect(60),
                    16.height,
                    AppTextField(
                      controller: nameCont,
                      textFieldType: TextFieldType.NAME,
                      decoration: InputDecoration(labelText: appStore.translate('full_name'), border: OutlineInputBorder()),
                      readOnly: true,
                      enabled: false,
                      isValidationRequired: false,
                    ),
                    16.height,
                    AppTextField(
                      controller: emailCont,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: InputDecoration(labelText: appStore.translate('email'), border: OutlineInputBorder()),
                      enabled: false,
                      readOnly: true,
                      isValidationRequired: false,
                    ),
                    16.height,
                    AppTextField(
                      controller: homeAddressCont,
                      textFieldType: TextFieldType.ADDRESS,
                      decoration: InputDecoration(labelText: appStore.translate('home_address'), border: OutlineInputBorder()),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.name,
                      nextFocus: workAddressFocus,
                      validator: (s) {
                        if (s!.trim().isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        FocusScope.of(context).requestFocus(workAddressFocus);
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: workAddressCont,
                      textFieldType: TextFieldType.ADDRESS,
                      decoration: InputDecoration(labelText: appStore.translate('work_address'), border: OutlineInputBorder()),
                      textInputAction: TextInputAction.done,
                      focus: workAddressFocus,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.name,
                      validator: (s) {
                        if (s!.trim().isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                    30.height,
                    AppButton(
                      width: context.width(),
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onTap: () {
                        validate();
                      },
                      color: colorPrimary,
                      child: Text(appStore.translate('save'), style: boldTextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoggedIn)),
        ],
      ),
    );
  }
}
