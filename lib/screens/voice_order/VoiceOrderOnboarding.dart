import 'package:flutter/material.dart';
import 'package:fooddelivery/components/voice_order_component/VoiceOrderOnboarding1.dart';
import 'package:fooddelivery/components/voice_order_component/VoiceOrderOnboarding2.dart';
import 'package:fooddelivery/components/voice_order_component/VoiceOrderOnboarding3.dart';
import 'package:fooddelivery/screens/voice_order/VoiceOrderPlacement.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class VoiceOrderOnboarding extends StatefulWidget {
  const VoiceOrderOnboarding({super.key});

  @override
  State<VoiceOrderOnboarding> createState() => _VoiceOrderOnboardingState();
}

class _VoiceOrderOnboardingState extends State<VoiceOrderOnboarding> {
  int index = 0;
  var pageController = PageController();
  List steps = [
    VoiceOrderOnboarding1(),
    VoiceOrderOnboarding2(),
    VoiceOrderOnboarding3(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Card(
                  color: context.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),
                ).onTap(() {
                  finish(context);
                }),
                10.width,
                Text(
                  "Voice Order Placement",
                  style: boldTextStyle(
                    size: 20,
                  ),
                )
              ],
            ),
            5.height,
            Expanded(
                child: PageView.builder(
                    onPageChanged: (val) {
                      index = val;
                      setState(() {});
                    },
                    controller: pageController,
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return steps[index];
                    })),
            SmoothPageIndicator(
              controller: pageController,
              count: steps.length,
              effect: WormEffect(activeDotColor: colorPrimary),
            ).center(),
            20.height,
            AppButton(
              onTap: () {
                if (index + 1 < steps.length) {
                  pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                } else {
                  VoiceOrderPlacement().launch(context);
                }
              },
              color: colorPrimary,
              text: index + 1 < steps.length ? "NEXT" : "DONE",
              textColor: white,
              width: double.infinity,
            )
          ],
        ),
      )),
    );
  }
}
