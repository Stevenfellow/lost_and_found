// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/src/utils/app_colors.dart';
import 'package:lost_and_found/src/widget/objet_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  // late Stream<QuerySnapshot<Map<String, dynamic>>> categoriesStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> itemsStream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> itemsStreamSub;
  bool isLost = true;
  String selectedCategory = "Electronics";
  String currentObject = "object";
  List filteredCats = [];
  List categories = [];

  var options = [
    'Electronics',
    'Book Equipments',
    'ID cards',
    'Documents',
    'others'
  ];

  @override
  void initState() {
    // categoriesStream =
    //     FirebaseFirestore.instance.collection("lost_objet").snapshots();
    _chooseStream();
    // itemsStream = FirebaseFirestore.instance
    //     .collection("lost_objet")
    //     .orderBy("createdAt", descending: true)
    //     .where("category_id", isEqualTo: selectedCategory)
    //     .snapshots();

    // foundStream = FirebaseFirestore.instance
    //     .collection("found_objet")
    //     .orderBy("createdAt", descending: true)
    //     .where("category_id", isEqualTo: selectedCategory)
    //     .snapshots();

    super.initState();
  }

  void _chooseStream() {
    itemsStream = isLost
        ? FirebaseFirestore.instance
            .collection("lost_objet")
            .orderBy("createdAt", descending: true)
            .where("category_id", isEqualTo: selectedCategory)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("found_objet")
            .orderBy("createdAt", descending: true)
            .where("category_id", isEqualTo: selectedCategory)
            .snapshots();

    categories.clear();
    itemsStream.listen((event) {
      categories.addAll(event.docs.map((e) => e.data()));
      filteredCats = categories;
    });
  }

  void _searchText(String value) {
    filteredCats = categories
        .where((e) =>
            e['category_id'].toLowerCase().contains(value) ||
            e['title'].toLowerCase().contains(value))
        .toList();
    // print(filteredCats);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        title: TextField(
          onChanged: _searchText,
          decoration: const InputDecoration(hintText: 'Search Here'),
        ),
        // const Text(
        //   "Search Here",
        //   style: TextStyle(
        //     color: AppColors.primaryGrayText,
        //     fontWeight: FontWeight.w500,
        //     fontSize: 20,
        //   ),
        // ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: screenWidth,
            height: screenHeight * .05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isLost,
                      onChanged: (value) {
                        print(value);
                        if (isLost != true) {
                          setState(() {
                            isLost = value!;
                            _chooseStream();
                          });
                        }
                      },
                    ),
                    const Text(
                      "Lost Object",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isLost,
                      onChanged: (value) {
                        print(value);
                        if (isLost != false) {
                          setState(() {
                            isLost = value!;
                            _chooseStream();
                          });
                        }
                      },
                    ),
                    const Text(
                      "Found Object",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            width: screenWidth,
            height: screenHeight * .05,
            child: Row(
              children: [
                Expanded(
                  child:
                      // StreamBuilder(
                      //   stream: categoriesStream,
                      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                      //     if (!snapshot.hasData) {
                      //       return const Center(child: CircularProgressIndicator());
                      //     }
                      //     if (snapshot.hasError) {
                      //       return Text("${snapshot.error}");
                      //     }

                      //     if (snapshot.hasData) {
                      //       if (snapshot.data!.size == 0) {
                      //         return Container(); //? shimmer yet
                      //       } else {
                      //         List<QueryDocumentSnapshot<Object?>> cats =
                      //             snapshot.data!.docs;

                      //         filteredCats = categories = cats;

                      // return
                      ListView(
                    scrollDirection: Axis.horizontal,
                    children: options.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          // selectedCategory = cat['category_id'];
                          selectedCategory = cat;
                          // currentObject = cat['title'];
                          currentObject = cat;
                          _chooseStream();
                          setState(() {});

                          print(cat);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Chip(
                            backgroundColor: selectedCategory == cat
                                ? AppColors.primary
                                : null,
                            label: Text(
                              // cat['title'],
                              cat,
                              style: TextStyle(
                                color: selectedCategory == cat
                                    ? Colors.white
                                    : AppColors.primaryText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  //       }
                  //     }
                  //     return Container();
                  //   },
                  // ),
                )
              ],
            ),
          ),
          Expanded(
            child:
                // StreamBuilder<QuerySnapshot>(
                // stream: isLost
                //     ? FirebaseFirestore.instance
                //         .collection("lost_objet")
                //         .orderBy("createdAt", descending: true)
                //         .where("category_id", isEqualTo: selectedCategory)
                //         .snapshots()
                //     : FirebaseFirestore.instance
                //         .collection("found_objet")
                //         .orderBy("createdAt", descending: true)
                //         .where("category_id", isEqualTo: selectedCategory)
                //         .snapshots(),
                // stream: itemsStream,
                // builder: ((BuildContext context,
                //     AsyncSnapshot<QuerySnapshot> snapshot) {
                //   print(snapshot.data!.docs);
                //   if (!snapshot.hasData) {
                //     return const Center(child: CircularProgressIndicator());
                //   }
                //   if (snapshot.hasError) {
                //     return Center(
                //       child: Text(
                //         "${snapshot.error}",
                //         style: const TextStyle(
                //           color: Colors.red,
                //         ),
                //       ),
                //     );
                //   }

                //   if (snapshot.hasData) {
                //     var data = snapshot.data!.docs;

                // if (snapshot.data!.size == 0) {
                //   return
                //   Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Center(
                //       child: isLost
                //           ? Text(
                //               "No lost $currentObject yet",
                //               style: const TextStyle(
                //                 color: AppColors.primaryText,
                //                 fontSize: 18,
                //               ),
                //             )
                //           : Text(
                //               "No Found $currentObject yet",
                //               style: const TextStyle(
                //                 color: AppColors.primaryText,
                //                 fontSize: 18,
                //               ),
                //             ),
                //     ),
                //   );
                // } else {
                // return
                ListView.separated(
              //controller: scrollController,
              // itemCount: snapshot.data!.size,
              itemCount: filteredCats.length,
              separatorBuilder: (context, index) {
                return Container(
                  height: screenHeight * 0.01,
                  decoration: const BoxDecoration(color: AppColors.grayScale),
                );
              },
              itemBuilder: (context, index) {
                var object = filteredCats[index];

                return ObjetWidget(
                  title: object['title'],
                  description: object['description'],
                  image: object['image'],
                  userId: object['user_id'],
                  userImage: object['user_photo'],
                  username: object['user_name'],
                  createAd: object['createdAt'],
                  usersubname: object['user_subname'],
                  isLost: true,
                );
              },
            ),
            //   }
            // }

            //     return Container();
            //   }),
            // ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// DropdownButtonFormField<String>(
//                               onChanged: (value) {
//                                 selectedCategory ??= {};
//                                 selectedCategory!['id'] = value;
//                                 print(value);
//                                 setState(() {});
//                               },
//                               hint: const Text("selected category"),
//                               validator: (value) {
//                                 if (value == null) {
//                                   return "Please Select a category";
//                                 }
//                                 return null;
//                               },
//                               value: selectedCategory!['id'],
//                               items: cats.map((d) {
//                                 var cat = d.data()! as Map<String, dynamic>;
//                                 cat['id'] = d.id;
//                                 return DropdownMenuItem<String>(
//                                   child: Text("${cat['title']}"),
//                                   value: cat['id'],
//                                 );
//                               }).toList(),
//                             );
