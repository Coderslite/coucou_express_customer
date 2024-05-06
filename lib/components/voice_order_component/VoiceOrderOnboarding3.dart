import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/Colors.dart';

class VoiceOrderOnboarding3 extends StatelessWidget {
  const VoiceOrderOnboarding3({super.key});

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
            "assets/voice_order3.png",
            fit: BoxFit.cover,
          ),
        ).center(),
        20.height,
        Text(
          "Summary",
          style: boldTextStyle(
            size: 14,
          ),
        ),
        10.height,
        Text(
          "For example, “I’d like 2 burgers, one sandwich and 2 Pepsis from Macdonald on 123 delivery avenue, Dakar and the delivery address is 123 Apple street, Dakar, apt 5”",
          style: primaryTextStyle(
            size: 12,
          ),
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
