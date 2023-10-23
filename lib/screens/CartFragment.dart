import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/CartItemComponent.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'MyOrderScreen.dart';

class CartFragment extends StatefulWidget {
  static String tag = '/CartFragment';

  @override
  CartFragmentState createState() => CartFragmentState();
}

class CartFragmentState extends State<CartFragment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      appBar: appBarWidget(appStore.translate('cart'),
          showBack: false,
          elevation: 0,
          textSize: 28,
          color: appStore.isDarkMode ? scaffoldColorDark : Colors.white),
      body: Stack(
        children: [
          StreamBuilder<List<MenuModel>>(
            stream: myCartDBService.cartList(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text(snapshot.error.toString()).center();
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return noDataWidget(
                          errorMessage: appStore.translate('noDataFound'))
                      .center();
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16, bottom: 16, right: 16),
                    itemBuilder: (context, index) => CartItemComponent(
                      cartData: snapshot.data![index],
                      onUpdate: () {
                        setState(() {});
                      },
                    ),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                  );
                }
              }
              return Loader().center();
            },
          ),
          Observer(
            builder: (_) => viewCartWidget(
                    context: context,
                    totalItemLength: '${appStore.mCartList.length}',
                    onTap: () async {
                      MyOrderScreen().launch(context);
                    })
                .visible(appStore.mCartList.isNotEmpty && appStore.isLoggedIn),
          ),
        ],
      ),
    );
  }
}
