import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/UserModel.dart';
import 'package:fooddelivery/screens/OTPScreen.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

import 'MyCartService.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> _signInWithGoogle() async {
  GoogleSignInAccount googleSignInAccount = (await googleSignIn.signIn())!;

  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await auth.signInWithCredential(credential);
  final User user = authResult.user!;

  assert(!user.isAnonymous);

  await googleSignIn.signOut();
  auth.signOut();

  return auth.currentUser;
}

Future<User?> _signInWithEmail(String email, String password) async {
  return await auth.signInWithEmailAndPassword(email: email, password: password).then((value) {
    return value.user;
  }).catchError((e) {
    throw e;
  });
}

Future<void> signUpWithEmail(String name, String email, String password, String phone) async {
  UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);

  if (userCredential.user != null) {
    User currentUser = userCredential.user!;
    UserModel userModel = UserModel();

    /// Create user
    userModel.uid = currentUser.uid.validate();
    userModel.email = currentUser.email.validate();
    userModel.password = password.validate();
    userModel.name = name.validate();
    userModel.number = phone.validate();
    userModel.photoUrl = currentUser.photoURL.validate();
    userModel.loginType = LoginTypeApp;
    userModel.updatedAt = DateTime.now();
    userModel.createdAt = DateTime.now();
    userModel.listOfAddress = [];
    userModel.isAdmin = false;
    userModel.isTester = false;
    userModel.role = USER_ROLE;
    userModel.favRestaurant = [];

    userModel.city = '';
    userModel.isDeleted = false;

    userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);

    await userDBService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
      await signInWithEmail(email: email, password: password).then((value) {
        //
      });
    }).catchError((e) {
      throw e;
    });
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<void> signInWithGoogle() async {
  await _signInWithGoogle().then((currentUser) async {
    UserModel userModel = UserModel();

    if (await userDBService.isUserExist(currentUser!.email, LoginTypeGoogle)) {
      //
      await userDBService.getUserByEmail(currentUser.email).then((user) async {
        if (user.role == USER_ROLE) {
          ///Return user data
          userModel = user;
        } else {
          throw '${appStore.translate('already_registered')} ${user.role}';
        }
      }).catchError((e) {
        throw e;
      });
    } else {
      /// Create user
      userModel.uid = currentUser.uid.validate();
      userModel.email = currentUser.email.validate();
      userModel.name = currentUser.displayName.validate();
      userModel.photoUrl = currentUser.photoURL.validate();
      userModel.number = currentUser.phoneNumber.validate();
      userModel.updatedAt = DateTime.now();
      userModel.createdAt = DateTime.now();
      userModel.isAdmin = false;
      userModel.isTester = false;
      userModel.loginType = LoginTypeGoogle;
      userModel.listOfAddress = [];
      userModel.role = USER_ROLE;
      userModel.favRestaurant = [];
      userModel.password = '';
      userModel.city = '';
      userModel.isDeleted = false;
      userModel.oneSignalPlayerId = getStringAsync(PLAYER_ID);

      await userDBService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) {
        //
      }).catchError((e) {
        throw e;
      });
    }
    await saveUserDetails(userModel, LoginTypeGoogle);
  }).catchError((e) {
    throw errorSomethingWentWrong;
  });
}

Future<UserModel> signInWithEmail({String? email, String? password}) async {
  if (await userDBService.isUserExist(email, LoginTypeApp)) {
    return await _signInWithEmail(email!, password!).then((user) async {
      return await userDBService.loginWithEmail(email: user!.email, password: password).then((value) async {
        await saveUserDetails(value, LoginTypeApp);
        if (value.role == USER_ROLE) {
          ///Return user data
          return value;
        } else {
          throw '${appStore.translate('already_registered')} ${value.role}';
        }
      }).catchError((e) {
        throw e;
      });
    });
  } else {
    throw appStore.translate('not_registered');
  }
}

Future<void> saveUserDetails(UserModel userModel, String loginType) async {
  await setValue(LOGIN_TYPE, loginType);

  await setValue(ADMIN, userModel.isAdmin.validate());
  await setValue(TESTER, userModel.isTester.validate());
  await setValue(USER_ROLE, userModel.role.validate());
  await setValue(FAVORITE_RESTAURANT, jsonEncode(userModel.favRestaurant.validate()));

  await appStore.setLoggedIn(true);
  await appStore.setUserId(userModel.uid);
  await appStore.setFullName(userModel.name);
  await appStore.setUserEmail(userModel.email);
  await appStore.setUserProfile(userModel.photoUrl);
  await appStore.setPhoneNumber(userModel.number);
  await appStore.setCityName(userModel.city);

  /// Initialize cart service with updated user id
  myCartDBService = MyCartDBService();
  appStore.clearCart();
  myCartDBService.getCartList().then((value) {
    value.forEach((element) {
      appStore.addToCart(element);
    });
  });

  /// Update user data
  userDBService.updateDocument({
    UserKeys.oneSignalPlayerId: getStringAsync(PLAYER_ID).validate(),
    CommonKeys.updatedAt: DateTime.now(),
  }, userModel.uid);

  setFavouriteRestaurant();
}

Future<void> setFavouriteRestaurant() async {
  if (getStringAsync(FAVORITE_RESTAURANT).isNotEmpty) {
    Iterable? it = jsonDecode(getStringAsync(FAVORITE_RESTAURANT));

    if (it != null && it.isNotEmpty) {
      favRestaurantList.clear();
      favRestaurantList.addAll(it.map((e) => e.toString()).toList());
    }
  }
}

Future<void> logout() async {
  userDBService.updateDocument({
    UserKeys.oneSignalPlayerId: '',
    CommonKeys.updatedAt: DateTime.now(),
  }, appStore.userId).then((value) async {
    //
  }).catchError((e) {
    throw e;
  });
  await removeKey(IS_NOTIFICATION_ON);
  await removeKey(USER_HOME_ADDRESS);
  await removeKey(USER_ROLE);
  await removeKey(FAVORITE_RESTAURANT);
  await removeKey(TESTER);

  favRestaurantList.clear();

  appStore.setAddressModel(null);
  appStore.setLoggedIn(false);
  appStore.setUserId('');
  appStore.setFullName('');
  appStore.setUserEmail('');
  appStore.setUserProfile('');
  appStore.setCityName('');

  appStore.clearCart();
}

Future<void> forgotPassword({required String email}) async {
  await auth.sendPasswordResetEmail(email: email).then((value) {
    //
  }).catchError((error) {
    throw error.toString();
  });
}

Future<void> loginWithOTP(BuildContext context, String phoneNumber, {bool aIsResend = false, int? forceResendingToken = 0}) async {
  appStore.setLoading(true);
  await auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    timeout: 60.seconds,
    forceResendingToken: forceResendingToken,
    verificationCompleted: (PhoneAuthCredential credential) async {
      //
    },
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        toast(appStore.translate('phone_number_not_valid'));
        throw appStore.translate('phone_number_not_valid');
      } else {
        toast(e.toString());
        throw e.toString();
      }
    },
    codeSent: (String verificationId, int? resendToken) async {
      appStore.setLoading(false);
      OTPScreen(verificationId: verificationId, isCodeSent: true, phoneNumber: phoneNumber, resendToken: resendToken).launch(context);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      //
    },
  );
}
