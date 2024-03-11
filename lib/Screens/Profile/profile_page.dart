// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:ARMOYU/Core/ARMOYU.dart';
import 'package:ARMOYU/Core/AppCore.dart';
import 'package:ARMOYU/Functions/API_Functions/blocking.dart';
import 'package:ARMOYU/Models/team.dart';

import 'package:ARMOYU/Screens/Chat/chatdetail_page.dart';
import 'package:ARMOYU/Screens/Profile/friendlist_page.dart';
import 'package:ARMOYU/Screens/Utility/fullscreenimage_page.dart';
import 'package:ARMOYU/Services/appuser.dart';
import 'package:ARMOYU/Widgets/utility.dart';
import 'package:ARMOYU/Widgets/detectabletext.dart';
import 'package:ARMOYU/Widgets/text.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ARMOYU/Functions/API_Functions/media.dart';
import 'package:ARMOYU/Functions/API_Functions/profile.dart';
import 'package:ARMOYU/Functions/functions_service.dart';
import 'package:ARMOYU/Widgets/buttons.dart';
import 'package:ARMOYU/Widgets/posts.dart';

class ProfilePage extends StatefulWidget {
  final int? userID; // Zorunlu olarak alınacak veri
  final String? username; // Zorunlu olmayan  veri
  final bool appbar; // Zorunlu olarak alınacak veri

  const ProfilePage({
    super.key,
    this.userID,
    required this.appbar,
    this.username,
  });
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

late TabController tabController;

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  int userID = -1;
  String userName = "...";
  String displayName = "...";
  String banneravatar =
      "https://upload.wikimedia.org/wikipedia/commons/7/71/Black.png";
  String banneravatarbetter =
      "https://upload.wikimedia.org/wikipedia/commons/7/71/Black.png";
  String avatar =
      "https://aramizdakioyuncu.com/galeri/ana-yapi/gifler/spinner.gif";
  String avatarbetter =
      "https://aramizdakioyuncu.com/galeri/ana-yapi/gifler/spinner.gif";

  int level = 0;

  int friendsCount = 0;
  int postsCount = 0;
  int awardsCount = 0;

  String country = "...";
  String province = "";
  String registerdate = "...";
  String job = "";
  String role = "...";
  String rolecolor = "FFFFFF";
  String aboutme = "";
  String burc = "...";

  Team? favoritakim;

  bool isFriend = false;

  bool isbeFriend = false;

  List<String> listFriendTOP3 = [
    "https://aramizdakioyuncu.com/galeri/ana-yapi/gifler/spinner.gif",
    "https://aramizdakioyuncu.com/galeri/ana-yapi/gifler/spinner.gif",
    "https://aramizdakioyuncu.com/galeri/ana-yapi/gifler/spinner.gif"
  ];
  String friendTextLine = "";

  bool isAppBarExpanded = true;
  late ScrollController pageMainscroller;
  late ScrollController galleryscrollcontroller;
  late ScrollController postsscrollcontroller;
  bool galleryproccess = false;

  String friendStatus = "Bekleniyor";
  Color friendStatuscolor = Colors.blue;

  bool ispostsVisible = true;
  bool isgalleryVisible = false;

  bool postsfetchproccess = false;

  int postscounter = 1;
  int gallerycounter = 1;

