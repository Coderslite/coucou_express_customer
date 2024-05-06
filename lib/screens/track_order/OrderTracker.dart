import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/components/order_tracker/OrderAccepted.dart';
import 'package:fooddelivery/components/order_tracker/OrderArrivedBuyFrom.dart';
import 'package:fooddelivery/components/order_tracker/OrderArrivedLocation.dart';
import 'package:fooddelivery/components/order_tracker/OrderDelivered.dart';
import 'package:fooddelivery/components/order_tracker/OrderPaidPickup.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/screens/track_order/OrderChat.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class OrderTracker extends StatefulWidget {
  final String orderId;
  const OrderTracker({super.key, required this.orderId});

  @override
  State<OrderTracker> createState() => _OrderTrackerState();
}

class _OrderTrackerState extends State<OrderTracker> {
  PlayerController controller = PlayerController();
  String url = "";
  List<double> waveformData = [];
  handleGenerateWave() async {
    waveformData = await controller.extractWaveformData(
      path: url,
      noOfSamples: 100,
    );
    setState(() {});
  }

  handlePlay({required String fileUrl, required String time}) async {
// Or directly extract from preparePlayer and initialise audio player
    await createFileOfPdfUrl(fileUrl: fileUrl, time: time);
    await handleGenerateWave();
    await controller.preparePlayer(
      path: url,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    await controller.startPlayer(finishMode: FinishMode.stop);
    print("audio playing");
    setState(() {});
    controller.onCompletion.listen((_) {
      controller.stopPlayer();
      print("audio stopped");
      setState(() {});
    });
  }

  Future<File> createFileOfPdfUrl(
      {required String fileUrl, required String time}) async {
    try {
      url = fileUrl;
      final filename = time.substring(time.lastIndexOf("/") + 1);
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      // Check if the file already exists
      if (await file.exists()) {
        print("File already exists");
        return file;
      }

      var request = await http.get(Uri.parse(url));
      var bytes = request.bodyBytes;

      await file.writeAsBytes(bytes, flush: true);
      print("Downloaded file");
      return file;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                  "Track Order",
                  style: boldTextStyle(
                    size: 20,
                  ),
                )
              ],
            ),
            10.height,
            Expanded(
                child: StreamBuilder<OrderModel>(
                    stream: myOrderDBService.orderById(
                        id: widget.orderId.validate()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var order = snapshot.data!;
                        int currentIndex = order.orderStatus ==
                                    ORDER_AWAIT_CUSTOMER ||
                                order.orderStatus == ORDER_CONFIRMED
                            ? 1
                            : order.orderStatus == ORDER_BUYFROM
                                ? 2
                                : order.orderStatus == ORDER_PICKUP
                                    ? 3
                                    : order.orderStatus == ORDER_ARRIVED
                                        ? 4
                                        : order.orderStatus == ORDER_DELIVERED
                                            ? 5
                                            : 0;

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: order.deliveryBoyId.isEmptyOrNull
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Your Order is queued",
                                          style: boldTextStyle(),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: colorPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Row(
                                            children: [
                                              Icon(
                                                controller.playerState.isStopped
                                                    ? Icons.play_arrow
                                                    : Icons.pause,
                                                color: white,
                                              ),
                                              5.width,
                                              Text(
                                                controller.playerState.isStopped
                                                    ? "Play"
                                                    : "Pause",
                                                style: boldTextStyle(
                                                  size: 14,
                                                  color: white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ).onTap(() {
                                          handlePlay(
                                              fileUrl:
                                                  order.orderUrl.validate(),
                                              time: order.createdAt.toString());
                                        }),
                                      ],
                                    )
                                  : Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Image.asset(
                                            "assets/avatar.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        10.width,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Abraham Great",
                                                style: boldTextStyle(
                                                  size: 14,
                                                ),
                                              ),
                                              10.height,
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: colorPrimary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Image.asset(
                                                      "assets/call.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  10.width,
                                                  Container(
                                                    height: 30,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: colorPrimary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Image.asset(
                                                      "assets/message.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ).onTap(() {
                                                    OrderChatScreen()
                                                        .launch(context);
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              timeago.format(order.createdAt!),
                                              style: boldTextStyle(
                                                size: 10,
                                              ),
                                            ),
                                            10.height,
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                  color: colorPrimary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.play_arrow,
                                                    color: white,
                                                  ),
                                                  5.width,
                                                  Text(
                                                    "Play",
                                                    style: boldTextStyle(
                                                      size: 14,
                                                      color: white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ).onTap(() {
                                              handlePlay(
                                                  fileUrl:
                                                      order.orderUrl.validate(),
                                                  time: order.createdAt
                                                      .toString());
                                            }),
                                          ],
                                        )
                                      ],
                                    ),
                            ),
                            20.height,
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: context.cardColor,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AudioFileWaveforms(
                                      size: Size(
                                          MediaQuery.of(context).size.width,
                                          60.0),
                                      playerController: controller,
                                      enableSeekGesture: true,
                                      waveformType: WaveformType.fitWidth,
                                      waveformData: waveformData,
                                      playerWaveStyle: const PlayerWaveStyle(
                                        fixedWaveColor: Colors.white54,
                                        liveWaveColor: colorPrimary,
                                        spacing: 6,
                                        backgroundColor: grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).visible(waveformData.isNotEmpty &&
                                controller.playerState.isPlaying),
                            Expanded(
                              child: ListView(
                                children: [
                                  OrderAccepted(
                                    order: order,
                                    index: currentIndex,
                                    onConfirm: () {
                                      handleOrderConfirmed(
                                          orderID: order.id.validate());
                                    },
                                  ),
                                  OrderArrivedBuyFrom(
                                    index: currentIndex,
                                    order: order,
                                  ),
                                  OrderPaidPickup(
                                    index: currentIndex,
                                    order: order,
                                  ),
                                  OrderArrivedLocation(
                                    index: currentIndex,
                                    order: order,
                                  ),
                                  OrderDelivered(
                                    index: currentIndex,
                                    order: order,
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      }
                      return Loader();
                    }))
          ],
        ),
      )),
    );
  }

  handleOrderConfirmed({required String orderID}) async {
    await myOrderDBService.updateDocument({
      "orderStatus": ORDER_CONFIRMED,
    }, orderID);
    toast("Order Confirmed");
  }
}
