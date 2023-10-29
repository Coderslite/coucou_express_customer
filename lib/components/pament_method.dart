import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/Common.dart';

class PaymentMethod extends StatefulWidget {
  final int amount;
  final Function order;
  const PaymentMethod({super.key, required this.amount, required this.order});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  @override
  void initState() {
    appStore.setPaymentMethod("");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              BackButton(),
              Text(
                "Payment Option",
                style: boldTextStyle(),
              ),
              Container()
            ],
          ),
          widget.amount < 1
              ? Container()
              : Text(
                  "Pay ${getAmount(widget.amount)}",
                  style: boldTextStyle(size: 28),
                ),
          ListTile(
            onTap: () {
              setState(() {
                appStore.setPaymentMethod("CASH");
              });
            },
            selected: appStore.paymentMethod == "CASH",
            selectedTileColor: lightGray,
            leading: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/cash.png",
                  fit: BoxFit.cover,
                )),
            title: Text(
              "CASH",
              style: boldTextStyle(),
            ),
          ),
          ListTile(
            onTap: () {
              setState(() {
                appStore.setPaymentMethod("WAVE");
              });
            },
            selected: appStore.paymentMethod == "WAVE",
            selectedTileColor: lightGray,
            leading: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/wave.png",
                  fit: BoxFit.cover,
                )),
            title: Text(
              "WAVE",
              style: boldTextStyle(),
            ),
          ),
          ListTile(
            onTap: () {
              setState(() {
                appStore.setPaymentMethod("ORANGE");
              });
            },
            selected: appStore.paymentMethod == "ORANGE",
            selectedTileColor: lightGray,
            leading: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/orange.png",
                  fit: BoxFit.cover,
                )),
            title: Text(
              "ORANGE MONEY",
              style: boldTextStyle(),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              onPressed: () {
                if (appStore.paymentMethod != 'CASH' &&
                    appStore.paymentMethod != 'WAVE' &&
                    appStore.paymentMethod != 'ORANGE') {
                  toast("Please select a payment method");
                } else {
                  Navigator.pop(context);
                  showConfirmDialog(
                    context,
                    appStore.translate('place_order_confirmation'),
                    negativeText: appStore.translate('no'),
                    positiveText: appStore.translate('yes'),
                  ).then((value) async {
                    if (value ?? false) {
                      widget.order();
                    }
                  }).catchError((e) {
                    toast(e.toString());
                  });
                }
              },
              child: Text(
                "Proceed",
                style: primaryTextStyle(),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: mediumSeaGreen),
            ),
          )
        ],
      );
    });
  }
}
