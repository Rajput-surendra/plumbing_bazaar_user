import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/AppBtn.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/SimBtn.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widgets.dart';
import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/All_Category.dart';
import 'package:eshop_multivendor/Screen/SellerList.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';

import 'package:marquee_widget/marquee_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:video_player/video_player.dart';
import '../Model/SubCate_Model.dart';
import '../Model/SubcribeModel.dart';
import 'Login.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'SectionList.dart';
import 'brands.dart';

class HomePage extends StatefulWidget {
  String video;

  HomePage({required this.video, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> subCate = [];
String? category;
List brandList = [];
String? categoryId;

String? image;

String? cStatus;
String? pdf;
List<Product> popularList = [];
List marqueeImages = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
int count = 1;
List<Model> homeSliderList = [];
List<Widget> pages = [];

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  int currentindex = 0;

  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];
  List bannerVideo = [];
  bool isPipe = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  //String? curPin;
  final ScrollController scrollcontroller = new ScrollController();
  VideoPlayerController? _videoController;

  bool scroll_visibility = true;
  var height;

  //VideoPlayerController _viController  ;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
          scroll_visibility = true;
        } else {
          print('At the bottom');
          scroll_visibility = false;
        }
      }
    });
    // scrollcontroller.addListener(() {
    //   if(scrollcontroller.position.pixels > 0 || scrollcontroller.position.pixels < scrollcontroller.position.maxScrollExtent)
    //     scroll_visibility = false;
    //   else
    //     scroll_visibility = true;
    //
    //   setState(() {});
    // });
    // Future.delayed(Duration.zero,(){
    //   return
    //     DialogBox();
    // });
    // DialogBox();
   // getBannerVideo();
    // _viController = VideoPlayerController.network(
    //     'https://alphawizztest.tk/plumbing_bazzar/uploads/HW-Hues-rendered-TVC-30sec.mp4'
    // )
    //   ..initialize().then((_) {
    //     _viController.play();
    //     // _videoController!.pause();
    //     _viController.setLooping(true);
    //     // Ensure the first frame is shown after the video is initialized
    //   });
    // if(bannerVideo[0]['video'] != null) {
    // Future.delayed(Duration(seconds: 3), (){
    showVideo(widget.video);

    // });
    //}
    callApi();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      new CurvedAnimation(
        parent: buttonController,
        curve: new Interval(
          0.0,
          0.150,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  Future subcribe(email, name) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://alphawizztest.tk/plumbing_bazzar/app/v1/api/Subcribe'));
    request.fields.addAll({'email': '$email', 'name': '$name'});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      var result = SubcribeModel.fromJson(json.decode(data));
      setSnackbar("Subcribe Sucessfull ", context);

      print("checking message here ${result.message} ");
      print("checking data here ${result.data} ");
    } else {
      return null;
    }
  }

  Future<SubCateModel?> subCate() async {
    var request = http.Request(
        'POST',
        Uri.parse(
            '$getAllCatApi'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      print(data.toString());
      print(response.statusCode);

      return SubCateModel.fromJson(json.decode(data));
    } else {
      return null;
    }
  }

  showVideo(String url) {
    _videoController = VideoPlayerController.network(
        //  widget.video
        video
        //url
        // bannerVideo != null?
        //  "https://alphawizztest.tk/plumbing_bazzar/${bannerVideo[0]['video']}"
        //     : ""
        //   :
        // 'https://alphawizztest.tk/plumbing_bazzar/uploads/HW-Hues-rendered-TVC-30sec.mp4'
        )
      ..initialize().then((_) {
         _videoController!.play();
        // _videoController!.pause();
        _videoController!.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
      });
  }

  // void validateSave(){
  //   var _formKey;
  //   final form = _formKey.currentState;
  //   if(form.validate())
  //   {
  //     print ('Form is valid');
  //   }
  //   else
  //   {
  //     print('form is invalid');
  //   }
  // }
  void validator() {
    Function(String) usernameValidator = (String username) {
      if (username.isEmpty) {
        return 'Username empty';
      } else if (username.length < 3) {
        return 'Username short';
      }

      return null;
    };

    passwordValidator(String password) {
      if (password.isEmpty) {
        return 'Password empty';
      } else if (password.length < 3) {
        return 'PasswordShort';
      }
      return null;
    }
  }

  bool isStoped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: colors.primary,
          onPressed: () {
            _showMyDialog();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              children: [
                Text(
                  "Enquire ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      color: colors.whiteTemp),
                ),
                Text(
                  "Now ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      color: colors.whiteTemp),
                )
              ],
            ),
          )),
      body: _isNetworkAvail
          ? RefreshIndicator(
              color: colors.primary,
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                controller: scrollcontroller,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _deliverPincode(),
                    _video(),
                    _marquee(),
                    _brandsHeader(),
                    _catList(),
                    SizedBox(
                      height: 20,
                    ),
                    // _slider(),
                    _productsHeader(),
                    _section(),
                    _slider(),
                    //_seller()
                  ],
                ),
              ),
            )
          : noInternet(context),
    );
  }

  Future<Null> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);

    return callApi();
  }

  // Widget _slider() {
  //   double height = deviceWidth! / 2.2;
  //
  //   return Selector<HomeProvider, bool>(
  //     builder: (context, data, child) {
  //       return data
  //           ? sliderLoading()
  //           : Stack(
  //               children: [
  //                 Container(
  //                   height: height,
  //                   width: double.infinity,
  //                   // margin: EdgeInsetsDirectional.only(top: 10),
  //                   child: PageView.builder(
  //                     itemCount: homeSliderList.length,
  //                     scrollDirection: Axis.horizontal,
  //                     controller: _controller,
  //                     physics: AlwaysScrollableScrollPhysics(),
  //                     onPageChanged: (index) {
  //                       context.read<HomeProvider>().setCurSlider(index);
  //                     },
  //                     itemBuilder: (BuildContext context, int index) {
  //                       return pages[index];
  //                     },
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 0,
  //                   height: 40,
  //                   left: 0,
  //                   width: deviceWidth,
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.max,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: map<Widget>(
  //                       homeSliderList,
  //                       (index, url) {
  //                         return Container(
  //                             width: 8.0,
  //                             height: 8.0,
  //                             margin: EdgeInsets.symmetric(
  //                                 vertical: 10.0, horizontal: 2.0),
  //                             decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: context.read<HomeProvider>().curSlider ==
  //                                       index
  //                                   ? Theme.of(context).colorScheme.fontColor
  //                                   : Theme.of(context).colorScheme.lightBlack,
  //                             ));
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             );
  //     },
  //     selector: (_, homeProvider) => homeProvider.sliderLoading,
  //   );
  // }

  Widget _slider() {
    double height = deviceWidth! / 2.2;

    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    Container(
                      height: height,
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 1200),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          height: height,
                          onPageChanged: (position, reason) {
                            setState(() {
                              currentindex = position;
                            });
                            print(reason);
                            print(CarouselPageChangedReason.controller);
                          },
                        ),
                        items: homeSliderList.map((val) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "${val.image}",
                                  fit: BoxFit.fill,
                                )),
                          );
                        }).toList(),
                      ),
                      // margin: EdgeInsetsDirectional.only(top: 10),
                      // child: PageView.builder(
                      //   itemCount: homeSliderList.length,
                      //   scrollDirection: Axis.horizontal,
                      //   controller: _controller,
                      //   pageSnapping: true,
                      //   physics: AlwaysScrollableScrollPhysics(),
                      //   onPageChanged: (index) {
                      //     context.read<HomeProvider>().setCurSlider(index);
                      //   },
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return pages[index];
                      //   },
                      // ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: homeSliderList.map((e) {
                          int index = homeSliderList.indexOf(e);
                          return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentindex == index
                                    ? Theme.of(context).colorScheme.fontColor
                                    : Theme.of(context).colorScheme.lightBlack,
                              ));
                        }).toList()),
                  ],
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  Widget _video() {
    return InkWell(
      onTap: (){
        setState(() {
          isStoped = true;
        });
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: bannerVideo.isNotEmpty
              ?
          //widget.video.isNotEmpty ?
          VideoPlayer(_videoController!)
              : Center(
            child: CircularProgressIndicator(
              color: colors.primary,
            ),
          )

        //     : VideoPlayer(
        //     _viController
        // )
      ),
    );
  }

  Widget _marquee() {
    return Container(
      height: 60,
      child: Center(
        child: Marquee(
            animationDuration: Duration(seconds: 5),
            directionMarguee: DirectionMarguee.oneDirection,

            // autoRepeat: true,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: marqueeImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: new ClipRRect(
                      // borderRadius: BorderRadius.circular(35.0),
                      child: commonHWImage(
                          marqueeImages[index]['image'].toString(),
                          50.0,
                          200.0,
                          "",
                          context,
                          "assets/images/placeholder.png"),
                    ),
                  );
                })
            // Text( 'This project is a starting point for a Dart package, a library module containing code that can be shared easily across multiple Flutter or Dart projects. '),
            ),
      ),
    );
  }

  Widget _brandsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 150.0, right: 150),
              child: Divider(
                color: colors.primary,
              ),
            ),
            Text(
              BRAND,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 150.0, right: 150),
              child: Divider(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productsHeader() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 150.0, right: 150),
            child: Divider(
              color: colors.primary,
            ),
          ),
          //getTranslated(context, BRANDS),
          Text(
            PRODUCT,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 150.0, right: 150),
            child: Divider(
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 30)).then(
      (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients)
            _controller
                .animateToPage(nextPage,
                    duration: Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider());
        }
      },
    );
  }

  _singleSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0)
      back = Theme.of(context).colorScheme.back1;
    else if (pos == 1)
      back = Theme.of(context).colorScheme.back2;
    else if (pos == 2)
      back = Theme.of(context).colorScheme.back3;
    else if (pos == 3)
      back = Theme.of(context).colorScheme.back4;
    else
      back = Theme.of(context).colorScheme.back5;

    return sectionList[index].productList!.length > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // _getHeading(sectionList[index].title ?? "", index),
                    _getSection(index),
                  ],
                ),
              ),
              // offerImages.length > index ? _getOfferImage(index) : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: colors.yellow,
                ),
                padding: EdgeInsetsDirectional.only(
                    start: 10, bottom: 3, top: 3, end: 10),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /*   Positioned(
                  // clipBehavior: Clip.hardEdge,
                  // margin: EdgeInsets.symmetric(horizontal: 20),

                  right: -14,
                  child: SvgPicture.asset("assets/images/eshop.svg"))*/
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(sectionList[index].shortDesc ?? "",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: Size.zero, // <
                    backgroundColor: (Theme.of(context).colorScheme.white),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                child: Text(
                  getTranslated(context, 'SHOP_NOW')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SectionModel model = sectionList[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionList(
                        index: index,
                        section_model: model,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getOfferImage(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: FadeInImage(
            fit: BoxFit.contain,
            fadeInDuration: Duration(milliseconds: 150),
            image: CachedNetworkImageProvider(offerImages[index].image!),
            width: double.maxFinite,
            imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),

            // errorWidget: (context, url, e) => placeHolder(50),
            placeholder: AssetImage(
              "assets/images/sliderph.png",
            )),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;

            Navigator.push(
              context,
              PageRouteBuilder(
                  //transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) =>
                      ProductDetail(model: item, secPos: 0, index: 0, list: true
                          //  title: sectionList[secPos].title,
                          )),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.subList == null || item.subList!.length == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
              mainAxisSpacing: 10,
              crossAxisSpacing: 15,
              padding: EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 0.750,

              //  childAspectRatio: 1.0,
              physics: NeverScrollableScrollPhysics(),
              children:
                  //  [
                  //   Container(height: 500, width: 1200, color: Colors.red),
                  //   Text("hello"),
                  //   Container(height: 10, width: 50, color: Colors.green),
                  // ]
                  List.generate(
                sectionList[i].productList!.length < 4
                    ? sectionList[i].productList!.length
                    : 4,
                (index) {
                  // return Container(
                  //   width: 600,
                  //   height: 50,
                  //   color: Colors.red,
                  // );

                  return productItem(i, index, index % 2 == 0 ? true : false);
                },
              ),
            ),
          )
        : sectionList[i].style == STYLE1
            ? sectionList[i].productList!.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight!,
                                child: productItem(i, 0, true))),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, false)),
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 2, false)),
                            ],
                          ),
                        ),
                      ],
                    ))
                : Container()
            : sectionList[i].style == STYLE2
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 0, true)),
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, true)),
                            ],
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight,
                                child: productItem(i, 2, false))),
                      ],
                    ))
                : sectionList[i].style == STYLE3
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.loose,
                                child: Container(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.3
                                        : deviceHeight! * 0.6,
                                    child: productItem(i, 0, false))),
                            Container(
                              height: orient == Orientation.portrait
                                  ? deviceHeight! * 0.2
                                  : deviceHeight! * 0.5,
                              child: Row(
                                children: [
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 1, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 2, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 3, false)),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : sectionList[i].style == STYLE4
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: Container(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.25
                                            : deviceHeight! * 0.5,
                                        child: productItem(i, 0, false))),
                                Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: Row(
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 1, true)),
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 2, false)),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GridView.count(
                                padding: EdgeInsetsDirectional.only(top: 5),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.2,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                children: List.generate(
                                  sectionList[i].productList!.length < 6
                                      ? sectionList[i].productList!.length
                                      : 6,
                                  (index) {
                                    return productItem(i, index,
                                        index % 2 == 0 ? true : false);
                                  },
                                )));
  }

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList!.length > index) {
      String? offPer;
      double price = double.parse(
          sectionList[secPos].productList![index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList![index].prVarientList![0].price!);
      } else {
        double off = double.parse(sectionList[secPos]
                .productList![index]
                .prVarientList![0]
                .price!) -
            price;
        offPer = ((off * 100) /
                double.parse(sectionList[secPos]
                    .productList![index]
                    .prVarientList![0]
                    .price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,

        margin: EdgeInsetsDirectional.only(bottom: 2, end: 2),
        //end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                /*       child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    child: Hero(
                      tag:
                      "${sectionList[secPos].productList![index].id}$secPos$index",
                      child: FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                            sectionList[secPos].productList![index].image!),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        fit: extendImg ? BoxFit.fill : BoxFit.contain,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            erroWidget(width),

                        // errorWidget: (context, url, e) => placeHolder(width),
                        placeholder: placeHolder(width),
                      ),
                    )),*/
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        // transitionOnUserGestures: true,
                        tag:
                            "${sectionList[secPos].productList![index].id}$secPos$index",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(
                              sectionList[secPos].productList![index].image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(double.maxFinite),
                          fit: BoxFit.fill,
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5.0,
                  top: 3,
                ),
                child: Text(
                  sectionList[secPos].productList![index].name!,
                  style: Theme.of(context).textTheme.overline!.copyWith(
                      color: colors.primary,
                      letterSpacing: 0,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  // style: Theme.of(context).textTheme.caption!.copyWith(
                  //     color: Theme.of(context).colorScheme.lightBlack),
                  // maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                double.parse(sectionList[secPos]
                            .productList![index]
                            .prVarientList![0]
                            .disPrice!) !=
                        0
                    ? CUR_CURRENCY! +
                        "" +
                        sectionList[secPos]
                            .productList![index]
                            .prVarientList![0]
                            .price!
                    : "",
                //" " + CUR_CURRENCY! + " " + price.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Text("$offPer%",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.overline!.copyWith(
                      color: colors.primary,
                      letterSpacing: 0,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              // Padding(
              //   padding: const EdgeInsetsDirectional.only(
              //       start: 5.0, bottom: 5, top: 3),
              //   child: double.parse(sectionList[secPos]
              //               .productList![index]
              //               .prVarientList![0]
              //               .disPrice!) !=
              //           0
              //       ? Row(
              //           children: <Widget>[
              //             // Text(
              //             //   double.parse(sectionList[secPos]
              //             //               .productList![index]
              //             //               .prVarientList![0]
              //             //               .disPrice!) !=
              //             //           0
              //             //       ? CUR_CURRENCY! +
              //             //           "" +
              //             //           sectionList[secPos]
              //             //               .productList![index]
              //             //               .prVarientList![0]
              //             //               .price!
              //             //       : "",
              //             //   style: Theme.of(context)
              //             //       .textTheme
              //             //       .overline!
              //             //       .copyWith(
              //             //           decoration: TextDecoration.lineThrough,
              //             //           letterSpacing: 0,
              //             //     fontSize: 15,
              //             //     fontWeight: FontWeight.bold
              //             //   ),
              //             // ),
              //             Flexible(
              //               child: Text( "$offPer%",
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: Theme.of(context)
              //                       .textTheme
              //                       .overline!
              //                       .copyWith(
              //                           color: colors.primary,
              //                           letterSpacing: 0,
              //                     fontSize: 15,
              //                     fontWeight: FontWeight.bold
              //                   )),
              //             ),
              //           ],
              //         )
              //       : Container(
              //           height: 5,
              //         ),
              // )
            ],
          ),
          onTap: () {
            Product model = sectionList[secPos].productList![index];
            Navigator.push(
              context,
              PageRouteBuilder(
                // transitionDuration: Duration(milliseconds: 150),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: model, secPos: secPos, index: index, list: false
                    //  title: sectionList[secPos].title,
                    ),
              ),
            );
          },
        ),
      );
    } else
      return Container();
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: sectionLoading(),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: sectionList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print("here");
                  return _singleSection(index);
                },
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                color: Colors.white,
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Container(
          padding: EdgeInsets.all(10),
                child: FutureBuilder(
                    future: subCate(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        SubCateModel model = snapshot.data;
                        return ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: model.data!.length,
                            itemBuilder: (c, i) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 120.0, right: 120),
                                    child: Divider(
                                      color: colors.primary,
                                    ),
                                  ),
                                  Text(
                                    "${model.data![i].name}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 120.0, right: 120, bottom: 12),
                                    child: Divider(
                                      color: colors.primary,
                                    ),
                                  ),
                                  // Text("${model.data![i].name}",style: TextStyle(
                                  //   fontWeight: FontWeight.bold,fontSize: 15
                                  // ),),
                                  // GridView.builder(
                                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  //       crossAxisCount: 3,
                                  //       // childAspectRatio: 16 / 20,
                                  //       mainAxisSpacing: 10,
                                  //       crossAxisSpacing: 10),
                                  //   itemCount:
                                  //   model.data![i].subcategory!.length > 12 ? 12 :
                                  //   model.data![i].subcategory!.length,
                                  //   shrinkWrap: true,
                                  //   physics: NeverScrollableScrollPhysics(),
                                  //   itemBuilder: (context, index) {
                                  //     return Image.network("${model.data![i].subcategory![index].image}");
                                  //
                                  //   },
                                  // ),
                                  GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            // childAspectRatio: 16 / 20,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10),
                                    itemCount:
                                        // model.data![i].subcategory!.length > 12
                                        //     ? 12
                                        //     :
                                        model.data![i].subcategory!.length ?? 0
                                        // model.data![i].subcategory!.length
                                        //     : 0
                                    ,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return
                                          // index != 7 ?
                                        // model.data![i].subcategory!.length ==0 ?
                                          GestureDetector(
                                        onTap: () async {
                                          //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
                                          categoryId =
                                              model.data![i].id.toString();
                                          image =
                                              "$imageUrl${model.data![i].subcategory![index].image.toString()}";
                                          // cStatus = brandList[index]['c_status'].toString();
                                          cStatus =
                                              model.data![i].subcategory![index].cStatus.toString();
                                          pdf = model.data![i]
                                              .subcategory![index].banner
                                              .toString();
                                          // pdf = brandList[index]['banner'].toString();
                                          print("this is *** $cStatus");
                                          if (cStatus == "1") {
                                            isPipe = true;
                                          } else {
                                            isPipe = false;
                                          }
                                          //print("Image============${brandList[i]}");
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SellerList(
                                                        image: image.toString(),
                                                        catId: categoryId
                                                            .toString(),
                                                        isPipe: isPipe,
                                                        pdf: pdf.toString(),
                                                        // pdf: catList[index].banner.toString()
                                                        //brandList[index]['parent_id'].toString()
                                                        //brandList[index]['children'][0]['parent_id'].toString(),
                                                        // catId: catList[index].id,
                                                        // catName: catList[index].name,
                                                        // subId: catList[index].subList,
                                                        // userLocation: currentAddress.text,
                                                        // getByLocation: false,
                                                      )));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 0.0),
                                              child: new ClipRRect(
                                                // borderRadius: BorderRadius.circular(35.0),
                                                child: commonHWImage(
                                                    "$imageUrl${model.data![i].subcategory![index].image.toString()}",
                                                    80.0,
                                                    120.0,
                                                    "",
                                                    context,
                                                    "assets/images/splashlogo.png"),
                                                // "assets/images/placeholder.png"),
                                              ),
                                            ),
                                            // Container(
                                            //   child: Text(
                                            //     catList[index].name!,
                                            //     style: Theme.of(context)
                                            //         .textTheme
                                            //         .caption!
                                            //         .copyWith(
                                            //         color: Theme.of(context)
                                            //             .colorScheme
                                            //             .fontColor,
                                            //         fontWeight: FontWeight.w600,
                                            //         fontSize: 12),
                                            //     overflow: TextOverflow.ellipsis,
                                            //     textAlign: TextAlign.center,
                                            //   ),
                                            //   // width: 50,
                                            // ),
                                          ],
                                        ),
                                      );
                                      // : SizedBox(height: 0,);
                                      //     : Column(
                                      //   children: [
                                      //     FloatingActionButton( backgroundColor:colors.whiteTemp,
                                      //       onPressed: () async {
                                      //         // Navigator.push(
                                      //         //     context,
                                      //         //     MaterialPageRoute(
                                      //         //         builder: (context) =>
                                      //         //             Category(catList.toList())));
                                      //       },
                                      //       child: Icon(Icons.keyboard_arrow_down_rounded,size: 30,),),
                                      //     Container(height: 10,),
                                      //     Text(
                                      //       "View All",
                                      //       style: TextStyle(
                                      //           fontSize: 13.0,
                                      //           fontWeight: FontWeight.w700,
                                      //           color:
                                      //           Theme.of(context).colorScheme.fontColor),
                                      //     ),
                                      //   ],
                                      // );
                                    },
                                  ),
                                ],
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error_outline);
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
                          ),
                        );
                      }
                    }),
              );
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7.0),
        //   child:
        //   Card(
        //     color: Colors.white,
        //     elevation: 5,
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        //     child:
        //     Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: Column(
        //         children: [
        //           GridView.builder(
        //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //                 crossAxisCount: 3,
        //                // childAspectRatio: 16 / 20,
        //                 mainAxisSpacing: 10,
        //                 crossAxisSpacing: 10),
        //             itemCount:
        //             catList.length > 12 ? 12 :
        //             catList.length,
        //             shrinkWrap: true,
        //             physics: NeverScrollableScrollPhysics(),
        //             itemBuilder: (context, index) {
        //               return
        //                // index != 7 ?
        //                 GestureDetector(
        //                 onTap: () async {
        //               //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
        //                   categoryId = brandList[index]['id'].toString();
        //                   cStatus = brandList[index]['c_status'].toString();
        //                   pdf = brandList[index]['banner'].toString();
        //                   print("this is *** $cStatus");
        //                   if(cStatus == "1"){
        //                     isPipe = true;
        //                   }else{
        //                     isPipe = false;
        //                   }
        //                  Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (context) => SellerList(
        //                             image: catList[index].image.toString(),
        //                             catId: categoryId.toString(),
        //                             isPipe : isPipe,
        //                             pdf: catList[index].banner.toString()
        //                             //brandList[index]['parent_id'].toString()
        //                             //brandList[index]['children'][0]['parent_id'].toString(),
        //                             // catId: catList[index].id,
        //                             // catName: catList[index].name,
        //                             // subId: catList[index].subList,
        //                             // userLocation: currentAddress.text,
        //                             // getByLocation: false,
        //                           )));
        //                 },
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   mainAxisAlignment: MainAxisAlignment.start,
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: <Widget>[
        //                     Padding(
        //                       padding: EdgeInsets.only(bottom: 0.0),
        //                       child: new ClipRRect(
        //                        // borderRadius: BorderRadius.circular(35.0),
        //                         child: commonHWImage(
        //                             catList[index].image.toString(),
        //                             80.0,
        //                             120.0,
        //                             "",
        //                             context,
        //                             "assets/images/splashlogo.png"),
        //                            // "assets/images/placeholder.png"),
        //                       ),
        //                     ),
        //                     // Container(
        //                     //   child: Text(
        //                     //     catList[index].name!,
        //                     //     style: Theme.of(context)
        //                     //         .textTheme
        //                     //         .caption!
        //                     //         .copyWith(
        //                     //         color: Theme.of(context)
        //                     //             .colorScheme
        //                     //             .fontColor,
        //                     //         fontWeight: FontWeight.w600,
        //                     //         fontSize: 12),
        //                     //     overflow: TextOverflow.ellipsis,
        //                     //     textAlign: TextAlign.center,
        //                     //   ),
        //                     //   // width: 50,
        //                     // ),
        //                   ],
        //                 ),
        //               );
        //               //     : Column(
        //               //   children: [
        //               //     FloatingActionButton( backgroundColor:colors.whiteTemp,
        //               //       onPressed: () async {
        //               //         // Navigator.push(
        //               //         //     context,
        //               //         //     MaterialPageRoute(
        //               //         //         builder: (context) =>
        //               //         //             Category(catList.toList())));
        //               //       },
        //               //       child: Icon(Icons.keyboard_arrow_down_rounded,size: 30,),),
        //               //     Container(height: 10,),
        //               //     Text(
        //               //       "View All",
        //               //       style: TextStyle(
        //               //           fontSize: 13.0,
        //               //           fontWeight: FontWeight.w700,
        //               //           color:
        //               //           Theme.of(context).colorScheme.fontColor),
        //               //     ),
        //               //   ],
        //               // );
        //             },
        //           ),
        //           InkWell(
        //             onTap: (){
        //               Navigator.push(context,
        //                    MaterialPageRoute(
        //                       builder: (context) => Brands(
        //                       )));
        //             },
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.end,
        //               children: [
        //                 Text("See All",
        //                   style: Theme.of(this.context)
        //                       .textTheme
        //                       .subtitle1!
        //                       .copyWith(color: Theme.of(context).colorScheme.fontColor),),
        //                 Icon(Icons.arrow_forward,
        //                 size: 18,
        //                 color: Colors.black,)
        //               ],
        //             ),
        //           )
        //         ],
        //       ),
        //     ),
        //  ),
        // );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  // _catList() {
  //   return Selector<HomeProvider, bool>(
  //     builder: (context, data, child) {
  //       return data
  //           ? Container(
  //               width: double.infinity,
  //               child: Shimmer.fromColors(
  //                   baseColor: Theme.of(context).colorScheme.simmerBase,
  //                   highlightColor: Theme.of(context).colorScheme.simmerHigh,
  //                   child: catLoading()))
  //           : Container(
  //               height: 100,
  //               padding: const EdgeInsets.only(top: 10, left: 10),
  //               child: ListView.builder(
  //                 itemCount: catList.length < 10 ? catList.length : 10,
  //                 scrollDirection: Axis.horizontal,
  //                 shrinkWrap: true,
  //                 physics: AlwaysScrollableScrollPhysics(),
  //                 itemBuilder: (context, index) {
  //                   if (index == 0)
  //                     return Container();
  //                   else
  //                     return Padding(
  //                       padding: const EdgeInsetsDirectional.only(end: 10),
  //                       child: GestureDetector(
  //                         onTap: () async {
  //                           if (catList[index].subList == null ||
  //                               catList[index].subList!.length == 0) {
  //                             await Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => ProductList(
  //                                     name: catList[index].name,
  //                                     id: catList[index].id,
  //                                     tag: false,
  //                                     fromSeller: false,
  //                                   ),
  //                                 ));
  //                           } else {
  //                             await Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => SubCategory(
  //                                     title: catList[index].name!,
  //                                     subList: catList[index].subList,
  //                                   ),
  //                                 ));
  //                           }
  //                         },
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: <Widget>[
  //                             Padding(
  //                               padding: const EdgeInsetsDirectional.only(
  //                                   bottom: 5.0),
  //                               child: new ClipRRect(
  //                                 borderRadius: BorderRadius.circular(25.0),
  //                                 child: new FadeInImage(
  //                                   fadeInDuration: Duration(milliseconds: 150),
  //                                   image: CachedNetworkImageProvider(
  //                                     catList[index].image!,
  //                                   ),
  //                                   height: 50.0,
  //                                   width: 50.0,
  //                                   fit: BoxFit.contain,
  //                                   imageErrorBuilder:
  //                                       (context, error, stackTrace) =>
  //                                           erroWidget(50),
  //                                   placeholder: placeHolder(50),
  //                                 ),
  //                               ),
  //                             i),
  //                             Container(
  //                               child: Text(
  //                                 catList[index].name!,
  //                                 style: Theme.of(context)
  //                                     .textTheme
  //                                     .caption!
  //                                     .copyWith(
  //                                         color: Theme.of(context)
  //                                             .colorScheme
  //                                             .fontColor,
  //                                         fontWeight: FontWeight.w600,
  //                                         fontSize: 10),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 textAlign: TextAlign.center,
  //                               ),
  //                               width: 50,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                 },
  //               ),
  //             );
  //     },
  //     selector: (_, homeProvider) => homeProvider.catLoading,
  //   );
  // }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<Null> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();
      getSlider();
      // getCat();
      subCate();
      getBannerVideo();
      getMarqueeImages();
      getSeller();
      getSection();
      getOfferImages();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    return null;
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added')
              setSnackbar(msg!, context);
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void getOfferImages() {
    Map parameter = Map();

    apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        offerImages.clear();
        offerImages =
            (data as List).map((data) => new Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setOfferLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setOfferLoading(false);
    });
  }

  void getSection() {
    // Map parameter = {PRODUCT_LIMIT: "5", PRODUCT_OFFSET: "6"};
    Map parameter = {PRODUCT_LIMIT: "5"};

    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    String curPin = context.read<UserProvider>().curPincode;
    if (curPin != '') parameter[ZIPCODE] = curPin;

    apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      print("Get Section Data---------: $getdata");
      sectionList.clear();
      if (!error) {
        var data = getdata["data"];
        print("Get Section Data2: $data");
        sectionList = (data as List)
            .map((data) => new SectionModel.fromJson(data))
            .toList();
      } else {
        if (curPin != '') context.read<UserProvider>().setPincode('');
        setSnackbar(msg!, context);
        print("Get Section Error Msg: $msg");
      }
      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    //print("")
    Map parameter = Map();
    if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];

      if (!error) {
        var data = getdata["data"]["system_settings"][0];
        cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
        refer = data["is_refer_earn_on"] == "1" ? true : false;
        CUR_CURRENCY = data["currency"];
        RETURN_DAYS = data['max_product_return_days'];
        MAX_ITEMS = data["max_items_cart"];
        MIN_AMT = data['min_amount'];
        CUR_DEL_CHR = data['delivery_charge'];
        String? isVerion = data['is_version_system_on'];
        extendImg = data["expand_product_images"] == "1" ? true : false;
        String? del = data["area_wise_delivery_charge"];
        MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];

        if (del == "0")
          ISFLAT_DEL = true;
        else
          ISFLAT_DEL = false;

        if (CUR_USERID != null) {
          REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

          context
              .read<UserProvider>()
              .setPincode(getdata["data"]["user_data"][0][PINCODE]);

          if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty)
            generateReferral();

          context.read<UserProvider>().setCartCount(
              getdata["data"]["user_data"][0]["cart_total_items"].toString());
          context
              .read<UserProvider>()
              .setBalance(getdata["data"]["user_data"][0]["balance"]);

          _getFav();
          _getCart("0");
        }

        UserProvider user = Provider.of<UserProvider>(context, listen: false);
        SettingProvider setting =
            Provider.of<SettingProvider>(context, listen: false);
        user.setMobile(setting.mobile);
        user.setName(setting.userName);
        user.setEmail(setting.email);
        user.setProfilePic(setting.profileUrl);

        Map<String, dynamic> tempData = getdata["data"];
        if (tempData.containsKey(TAG))
          tagList = List<String>.from(getdata["data"][TAG]);

        if (isVerion == "1") {
          String? verionAnd = data['current_version'];
          String? verionIOS = data['current_version_ios'];

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String version = packageInfo.version;

          final Version currentVersion = Version.parse(version);
          final Version latestVersionAnd = Version.parse(verionAnd);
          final Version latestVersionIos = Version.parse(verionIOS);

          if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
              (Platform.isIOS && latestVersionIos > currentVersion))
            updateDailog();
        }
      } else {
        setSnackbar(msg!, context);
      }
    }, onError: (error) {
      setSnackbar(error.toString(), context);
    });
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};

        Response response =
            await post(getCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<SectionModel> cartList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Null> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        REFER_CODE = refer;

        Map parameter = {
          USER_ID: CUR_USERID,
          REFERCODE: refer,
        };

        apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
      } else {
        if (count < 5) generateReferral();
        count++;
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context)
              .textTheme
              .subtitle1!
              .copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          new TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          new TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String _url = '';
                if (Platform.isAndroid) {
                  _url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  _url = iosLink;
                }

                if (await canLaunch(_url)) {
                  await launch(_url);
                } else {
                  throw 'Could not launch $_url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.5;

    return GestureDetector(
      child: FadeInImage(
          fadeInDuration: Duration(milliseconds: 150),
          image: CachedNetworkImageProvider(slider.image!),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.contain,
          imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/sliderph.png",
                fit: BoxFit.contain,
                height: height,
                color: colors.primary,
              ),
          placeholderErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/sliderph.png",
                fit: BoxFit.contain,
                height: height,
                color: colors.primary,
              ),
          placeholder: AssetImage(imagePath + "sliderph.png")),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;

        if (homeSliderList[curSlider].type == "products") {
          Product? item = homeSliderList[curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: item, secPos: 0, index: 0, list: true)),
          );
        } else if (homeSliderList[curSlider].type == "categories") {
          Product item = homeSliderList[curSlider].list;
          if (item.subList == null || item.subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ));
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              context.read<HomeProvider>().setCatLoading(true);
              context.read<HomeProvider>().setSecLoading(true);
              context.read<HomeProvider>().setSliderLoading(true);
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (mounted)
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  callApi();
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  _deliverPincode() {
    // String curpin = context.read<UserProvider>().curPincode;
    return GestureDetector(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.white,
        child: ListTile(
          dense: true,
          minLeadingWidth: 10,
          leading: Icon(
            Icons.location_pin,
          ),
          title: Selector<UserProvider, String>(
            builder: (context, data, child) {
              return Text(
                data == ''
                    ? getTranslated(context, 'SELOC')!
                    : getTranslated(context, 'DELIVERTO')! + data,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              );
            },
            selector: (_, provider) => provider.curPincode,
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ),
      onTap: _pincodeCheck,
    );
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 40, top: 30),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!,
                                    getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  context
                                      .read<UserProvider>()
                                      .setPincode(value!);
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(Icons.location_on),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsetsDirectional.only(start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context
                                              .read<UserProvider>()
                                              .setPincode('');

                                          context
                                              .read<HomeProvider>()
                                              .setSecLoading(true);
                                          getSection();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            getTranslated(context, 'All')!),
                                      ),
                                    ),
                                    Spacer(),
                                    SimBtn(
                                        size: 0.35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            // validatePin(curPin);
                                            context
                                                .read<HomeProvider>()
                                                .setSecLoading(true);
                                            getSection();

                                            context
                                                .read<HomeProvider>()
                                                .setSellerLoading(true);
                                            sellerList.clear();
                                            getSeller();
                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    Map map = Map();

    apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => new Model.fromSlider(data)).toList();

        pages = homeSliderList.map((slider) {
          return _buildImagePageItem(slider);
        }).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }

  SubCateModel getCat() {
    var brands;
    Map parameter = {
      //  CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getAllCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        brands = getdata;
        var data = getdata["data"];

        // catList =
        //     (data as List).map((data) => new SubCateModel.fromCat(data)).toList();
        brandList = getdata['data'];

        print(" this is length @@ ${catList.length} @@ ${brandList.length}");
        // if (getdata.containsKey("popular_categories")) {
        //   var data = getdata["popular_categories"];
        //   popularList =
        //       (data as List).map((data) => new Product.fromCat(data)).toList();
        //
        //   if (popularList.length > 0) {
        //     Product pop =
        //         new Product.popular("Popular", imagePath + "popular.svg");
        //     catList.insert(0, pop);
        //     context.read<CategoryProvider>().setSubList(popularList);
        //   }
        // }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
    return SubCateModel.fromJson(json.decode(brands));
  }

  Future<void> getMarqueeImages() async {
    Map parameter = {
      //CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getMarqueeApi, parameter).then((getdata) {
      bool error = getdata["error"];
      // String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        marqueeImages = data;
        print(marqueeImages.toString());
        // catList =
        //     (data as List).map((data) => new Product.fromCat(data)).toList();
        //
        // if (getdata.containsKey("popular_categories")) {
        //   var data = getdata["popular_categories"];
        //   popularList =
        //       (data as List).map((data) => new Product.fromCat(data)).toList();
        //
        //   if (popularList.length > 0) {
        //     Product pop =
        //     new Product.popular("Popular", imagePath + "popular.svg");
        //     catList.insert(0, pop);
        //     context.read<CategoryProvider>().setSubList(popularList);
        //   }
        //}
      } else {
        setSnackbar("", context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  String video = "";

  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enquire Now"),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.clear, color: colors.blackTemp)),
                  ],
                ),
                Divider(
                  color: colors.blackTemp,
                ),
                Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 1.0,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 1200),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: false,
                          scrollDirection: Axis.horizontal,
                          height: 150,
                          onPageChanged: (position, reason) {
                            setState(() {
                              currentindex = position;
                            });
                            print(reason);
                            print(CarouselPageChangedReason.controller);
                          },
                        ),
                        items: homeSliderList.map((val) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: val.image == null || val.image == ""
                                    ? Image.asset(
                                        "assets/images/placeholder.png",
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        "${val.image}",
                                        fit: BoxFit.cover,
                                      )),
                          );
                        }).toList(),
                      ),
                      // margin: EdgeInsetsDirectional.only(top: 10),
                      // child: PageView.builder(
                      //   itemCount: homeSliderList.length,
                      //   scrollDirection: Axis.horizontal,
                      //   controller: _controller,
                      //   pageSnapping: true,
                      //   physics: AlwaysScrollableScrollPhysics(),
                      //   onPageChanged: (index) {
                      //     context.read<HomeProvider>().setCurSlider(index);
                      //   },
                      //   itemBuilder: (BuildContext context, int index) {
                      //     return pages[index];
                      //   },
                      // ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: homeSliderList.map((e) {
                          int index = homeSliderList.indexOf(e);
                          return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentindex == index
                                    ? Theme.of(context).colorScheme.fontColor
                                    : Theme.of(context).colorScheme.lightBlack,
                              ));
                        }).toList()),
                  ],
                ),
                Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(

                          ),

                          height: 40,
                          child: TextFormField(

                            controller: nameC,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter a name' : null,
                            onChanged: (value) {
                              setState(
                                  () => nameC = value as TextEditingController);
                            },
                            decoration: InputDecoration(

                                // errorBorder: OutlineInputBorder(
                                //     gapPadding: 30.0,
                                //     borderSide:
                                //         BorderSide(color: colors.grad1Color),
                                //     borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    borderSide: BorderSide(color: Colors.blue)),
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: "Name"),

                          ),

                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 45,
                          child: TextFormField(
                            controller: emailC,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter a email' : null,
                            onChanged: (value) {
                              setState(() =>
                                  emailC = value as TextEditingController);
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(

                              // errorBorder: OutlineInputBorder(
                              //     gapPadding: 30.0,
                              //     borderSide:
                              //         BorderSide(color: colors.grad1Color),
                              //     borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    borderSide: BorderSide(color: Colors.blue)),

                                hintStyle: TextStyle(fontSize: 14),
                                hintText: "Email"),
                          ),
                        )
                      ],
                    ))
              ],
            ),
            actions: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        print("controllers ${emailC.text} and ${nameC.text}");
                        subcribe(emailC.text, nameC.text);
                      }
                      // validator();
                      emailC.clear();
                      nameC.clear();
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Center(
                        child: Text('Get Started',
                            style: TextStyle(color: colors.whiteTemp)),
                      ),
                    ),
                  )),
            ],
          );
        });
      },
    );
  }

  Future<void> DialogBox() async {
    Widget remindButton = TextButton(
      child: Text("Remind me later"),
      onPressed: () {},
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {},
    );
    Widget launchButton = TextButton(
      child: Text("Launch missile"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Enquire Now"),
      actions: [
        Row(
          children: [
            TextFormField(
                decoration: InputDecoration(hintText: "Surendra Singh")),
          ],
        )
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> getBannerVideo() async {
    Map parameter = {
      //CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getVideoApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      print(getVideoApi.toString());
      print(parameter.toString());
      //  print("initiated");
      // print(msg);
      if (!error) {
        var data = getdata["data"];
        bannerVideo = data;
        video =
            "$imageUrl${bannerVideo[0]['video']}";
        _videoController = VideoPlayerController.network('$video')
          ..initialize().then((_) {
            setState(() {
            //   if (_controller.value.isPlaying) {
            //     _controller.pause();
            //   } else {
            //     // If the video is paused, play it.
            //     _controller.play();
            //   }
            // });
           // scroll_visibility == false ? _videoController!.pause() :
              _videoController!.play();
              _videoController!.setVolume(0);
              _videoController!.setLooping(true);
            });
          });
        //video = "https://alphawizztest.tk/plumbing_bazzar/${bannerVideo[0]['video']}";
        print("this is my video ^^ ${bannerVideo[0]['video']}");
        // catList =
        //     (data as List).map((data) => new Product.fromCat(data)).toList();
        //
        // if (getdata.containsKey("popular_categories")) {
        //   var data = getdata["popular_categories"];
        //   popularList =
        //       (data as List).map((data) => new Product.fromCat(data)).toList();
        //
        //   if (popularList.length > 0) {
        //     Product pop =
        //     new Product.popular("Popular", imagePath + "popular.svg");
        //     catList.insert(0, pop);
        //     context.read<CategoryProvider>().setSubList(popularList);
        //   }
        //}
      } else {
       // setSnackbar("", context);

      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 40),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color:
                                          Theme.of(context).colorScheme.white,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : Container(),
                  ],
                ))
            .toList());
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    Map parameter = {};
    if (pin != '') {
      parameter = {
        ZIPCODE: pin,
      };
    }

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        print("Seller Parameter =========> $parameter");
        print("Seller Data=====================> : $data ");
        sellerList =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }
      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sellerList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslated(context, 'SHOP_BY_SELLER')!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold)),
                              GestureDetector(
                                child:
                                    Text(getTranslated(context, 'VIEW_ALL')!),
                                onTap: () {
                                  // if(catList[index].name.toString() =="ASTRAL" ||
                                  //     catList[index].name.toString() =="Finox" ||
                                  //     catList[index].name.toString() =="Arshirwad" ||
                                  //     catList[index].name.toString() =="Plasto" ){
                                  //   isPipe = true;
                                  // }else{
                                  //   isPipe = false;
                                  // }

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SellerList(
                                                image: "",
                                                catId: "",
                                                isPipe: isPipe,
                                                pdf: "",
                                              )));
                                },
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: ListView.builder(
                      itemCount: sellerList.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: GestureDetector(
                            onTap: () {
                              print(sellerList[index].open_close_status);
                              if (sellerList[index].open_close_status == '1') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SellerProfile(
                                              sellerStoreName: sellerList[index]
                                                      .store_name ??
                                                  "",
                                              sellerRating: sellerList[index]
                                                      .seller_rating ??
                                                  "",
                                              sellerImage: sellerList[index]
                                                      .seller_profile ??
                                                  "",
                                              sellerName: sellerList[index]
                                                      .seller_name ??
                                                  "",
                                              sellerID:
                                                  sellerList[index].seller_id,
                                              storeDesc: sellerList[index]
                                                  .store_description,
                                            )));
                              } else {
                                showToast("Currently Store is Off");
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      bottom: 5.0),
                                  child: new ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: new FadeInImage(
                                      fadeInDuration:
                                          Duration(milliseconds: 150),
                                      image: CachedNetworkImageProvider(
                                        sellerList[index].seller_profile!,
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.contain,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                              erroWidget(50),
                                      placeholder: placeHolder(50),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    sellerList[index].seller_name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  width: 50,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }
}
