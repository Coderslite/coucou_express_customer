import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/OrderSuccessFullyDialog.dart';
import '../function/send_notification.dart';
import '../main.dart';
import '../models/AddressModel.dart';
import '../models/OrderItemData.dart';
import '../models/OrderModel.dart';
import '../services/GetLocationLatLng.dart';
import '../services/GetRestaurantLocation.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'package:google_maps_webservice/src/places.dart';
import 'package:http/http.dart' as http;

import 'MyAddressScreen.dart';

class VoiceOrder extends StatefulWidget {
  @override
  _VoiceOrderState createState() => _VoiceOrderState();
}

class _VoiceOrderState extends State<VoiceOrder> {
  final TextEditingController _controller = TextEditingController();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  // final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  AudioPlayer audioPlayer = AudioPlayer();

  String? _recordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Timer? _recorderTimer;
  Timer? _playerTimer;
  int recorderTime = 0;
  Duration totalDuration = Duration();
  Duration currentPosition = Duration();
  bool wantToRecord = true;
  bool stepOne = true;
  bool onGoogle = false;
  String restaurantName = '';

  Future<void> startRecording() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _recordingPath = '${appDocDir.path}/recording.aac';
    try {
      await _audioRecorder.startRecorder(
        toFile: _recordingPath,
      );
      recorderTime = 0;
      _isRecording = true;
      _recorderTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          recorderTime += 1;
        });
      });
    } catch (e) {
      print('Failed to start recording: $e');
      toast('Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      try {
        await _audioRecorder.stopRecorder();
        await _audioRecorder.closeRecorder();
        setState(() {
          _isRecording = false;
          _recorderTimer!.cancel();
          wantToRecord = false;
        });
        print(_recordingPath);
      } catch (e) {
        print('Failed to stop recording: $e');
      }
    }
  }

  Future<void> startPlayback() async {
    if (File(_recordingPath!).existsSync()) {
      try {
        await audioPlayer.play(DeviceFileSource(_recordingPath!)).then((value) {
          trackProgress();
        });
      } catch (e) {
        print('Failed to start playback: $e');
        toast('Failed to start playback: $e');
      }
    } else {
      print('Recording file does not exist.');
      toast('Recording file does not exist.');
    }
  }

  Future<void> stopPlayback() async {
    if (_isPlaying) {
      try {
        audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } catch (e) {
        print('Failed to stop playback: $e');
      }
    }
  }

  Future<void> order() async {
    if (appStore.addressModel == null) {
      toast(appStore.translate('select_address'));
      await Future.delayed(Duration(milliseconds: 100));

      AddressModel? data = await MyAddressScreen(isOrder: true).launch(context);
      if (data != null && data is AddressModel) {
        appStore.setAddressModel(data);
        setState(() {});
      }
    } else {
      var downloadUrl = await uploadFile(File(_recordingPath!));
      if (downloadUrl != 'null') {
        var id = DateTime.now().millisecondsSinceEpoch;

        // if (restaurantId!.isEmpty) return toast(errorMessage);

        OrderModel orderModel = OrderModel();

        orderModel.userId = appStore.userId;
        orderModel.orderStatus = !onGoogle ? ORDER_PENDING : ORDER_RECEIVED;
        orderModel.createdAt = DateTime.now();
        orderModel.updatedAt = DateTime.now();
        orderModel.totalAmount = null;
        orderModel.totalItem = null;
        orderModel.orderId = id.toString();
        orderModel.listOfOrder = [];
        orderModel.restaurantName = restaurantName;
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
          SendNotification.handleSentToAgent(value.id);
          showInDialog(
            context,
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: radius(12)),
            child: OrderSuccessFullyDialog(),
          );
        }).catchError((e) {
          log(e);
        });
      } else {
        print("failed to upload");
      }
    }
  }

  Future<String> uploadFile(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage
        .ref('/uploads/')
        .child(getStringAsync(USER_ID) + DateTime.now().millisecond.toString());
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }

  @override
  void initState() {
    openTheRecorder().then((value) {});
    super.initState();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _audioRecorder.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void trackProgress() {
    audioPlayer.getDuration().then((value) {
      setState(() {
        totalDuration = value!;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
        print("current Position" + currentPosition.toString());
      });
    });

    setState(() {
      _isPlaying = true;
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    stopRecording();
    stopPlayback();
    _audioRecorder.closeRecorder();
    audioPlayer.dispose();
    _playerTimer!.cancel();
    _recorderTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(
              20,
            ),
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          spacing: 20,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _isRecording
                ? Text(
                    Duration(seconds: recorderTime).inMinutes.toString() +
                        "m" +
                        ":" +
                        Duration(seconds: recorderTime)
                            .inSeconds
                            .remainder(60)
                            .toString() +
                        "s",
                    style: primaryTextStyle(size: 26, color: redColor))
                : Container(),
            10.height,
            Container(
              child: Column(
                children: [
                  Text(
                    "Voice Order",
                    style: boldTextStyle(size: 25),
                  ),
                  Text(
                    stepOne ? "Record what you want to buy" : "",
                    style: primaryTextStyle(size: 17),
                  ),
                ],
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: wantToRecord
                    ? Column(
                        children: [
                          InkWell(
                            onTap:
                                _isRecording ? stopRecording : startRecording,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: AvatarGlow(
                                endRadius: 20,
                                animate: _isRecording ? true : false,
                                child: Icon(
                                  Icons.record_voice_over,
                                  size: 60,
                                  color:
                                      _isRecording ? redColor : mediumSeaGreen,
                                ),
                              ),
                            ),
                          ),
                          20.height,
                          Text(
                            _isRecording
                                ? "Recording......."
                                : "Tap the icon to Record / Stop",
                            style: primaryTextStyle(),
                          ),
                        ],
                      )
                    : stepOne
                        ? Column(
                            children: [
                              ProgressBar(
                                timeLabelTextStyle: primaryTextStyle(),
                                progress: currentPosition,
                                buffered: Duration(milliseconds: 2000),
                                total: totalDuration,
                                onSeek: (duration) {
                                  audioPlayer.seek(duration);
                                },
                              ),
                              CircleAvatar(
                                radius: 30,
                                child: IconButton(
                                  onPressed:
                                      _isPlaying ? stopPlayback : startPlayback,
                                  icon: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    child: _isPlaying
                                        ? Icon(
                                            Icons.pause,
                                            size: 35,
                                          )
                                        : Icon(
                                            Icons.play_arrow,
                                            size: 35,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : AppTextField(
                            textFieldType: TextFieldType.MULTILINE,
                            decoration: InputDecoration(
                                hintText:
                                    "Enter Your Preferred Buy From Place(Optional)"),
                            onChanged: (p0) {
                              restaurantName = p0.toString();
                            },
                          ),
              ),
            ),
            20.height,
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: wantToRecord
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _audioRecorder.openRecorder();
                              totalDuration = Duration();
                              currentPosition = Duration();
                              stepOne = true;
                              wantToRecord = true;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Record Again",
                                style: primaryTextStyle(),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.loop)
                            ],
                          ),
                        ),
                        stepOne
                            ? IconButton(
                                onPressed: () async {
                                  setState(() {
                                    stepOne = false;
                                  });
                                  if (appStore.addressModel == null) {
                                    toast(appStore.translate('select_address'));
                                    await Future.delayed(
                                        Duration(milliseconds: 100));

                                    AddressModel? data =
                                        await MyAddressScreen(isOrder: true)
                                            .launch(context);
                                    if (data != null && data is AddressModel) {
                                      appStore.setAddressModel(data);
                                      setState(() {});
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: context.iconColor,
                                  size: 30,
                                ))
                            : TextButton(
                                onPressed: () {
                                  order();
                                },
                                child: Text("Place Order"))
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
