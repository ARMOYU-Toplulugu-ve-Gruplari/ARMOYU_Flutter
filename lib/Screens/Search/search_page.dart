import 'dart:async';
import 'dart:developer';

import 'package:ARMOYU/Core/ARMOYU.dart';
import 'package:ARMOYU/Core/widgets.dart';
import 'package:ARMOYU/Functions/API_Functions/news.dart';
import 'package:ARMOYU/Models/news.dart';
import 'package:ARMOYU/Screens/News/news_list.dart';
import 'package:ARMOYU/Screens/News/news_page.dart';

import 'package:ARMOYU/Screens/Profile/profile_page.dart';
import 'package:ARMOYU/Widgets/Skeletons/search_skeleton.dart';
import 'package:ARMOYU/Widgets/text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ARMOYU/Functions/API_Functions/search.dart';

class SearchPage extends StatefulWidget {
  final bool appbar;
  final TextEditingController searchController;

  const SearchPage({
    super.key,
    required this.appbar,
    required this.searchController,
  });

  @override
  State<SearchPage> createState() => _SearchPagePage();
}

bool postsearchprocess = false;
Timer? searchTimer;

class _SearchPagePage extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  @override
  bool get wantKeepAlive => true;

  Widget widgetTPCard = ARMOYUWidget(
          scrollController: ScrollController(), content: [], firstFetch: true)
      .widgetTPlist();
  Widget widgetPOPCard = ARMOYUWidget(
          scrollController: ScrollController(), content: [], firstFetch: true)
      .widgetPOPlist();

  List<Widget> widgetSearch = [];

  bool firstProcces = false;
  @override
  void initState() {
    super.initState();

    widget.searchController.addListener(_onSearchTextChanged);

    if (!firstProcces) {
      getnewslist();
      firstProcces = !firstProcces;
    }
  }

  Future<void> getnewslist() async {
    if (eventlistProcces) {
      return;
    }
    eventlistProcces = true;
    FunctionsNews f = FunctionsNews();
    Map<String, dynamic> response = await f.fetch(newspage);
    if (response["durum"] == 0) {
      log(response["aciklama"]);
      eventlistProcces = false;
      //Tekrar çekmeyi dene
      getnewslist();
      return;
    }

    newsList.clear();
    for (dynamic element in response['icerik']) {
      if (mounted) {
        setState(() {
          newsList.add(
            News(
              newsID: element["haberID"],
              newsTitle: element["haberbaslik"],
              newsContent: "",
              author: element["yazar"],
              newsImage: element["resimminnak"],
              newssummary: element["ozet"],
              authoravatar: element["yazaravatar"],
              newsViews: element["goruntulen"],
            ),
          );
        });
      }
    }
    eventlistProcces = false;
  }

  void _onSearchTextChanged() {
    searchfunction(widget.searchController, widget.searchController.text);
  }

  @override
  void dispose() {
    widget.searchController.dispose();
    super.dispose();
  }

  Future<void> loadSkeletonpost() async {
    setState(() {
      widgetSearch.clear();
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
      widgetSearch.add(const SkeletonSearch());
    });
  }

  Future<void> searchfunction(
    TextEditingController controller,
    String text,
  ) async {
    if (controller.text == "" || controller.text.isEmpty) {
      searchTimer?.cancel();

      setState(() {
        widgetSearch.clear();
      });
      return;
    }

    searchTimer = Timer(const Duration(milliseconds: 500), () async {
      loadSkeletonpost();
      log("$text ${controller.text}");

      if (text != controller.text) {
        return;
      }
      FunctionsSearchEngine f = FunctionsSearchEngine();
      Map<String, dynamic> response = await f.searchengine(1, text);
      if (response["durum"] == 0) {
        log(response["aciklama"]);
        return;
      }

      try {
        setState(() {
          widgetSearch.clear();
        });
      } catch (e) {
        log(e.toString());
      }

      int dynamicItemCount = response["icerik"].length;
      //Eğer cevap gelene kadar yeni bir şeyler yazmışsa
      if (text != controller.text) {
        return;
      }
      for (int i = 0; i < dynamicItemCount; i++) {
        try {
          setState(() {
            widgetSearch.add(
              ListTile(
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    response["icerik"][i]["avatar"],
                  ),
                  backgroundColor: Colors.black,
                ),
                title: CustomText.costum1(response["icerik"][i]["Value"],
                    weight: FontWeight.bold),
                trailing: response["icerik"][i]["turu"] == "oyuncu"
                    ? const Icon(Icons.person)
                    : const Icon(Icons.groups),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(
                        userID: response["icerik"][i]["ID"], appbar: true),
                  ));
                },
              ),
            );
          });
        } catch (e) {
          log(e.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ARMOYU.bodyColor,
      body: widget.searchController.text != ""
          ? ListView.builder(
              controller: ScrollController(),
              itemCount: widgetSearch.length,
              itemBuilder: (context, index) {
                return widgetSearch[index];
              },
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      enableInfiniteScroll: true,
                      pauseAutoPlayOnTouch: true,
                      viewportFraction: 0.8,
                      autoPlayInterval: const Duration(seconds: 5),
                      scrollDirection: Axis.horizontal,
                      enlargeFactor: 0.2,
                      enlargeCenterPage: true,
                    ),
                    itemCount: newsList.length,
                    itemBuilder: (context, index, realIndex) {
                      return newsList.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsPage(
                                      news: newsList[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    image: CachedNetworkImageProvider(
                                      newsList[index].newsImage,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.8],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(7, 0, 7, 7),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                  newsList[index].authoravatar,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                newsList[index].author,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.visibility),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    newsList[index]
                                                        .newsViews
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            newsList[index].newssummary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: ARMOYU.screenWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ARMOYU.appbarColor,
                              ),
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 10),
                  widgetTPCard,
                  const SizedBox(height: 10),
                  widgetPOPCard,
                ],
              ),
            ),
    );
  }
}
