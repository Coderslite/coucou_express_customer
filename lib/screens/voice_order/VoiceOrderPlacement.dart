import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fooddelivery/screens/track_order/OrderTracker.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/OrderSuccessFullyDialog.dart';
import '../../main.dart';
import '../../models/AddressModel.dart';
import '../../models/OrderModel.dart';
import '../../utils/Constants.dart';
import '../MyAddressScreen.dart';

class VoiceOrderPlacement extends StatefulWidget {
  const VoiceOrderPlacement({super.key});

  @override
  State<VoiceOrderPlacement> createState() => _VoiceOrderPlacementState();
}

class _VoiceOrderPlacementState extends State<VoiceOrderPlacement> {
  late final RecorderController recorderController;
  PlayerController controller = PlayerController();
  List<double> waveformData = [];

  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;
  int counter = 0;
  Timer? timer;

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
        }
      } else {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      handleGenerateWave();
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  handleGenerateWave() async {
    waveformData = await controller.extractWaveformData(
      path: path!,
      noOfSamples: 100,
    );
    setState(() {});
  }

  handlePlay() async {
// Or directly extract from preparePlayer and initialise audio player
    await controller.preparePlayer(
      path: path!,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    await controller.startPlayer(finishMode: FinishMode.stop);
    setState(() {});
    controller.onCompletion.listen((_) {
      controller.stopPlayer();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  handleReset() async {
    path = null;
    waveformData.clear();
    path = null;
    setState(() {});
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  Future<void> order() async {
    try {
      setState(() {
        appStore.setIsUploading(true);
      });
      if (appStore.addressModel == null) {
        toast(appStore.translate('select_address'));
        await Future.delayed(Duration(milliseconds: 100));

        AddressModel? data =
            await MyAddressScreen(isOrder: true).launch(context);
        if (data != null) {
          appStore.setAddressModel(data);
          setState(() {});
          makeRequest();
        }
      } else {
        if (appStore.addressModel!.addressLocation == null) {
          toast(appStore.translate('select_address'));
          await Future.delayed(Duration(milliseconds: 100));

          AddressModel? data =
              await MyAddressScreen(isOrder: true).launch(context);
          if (data != null) {
            appStore.setAddressModel(data);

            makeRequest();
          }
        } else {
          makeRequest();
        }
      }
    } catch (err) {
      toast(err.toString());
    }
  }

  makeRequest() async {
    var downloadUrl = await uploadFile(File(path!));
    if (downloadUrl != 'null') {
      var id = DateTime.now().millisecondsSinceEpoch;

      // if (restaurantId!.isEmpty) return toast(errorMessage);

      OrderModel orderModel = OrderModel();

      orderModel.userId = appStore.userId;
      orderModel.orderStatus = ORDER_PENDING;
      orderModel.createdAt = DateTime.now();
      orderModel.updatedAt = DateTime.now();
      orderModel.totalAmount = null;
      orderModel.totalItem = null;
      orderModel.orderId = id.toString();
      orderModel.listOfOrder = [];
      orderModel.restaurantName = '';
      orderModel.restaurantId = null;
      orderModel.deliveryLocation = appStore.addressModel!.addressLocation;
      orderModel.deliveryAddress = appStore.addressModel!.address;
      orderModel.pavilionNo = appStore.addressModel!.pavilionNo;
      orderModel.userAddress = appStore.addressModel!.address;
      orderModel.paymentMethod = CASH_ON_DELIVERY;
      orderModel.deliveryCharge = getIntAsync(AROUND_UCAD_CHARGES.toString());

      orderModel.restaurantCity = getStringAsync(USER_CITY_NAME);
      orderModel.paymentStatus = PAYMENT_STATUS_PENDING;
      // orderModel.userLocation = GeoPoint(
      //     appStore.addressModel!.userLocation!.latitude,
      //     appStore.addressModel!.userLocation!.longitude);
      orderModel.orderType = "VoiceOrder";
      orderModel.orderUrl = downloadUrl;

      myOrderDBService.addDocument(orderModel.toJson()).then((value) async {
        // SendNotification.handleSentToAgent(value.id);
        setState(() {
          appStore.setIsUploading(false);
        });
        Navigator.pop(context);
        showInDialog(
          context,
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: radius(12)),
          child: OrderSuccessFullyDialog(
            orderId: value.id,
          ),
        );
      }).catchError((e) {
        log(e);
      });
    } else {
      print("failed to upload");
    }
  }

  Future<String> uploadFile(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage
        .ref('/uploads/')
        .child(getStringAsync(USER_ID) + DateTime.now().millisecond.toString());
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => {});
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
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
                    "Voice Order Placement",
                    style: boldTextStyle(
                      size: 20,
                    ),
                  )
                ],
              ),
              20.height,
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: context.cardColor),
                    child: Text(
                      'Record your voice order here',
                      style: boldTextStyle(
                        size: 16,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                            color: (isRecording ? fireBrick : colorPrimary)
                                .withOpacity(0.1)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Image.asset(
                                "assets/record.png",
                                fit: BoxFit.cover,
                                color: isRecording == true ? fireBrick : null,
                              ),
                            ),
                            Text(
                              "Recording",
                              style: boldTextStyle(color: fireBrick),
                            ).visible(isRecording)
                          ],
                        ),
                      ).onTap(() {
                        _startOrStopRecording();
                      }),
                      5.height,
                      Text(
                        "Tap to Record / Stop",
                        style: boldTextStyle(
                          size: 16,
                        ),
                      ).visible(!isRecording),
                      20.height,
                      !isRecording && path != null
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: context.cardColor,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: colorPrimary,
                                    child: Icon(
                                      controller.playerState.isStopped
                                          ? Icons.play_arrow
                                          : Icons.pause,
                                      color: white,
                                    ),
                                  ).onTap(() {
                                    handlePlay();
                                  }),
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
                            )
                          : Container(),
                      !isRecording
                          ? Container()
                          : Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.cardColor,
                              ),
                              child: AudioWaveforms(
                                enableGesture: true,
                                size:
                                    Size(MediaQuery.of(context).size.width, 60),
                                recorderController: recorderController,
                                waveStyle: const WaveStyle(
                                  waveColor: fireBrick,
                                  extendWaveform: true,
                                  showMiddleLine: false,
                                  showTop: false,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  // color: const Color(0xFF1E1B26),
                                ),
                              ).center(),
                            )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      path.isEmptyOrNull
                          ? Container()
                          : Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: BoxDecoration(
                                border: Border.all(color: colorPrimary),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Delete",
                                style: primaryTextStyle(
                                  color: colorPrimary,
                                ),
                              ).center(),
                            ).onTap(() {
                              handleReset();
                            }),
                      path.isEmptyOrNull
                          ? Container()
                          : Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Next",
                                style: primaryTextStyle(
                                  color: white,
                                ),
                              ).center(),
                            ).onTap(() {
                              // handlePlay();
                              order();
                            }),
                    ],
                  )
                ],
              )),
              Container(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
