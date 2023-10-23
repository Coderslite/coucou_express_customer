import 'package:flutter/material.dart';
import 'package:fooddelivery/models/WalkThroughModel.dart';
import 'package:fooddelivery/screens/LoginScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController pageController = PageController();
  int currentPage = 0;

  List<WalkThroughModel> list = [];

  @override
  void initState() {
    super.initState();
    init();
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark);
  }

  Future<void> init() async {
    list.add(WalkThroughModel(title: 'Order food faster & easier', image: walk_through_one, subTitle: "Get authentic, super deliciously food."));
    list.add(WalkThroughModel(title: 'Food in your area', image: walk_through_two, subTitle: 'Find, Save your favourite food near you.'));
    list.add(WalkThroughModel(title: 'Track Order', image: walk_through_three, subTitle: 'Track your delivery in realtime.'));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (index) {},
            children: list.map((e) {
              return SingleChildScrollView(
                child: Container(
                  height: context.height(),
                  width: context.width(),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(e.image!), fit: BoxFit.cover),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(e.title!, style: boldTextStyle(size: 22)).paddingLeft(16),
                            4.height,
                            Text(e.subTitle!, style: secondaryTextStyle()).paddingLeft(16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  appStore.translate('skip'),
                  style: primaryTextStyle(color: colorPrimary),
                ).paddingAll(8).onTap(() async {
                  await setValue(IS_FIRST_TIME, false);
                  LoginScreen().launch(context, isNewTask: true);
                }),
                DotIndicator(
                  indicatorColor: errorColor,
                  pageController: pageController,
                  pages: list,
                  unselectedIndicatorColor: Colors.grey,
                  onPageChanged: (i) {
                    currentPage = i;
                    setState(() {});
                  },
                ),
                Container(
                  child: Text(
                    currentPage != 2 ? appStore.translate('next') : appStore.translate('finish'),
                    style: secondaryTextStyle(color: colorPrimary),
                  ),
                  padding: EdgeInsets.all(8),
                ).onTap(() async {
                  if (currentPage == 2) {
                    await setValue(IS_FIRST_TIME, false);

                    LoginScreen().launch(context, isNewTask: true);
                  } else {
                    pageController.animateToPage(currentPage + 1, duration: Duration(milliseconds: 300), curve: Curves.linear);
                  }
                }),
              ],
            ).paddingOnly(left: 16, right: 16),
          ),
        ],
      ),
    );
  }
}
