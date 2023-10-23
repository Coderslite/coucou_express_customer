import 'package:flutter/material.dart';
import 'package:fooddelivery/components/CategoryItemComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/CategoryModel.dart';
import '../utils/Widgets.dart';

class AllCategories extends StatefulWidget {
  const AllCategories({super.key});

  @override
  State<AllCategories> createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget('All Services', color: context.cardColor),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<CategoryModel>>(
                    stream: categoryDBService.categories(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text(snapshot.error.toString()).center();

                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return noDataWidget(errorMessage: errorMessage)
                              .center();
                        } else {
                          return GridView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: CategoryItemComponent(
                                    category: snapshot.data![index]),
                              );
                            },
                            itemCount: snapshot.data!.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200),
                          );
                        }
                      }
                      return Loader().center();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