  bool firstgalleryfetcher = false;
  @override
  void initState() {
    super.initState();
    test();

    pageMainscroller = ScrollController();
    pageMainscroller.addListener(() {
      if (pageMainscroller.position.pixels >=
          pageMainscroller.position.maxScrollExtent * 0.5) {
        if (ispostsVisible) {
          profileloadPosts(postscounter, userID);
        }
        if (isgalleryVisible) {
          gallery(gallerycounter, userID);
        }
      }
      setState(() {
        isAppBarExpanded = pageMainscroller.offset <
            ARMOYU.screenHeight * 0.20; // veya başka bir eşik değeri
      });
    });

    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    tabController.addListener(() {
      if (tabController.indexIsChanging ||
          tabController.index != tabController.previousIndex) {
        if (tabController.index == 0) {
          setState(() {
            isgalleryVisible = false;
            ispostsVisible = true;
          });
        }
        if (tabController.index == 1) {
          if (!firstgalleryfetcher) {
            gallery(gallerycounter, userID);
          }

          setState(() {
            isgalleryVisible = true;
            ispostsVisible = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // TEST.cancel();
    super.dispose();
  }

  List<Widget> widgetPosts = [];
  final List<String> imageUrls = [];
  final List<String> imageufakUrls = [];
  final List<int> imagesownerID = [];

  profileloadPosts(int page, int userID) async {
    if (postsfetchproccess) {
      return;
    }
    postsfetchproccess = true;
    FunctionService f = FunctionService();
    Map<String, dynamic> response = await f.getprofilePosts(page, userID);
    if (response["durum"] == 0) {
      log(response["aciklama"]);
      postsfetchproccess = false;
      return;
    }

    if (response["icerik"].length == 0) {
      postsfetchproccess = false;
      return;
    }
    int dynamicItemCount = response["icerik"].length;

    for (int i = 0; i < dynamicItemCount; i++) {
      List<int> mediaIDs = [];
      List<int> mediaownerIDs = [];
      List<String> medias = [];
      List<String> mediasbetter = [];
      List<String> mediastype = [];
      List<String> mediadirection = [];

      if (response["icerik"][i]["paylasimfoto"].length != 0) {
        int mediaItemCount = response["icerik"][i]["paylasimfoto"].length;

        for (int j = 0; j < mediaItemCount; j++) {
          mediaIDs.add(response["icerik"][i]["paylasimfoto"][j]["fotoID"]);
          mediaownerIDs.add(response["icerik"][i]["sahipID"]);
          medias.add(response["icerik"][i]["paylasimfoto"][j]["fotominnakurl"]);
          mediasbetter
              .add(response["icerik"][i]["paylasimfoto"][j]["fotoufakurl"]);
          mediastype.add(
              response["icerik"][i]["paylasimfoto"][j]["paylasimkategori"]);
          mediadirection
              .add(response["icerik"][i]["paylasimfoto"][j]["medyayonu"]);
        }
      }
      if (mounted) {
        setState(() {
          widgetPosts.add(
            TwitterPostWidget(
              userID: response["icerik"][i]["sahipID"],
              profileImageUrl: response["icerik"][i]["sahipavatarminnak"],
              username: response["icerik"][i]["sahipad"],
              postID: response["icerik"][i]["paylasimID"],
              postText: response["icerik"][i]["paylasimicerik"],
              postDate: response["icerik"][i]["paylasimzamangecen"],
              mediaIDs: mediaIDs,
              mediaownerIDs: mediaownerIDs,
              mediaUrls: medias,
              mediabetterUrls: mediasbetter,
              mediatype: mediastype,
              mediadirection: mediadirection,
              postlikeCount: response["icerik"][i]["begenisay"],
              postcommentCount: response["icerik"][i]["yorumsay"],
              postMecomment: response["icerik"][i]["benyorumladim"],
              postMelike: response["icerik"][i]["benbegendim"],
              isPostdetail: false,
            ),
          );
        });
      }
    }
    postscounter = postscounter + 1;
    postsfetchproccess = false;
  }

  gallery(int page, int userID) async {
    firstgalleryfetcher = true;

    if (galleryproccess) {
      return;
    }
    galleryproccess = true;

    if (page == 1) {
      if (mounted) {
        setState(() {
          imageUrls.clear();
          imageufakUrls.clear();
        });
      }
    }

    FunctionsMedia f = FunctionsMedia();
    Map<String, dynamic> response = await f.fetch(userID, "-1", page);

    if (response["durum"] == 0) {
      log(response["aciklama"]);
      return;
    }

    if (response["icerik"].length == 0) {
      log("Sayfa Sonu");
      return;
    }

    for (int i = 0; i < response["icerik"].length; i++) {
      if (mounted) {
        setState(() {
          imageUrls.add(response["icerik"][i]["fotominnakurl"]);
          imageufakUrls.add(response["icerik"][i]["fotoufaklikurl"]);
          imagesownerID.add(response["icerik"][i]["fotosahipID"]);
        });
      }
    }
    galleryproccess = false;
    gallerycounter++;
  }

  Future<void> test() async {
    if (widget.userID == AppUser.ID) {
      userID = AppUser.ID;
      userName = AppUser.userName;
      displayName = AppUser.displayName;
      banneravatar = AppUser.banneravatar;
      banneravatarbetter = AppUser.banneravatarbetter;
      avatar = AppUser.avatar;
      avatarbetter = AppUser.avatarbetter;
      level = AppUser.level;
      friendsCount = AppUser.friendsCount;
      postsCount = AppUser.postsCount;
      awardsCount = AppUser.awardsCount;

      country = AppUser.country;
      province = AppUser.province;
      registerdate = AppUser.registerdate;

      aboutme = AppUser.aboutme;

      burc = AppUser.burc;

      favoritakim = AppUser.favTeam;

      try {
        job = AppUser.job;
      } catch (ex) {
        log(ex.toString());
      }

      try {
        role = AppUser.role;
      } catch (ex) {
        log(ex.toString());
      }
      try {
        rolecolor = AppUser.rolecolor;
      } catch (ex) {
        log(ex.toString());
      }
    } else {
      Map<String, dynamic> response = {};
      if (widget.userID == null && widget.username != null) {
        FunctionService f = FunctionService();
        Map<String, dynamic> response =
            await f.lookProfilewithusername(widget.username!);

        if (response["durum"] == 0) {
          log("Oyuncu bulunamadı");
          return;
        }
        //Kullanıcı adında birisi var

        userID = int.parse(response["oyuncuID"]);
        userName = response["kullaniciadi"];
        displayName = response["adim"];
        banneravatar = response["parkaresimminnak"];
        banneravatarbetter = response["parkaresimufak"];
        avatar = response["presimminnak"];
        avatarbetter = response["presimufak"];

        level = response["seviye"];
        friendsCount = response["arkadaslar"];
        postsCount = response["gonderiler"];
        awardsCount = response["oduller"];

        if (response["ulkesi"] != null) {
          country = response["ulkesi"];
        }
        if (response["ili"] != null) {
          province = response["ili"];
        }
        registerdate = response["kayittarihikisa"];

        if (response["burc"] != null) {
          burc = response["burc"];
        }

        if (response["favoritakim"] != null) {
          favoritakim = Team(
            teamID: response["favoritakim"]["takim_ID"],
            name: response["favoritakim"]["takim_adi"],
            logo: response["favoritakim"]["takim_logo"],
          );
        }

        if (response["isyeriadi"] != null) {
          job = response["isyeriadi"];
        }

        if (response["yetkisiacikla"] != null) {
          role = response["yetkisiacikla"];
        }
        if (response["yetkirenk"] != null) {
          rolecolor = response["yetkirenk"];
        }
        if (response["hakkimda"] != null) {
          aboutme = response["hakkimda"];
        }

        if (response["arkadasdurum"] == "1") {
          isFriend = true;
          isbeFriend = false;
        } else if (response["arkadasdurum"] == "2") {
          isFriend = false;
          isbeFriend = false;
        } else {
          isFriend = false;
          isbeFriend = true;
        }
        listFriendTOP3.clear();
        for (int i = 0; i < response["ortakarkadasliste"].length; i++) {
          if (mounted) {
            setState(() {
              if (i < 2) {
                if (i == 0) {
                  friendTextLine +=
                      "@${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]} ";
                } else {
                  if (response["ortakarkadasliste"].length == 2) {
                    friendTextLine +=
                        "ve @${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]} ";
                  } else {
                    friendTextLine +=
                        ", @${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]} ";
                  }
                }
              }
              listFriendTOP3
                  .add(response["ortakarkadasliste"][i]["oyuncuminnakavatar"]);
            });
          }
        }

        if (response["ortakarkadasliste"].length > 2) {
          int mutualFriend = response["ortakarkadaslar"] - 2;
          friendTextLine +=
              "ve ${mutualFriend.toString()} diğer kişi ile arkadaş";
        } else if (response["ortakarkadasliste"].length == 2) {
          friendTextLine += " ile arkadaş";
        } else if (response["ortakarkadasliste"].length == 1) {
          friendTextLine += " ile arkadaş";
        }
        ///////
      } else {
        FunctionService f = FunctionService();
        response = await f.lookProfile(widget.userID!);
        if (response["durum"] == 0) {
          log("Oyuncu bulunamadı");
          return;
        }
        userID = int.parse(response["oyuncuID"]);
        userName = response["kullaniciadi"];
        displayName = response["adim"];
        banneravatar = response["parkaresimminnak"];
        banneravatarbetter = response["parkaresimufak"];
        avatar = response["presimminnak"];
        avatarbetter = response["presimufak"];

        level = response["seviye"];
        friendsCount = response["arkadaslar"];
        postsCount = response["gonderiler"];
        awardsCount = response["oduller"];

        if (response["ulkesi"] != null) {
          country = response["ulkesi"];
        }
        if (response["ili"] != null) {
          province = response["ili"];
        }
        registerdate = response["kayittarihikisa"];

        if (response["burc"] != null) {
          burc = response["burc"];
        }

        if (response["favoritakim"] != null) {
          favoritakim = Team(
            teamID: response["favoritakim"]["takim_ID"],
            name: response["favoritakim"]["takim_adi"],
            logo: response["favoritakim"]["takim_logo"],
          );
        }

        if (response["isyeriadi"] != null) {
          job = response["isyeriadi"];
        }

        if (response["yetkisiacikla"] != null) {
          role = response["yetkisiacikla"];
        }
        if (response["yetkirenk"] != null) {
          rolecolor = response["yetkirenk"];
        }
        if (response["hakkimda"] != null) {
          aboutme = response["hakkimda"];
        }

        if (response["arkadasdurum"] == "1") {
          isFriend = true;
          isbeFriend = false;
        } else if (response["arkadasdurum"] == "2") {
          isFriend = false;
          isbeFriend = false;
        } else {
          isFriend = false;
          isbeFriend = true;
        }

        listFriendTOP3.clear();
        for (int i = 0; i < response["ortakarkadasliste"].length; i++) {
          if (mounted) {
            setState(() {
              if (i < 2) {
                if (i == 0) {
                  friendTextLine +=
                      "@${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]} ";
                } else {
                  if (response["ortakarkadasliste"].length == 2) {
                    friendTextLine +=
                        "ve @${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]}";
                  } else {
                    friendTextLine +=
                        ", @${response["ortakarkadasliste"][i]["oyuncukullaniciadi"]} ";
                  }
                }
              }
              listFriendTOP3
                  .add(response["ortakarkadasliste"][i]["oyuncuminnakavatar"]);
            });
          }
        }

        if (response["ortakarkadasliste"].length > 2) {
          int mutualFriend = response["ortakarkadaslar"] - 2;
          friendTextLine +=
              "ve ${mutualFriend.toString()} diğer kişi ile arkadaş";
        } else if (response["ortakarkadasliste"].length == 2) {
          friendTextLine += " ile arkadaş";
        } else if (response["ortakarkadasliste"].length == 1) {
          friendTextLine += " ile arkadaş";
        }
        /////
      }

      if (isbeFriend && !isFriend && userID != AppUser.ID) {
        friendStatus = "Arkadaş Ol";
        friendStatuscolor = Colors.blue;
      } else if (!isbeFriend &&
          !isFriend &&
          userID != AppUser.ID &&
          userID != -1) {
        friendStatus = "İstek Gönderildi";
        friendStatuscolor = Colors.black;
      } else if (!isbeFriend && isFriend && userID != AppUser.ID) {
        friendStatus = "Mesaj Gönder";
        friendStatuscolor = Colors.blue;
      }
    }

    await profileloadPosts(postscounter, userID);
  }

  Future<void> _handleRefresh() async {
    await test();
  }

  Future<void> changeavatar() async {
    XFile? selectedImage = await AppCore.pickImage();
    if (selectedImage == null) {
      return;
    }
    FunctionsProfile f = FunctionsProfile();
    List<XFile> imagePath = [];
    imagePath.add(selectedImage);
    Map<String, dynamic> response = await f.changeavatar(imagePath);
    if (response["durum"] == 0) {
      log(response["aciklama"]);
      return;
    }
    setState(() {
      AppUser.avatar = response["aciklamadetay"].toString();
      AppUser.avatarbetter = response["aciklamadetay"].toString();

      _handleRefresh();
    });
  }

  Future<void> changebanner() async {
    XFile? selectedImage = await AppCore.pickImage();
    if (selectedImage == null) {
      return;
    }
    FunctionsProfile f = FunctionsProfile();
    List<XFile> imagePath = [];
    imagePath.add(selectedImage);
    Map<String, dynamic> response = await f.changebanner(imagePath);
    if (response["durum"] == 0) {
      log(response["aciklama"]);
      return;
    }
    setState(() {
      AppUser.banneravatar = response["aciklamadetay"].toString();
      AppUser.banneravatarbetter = response["aciklamadetay"].toString();

      _handleRefresh();
    });
  }

  Future<void> friendrequest() async {
    FunctionsProfile f = FunctionsProfile();
    Map<String, dynamic> response = await f.friendrequest(userID);

    if (response["durum"] == 0) {
      log(response["aciklama"]);
      return;
    }

    friendStatus = "Bekleniyor";
    friendStatuscolor = Colors.black;
  }

  Future<void> sendmessage() async {
    log("Sohbet açılacak");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          appbar: true,
          userID: userID,
          useravatar: avatar,
          userdisplayname: userName,
          chats: const [],
        ),
      ),
    );
  }

  Future<void> cancelfriendrequest() async {
    log("istek iptal edilecek ");
  }

  Widget widgetFriendList(bool isclip, double left, String imageUrl) {
    if (isclip) {
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 30,
            height: 30,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
    }
    return Positioned(
      left: left,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: 30,
          height: 30,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ARMOYU.bodyColor,
      // extendBodyBehindAppBar: true,

      body: CustomScrollView(
        controller: pageMainscroller,
        slivers: [
          SliverAppBar(
            pinned: AppUser.ID != userID ? true : false,
            backgroundColor: Colors.black,
            expandedHeight: ARMOYU.screenHeight * 0.25,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet<void>(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                    ),
                                    width: ARMOYU.screenWidth / 4,
                                    height: 5,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: const ListTile(
                                    leading: Icon(Icons.share_outlined),
                                    title: Text("Profili paylaş."),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: const ListTile(
                                    leading: Icon(Icons.content_copy),
                                    title: Text("Profil linkini kopyala."),
                                  ),
                                ),
                                const Visibility(
                                  //Çizgi ekler
                                  child: Divider(),
                                ),
                                Visibility(
                                  visible: userID != AppUser.ID,
                                  child: InkWell(
                                    onTap: () async {
                                      FunctionsBlocking f = FunctionsBlocking();
                                      Map<String, dynamic> response =
                                          await f.add(userID);
                                      if (response["durum"] == 0) {
                                        log(response["aciklama"]);
                                        return;
                                      }
                                      try {
                                        Navigator.pop(context);
                                      } catch (e) {
                                        log(e.toString());
                                      }
                                    },
                                    child: const ListTile(
                                      textColor: Colors.red,
                                      leading: Icon(
                                        Icons.person_off_outlined,
                                        color: Colors.red,
                                      ),
                                      title: Text("Kullanıcıyı Engelle."),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: userID != AppUser.ID,
                                  child: InkWell(
                                    onTap: () {},
                                    child: const ListTile(
                                      textColor: Colors.red,
                                      leading: Icon(
                                        Icons.flag_outlined,
                                        color: Colors.red,
                                      ),
                                      title: Text("Profili bildir."),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: isFriend,
                                  child: InkWell(
                                    onTap: () async {
                                      FunctionsProfile f = FunctionsProfile();
                                      Map<String, dynamic> response =
                                          await f.friendremove(widget.userID!);
                                      if (response["durum"] == 0) {
                                        log(response["aciklama"]);
                                        return;
                                      }
                                    },
                                    child: const ListTile(
                                      textColor: Colors.red,
                                      leading: Icon(
                                        Icons.person_remove,
                                        color: Colors.pink,
                                      ),
                                      title: Text("Arkadaşlıktan Çıkar."),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: isFriend,
                                  child: InkWell(
                                    onTap: () async {
                                      FunctionsProfile f = FunctionsProfile();
                                      Map<String, dynamic> response =
                                          await f.userdurting(widget.userID!);
                                      if (response["durum"] == 0) {
                                        log(response["aciklama"]);
                                        return;
                                      }
                                    },
                                    child: const ListTile(
                                      textColor: Colors.orange,
                                      leading: Icon(
                                        Icons.local_fire_department,
                                        color: Colors.pink,
                                      ),
                                      title: Text("Profili Dürt."),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Align(
                alignment: Alignment.bottomLeft,
                child: userID == AppUser.ID
                    ? const SizedBox()
                    : CustomText().costum1(displayName),
              ),
              background: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FullScreenImagePage(
                      images: [banneravatarbetter],
                      initialIndex: 0,
                    ),
                  ));
                },
                onLongPress: () {
                  if (AppUser.ID != userID) {
                    return;
                  }
                  showModalBottomSheet<void>(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                    ),
                                    width: ARMOYU.screenWidth / 4,
                                    height: 5,
                                  ),
                                ),
                                Visibility(
                                  visible: AppUser.ID == userID,
                                  child: InkWell(
                                    onTap: () async {
                                      await changebanner();
                                    },
                                    child: const ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text("Arkaplan değiştir."),
                                    ),
                                  ),
                                ),
                                const Visibility(
                                  //Çizgi ekler
                                  child: Divider(),
                                ),
                                Visibility(
                                  visible: userID == AppUser.ID,
                                  child: InkWell(
                                    onTap: () {},
                                    child: const ListTile(
                                      textColor: Colors.red,
                                      leading: Icon(
                                        Icons.person_off_outlined,
                                        color: Colors.red,
                                      ),
                                      title: Text("Varsayılana dönder."),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: banneravatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    images: [avatarbetter],
                                    initialIndex: 0,
                                  ),
                                ));
                              },
                              onLongPress: () {
                                if (AppUser.ID != userID) {
                                  return;
                                }
                                showModalBottomSheet<void>(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Wrap(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[900],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                  ),
                                                  width: ARMOYU.screenWidth / 4,
                                                  height: 5,
                                                ),
                                              ),
                                              Visibility(
                                                visible: AppUser.ID == userID,
                                                child: InkWell(
                                                  onTap: () async {
                                                    await changeavatar();
                                                  },
                                                  child: const ListTile(
                                                    leading:
                                                        Icon(Icons.camera_alt),
                                                    title: Text(
                                                        "Avatar değiştir."),
                                                  ),
                                                ),
                                              ),
                                              const Visibility(
                                                //Çizgi ekler
                                                child: Divider(),
                                              ),
                                              Visibility(
                                                visible: userID == AppUser.ID,
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: const ListTile(
                                                    textColor: Colors.red,
                                                    leading: Icon(
                                                      Icons.person_off_outlined,
                                                      color: Colors.red,
                                                    ),
                                                    title: Text(
                                                        "Varsayılana dönder."),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: avatar,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Spacer(),
                                  // Column(
                                  //   children: [
                                  //     CustomText()
                                  //         .Costum1(level.toString()),
                                  //      CustomText().Costum1("Seviye"),
                                  //   ],
                                  // ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      CustomText().costum1(
                                          postsCount.toString(),
                                          weight: FontWeight.bold),
                                      CustomText().costum1("Gönderi"),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FriendlistPage(
                                                username: userName,
                                                userid: userID,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            CustomText().costum1(
                                                friendsCount.toString(),
                                                weight: FontWeight.bold),
                                            CustomText().costum1("Arkadaş"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      CustomText().costum1(
                                          awardsCount.toString(),
                                          weight: FontWeight.bold),
                                      CustomText().costum1("Ödül"),
                                    ],
                                  ),
                                  const Spacer(),

                                  favoritakim != null
                                      ? Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                // favteamfetch();
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl: favoritakim!.logo,
                                                height: 40,
                                                width: 40,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Column(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomText().costum1(
                    displayName,
                    size: 16,
                    weight: FontWeight.bold,
                  ),
                  Row(
                    children: [
                      CustomText().costum1(
                        "@$userName",
                      ),
                      const SizedBox(width: 5),
                      Text(
                        role,
                        style: TextStyle(
                          color: Color(
                            int.parse("0xFF$rolecolor"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Visibility(
                    visible: registerdate == "..." ? false : true,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        CustomText().costum1(
                          registerdate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Visibility(
                      visible: burc == "..." ? false : true,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.window,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 3),
                          CustomText().costum1(
                            burc,
                          ),
                        ],
                      )),
                  const SizedBox(height: 5),
                  Visibility(
                    visible: country == "..." ? false : true,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        CustomText().costum1(
                          "$country, $province",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Visibility(
                    visible: job == "" ? false : true,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        CustomText().costum1(job),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: AppUser.ID != userID,
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ...List.generate(listFriendTOP3.length, (index) {
                              final reversedIndex =
                                  listFriendTOP3.length - 1 - index;
                              if (reversedIndex == 0) {
                                return widgetFriendList(
                                  true,
                                  0,
                                  listFriendTOP3[reversedIndex].toString(),
                                );
                              }
                              return widgetFriendList(
                                false,
                                reversedIndex * 15,
                                listFriendTOP3[reversedIndex].toString(),
                              );
                            }),
                            SizedBox(width: listFriendTOP3.length * 65 / 3),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              specialText(context, friendTextLine)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Visibility(
                        //Arkadaş ol
                        visible:
                            isbeFriend && !isFriend && userID != AppUser.ID,
                        child: Expanded(
                          child: CustomButtons().friendbuttons(
                              friendStatus, friendrequest, friendStatuscolor),
                        ),
                      ),
                      Visibility(
                        //Bekliyor
                        visible: !isbeFriend &&
                            !isFriend &&
                            userID != AppUser.ID &&
                            userID != -1,
                        child: Expanded(
                          child: CustomButtons().friendbuttons(friendStatus,
                              cancelfriendrequest, friendStatuscolor),
                        ),
                      ),
                      Visibility(
                        //Mesaj Gönder
                        visible:
                            !isbeFriend && isFriend && userID != AppUser.ID,
                        child: Expanded(
                          child: CustomButtons().friendbuttons(
                              friendStatus, sendmessage, friendStatuscolor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Visibility(
                    visible: aboutme == "" ? false : true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDedectabletext().costum1(aboutme, 3, 13),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: Profileusersharedmedias(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return !ispostsVisible ? null : widgetPosts[index];
              },
              childCount: widgetPosts.length,
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Her satırda 2 görsel
              crossAxisSpacing: 8.0, // Yatayda boşluk
              mainAxisSpacing: 8.0, // Dikeyde boşluk
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return !isgalleryVisible
                    ? null
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                images: imageufakUrls,
                                imagesownerID: imagesownerID,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
              },
              childCount: !isgalleryVisible ? null : imageUrls.length,
            ),
          ),
        ],
      ),
    );
  }
}

class Profileusersharedmedias extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Başlık içeriğini oluşturun
    return Container(
      alignment: Alignment.center,
      color: ARMOYU.bodyColor,
      child: TabBar(
        labelColor: Colors.white,
        controller: tabController,
        isScrollable: true,
        indicatorColor: ARMOYU.color,
        tabs: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomText().costum1('Paylaşımlar', size: 15.0),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomText().costum1('Medya', size: 15.0),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40.0; // Başlığın maksimum yüksekliği

  @override
  double get minExtent => 40.0; // Başlığın minimum yüksekliği

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
