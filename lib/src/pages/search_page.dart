// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isLost = true;
  String selectedCategory = "Electronics";
  String currentObject = "object";
  List filteredCats = [];
  List categories = [];
  final _searchController = TextEditingController();

  var options = [
    'Electronics',
    'Book Equipments',
    'ID cards',
    'Documents',
    'others'
  ];

  @override
  void initState() {
    _chooseStream();

    super.initState();
  }

  void _chooseStream() {
    itemsStream = isLost
        ? FirebaseFirestore.instance
            .collection("lost_objet")
            .orderBy("createdAt", descending: true)
            .where("category_id", isEqualTo: selectedCategory)
            .snapshots()
            .asBroadcastStream()
        : FirebaseFirestore.instance
            .collection("found_objet")
            .orderBy("createdAt", descending: true)
            .where("category_id", isEqualTo: selectedCategory)
            .snapshots()
            .asBroadcastStream();
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
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
                onPressed: (() async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? img =
                      await _picker.pickImage(source: ImageSource.gallery);
                }),
                icon: const Icon(Icons.add_a_photo)),
          )
        ],
        title: TextField(
          onChanged: (value) => setState(() {}),
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search Here'),
        ),
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: options.map((cat) {
                      return GestureDetector(
                        onTap: () {
                          selectedCategory = cat;
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
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: itemsStream,
              builder: ((BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "${snapshot.error}",
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  var data = snapshot.data!.docs;

                  if (snapshot.data!.size == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: isLost
                            ? Text(
                                "No lost $currentObject yet",
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                ),
                              )
                            : Text(
                                "No Found $currentObject yet",
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    );
                  } else {
                    categories = snapshot.data!.docs;
                    filteredCats = categories
                        .where((e) =>
                            e['category_id']
                                .toLowerCase()
                                .contains(_searchController.text) ||
                            e['title']
                                .toLowerCase()
                                .contains(_searchController.text))
                        .toList();
                    print(filteredCats);
                    return ListView.separated(
                      itemCount: filteredCats.length,
                      separatorBuilder: (context, index) {
                        return Container(
                          height: screenHeight * 0.01,
                          decoration:
                              const BoxDecoration(color: AppColors.grayScale),
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
                    );
                  }
                }

                return Container();
              }),
            ),
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
