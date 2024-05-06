import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/Colors.dart';

class VoiceOrderOnboarding1 extends StatelessWidget {
  const VoiceOrderOnboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To place a clear and detailed order through a voice note, follow these rules",
          style: primaryTextStyle(
            size: 12,
          ),
        ),
        20.height,
        SizedBox(
          width: 150,
          height: 150,
          child: Image.asset(
            "assets/voice_order1.png",
            fit: BoxFit.cover,
          ),
        ).center(),
        20.height,
        Text(
          "List Items and Quantity:",
          style: boldTextStyle(
            size: 14,
          ),
        ),
        10.height,
        Text(
          "Begin by clearly stating the items you wish to order and the quantity of each one.",
          style: primaryTextStyle(
            size: 12,
          ),
        ),
        20.height,
        Text(
          "For example, “I’d like to order 2 burgers, 1 sandwich and 3 Pepsi cans.”",
          style: primaryTextStyle(size: 12),
        ),
        20.height,
        Container(
          padding: const EdgeInsets.all(10),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: context.cardColor,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorPrimary,
                child: Icon(
                  Icons.play_arrow,
                  color: white,
                ),
              ),
              10.width,
              Expanded(
                child: Image.asset(
                  "assets/waveform.png",
                  fit: BoxFit.cover,
                ),
              ),
              10.width,
              Text(
                "1:10",
                style: primaryTextStyle(
                  size: 12,
                ),
              )
            ],
          ),
        ),
        20.height,
      ],
    );
  }
}
