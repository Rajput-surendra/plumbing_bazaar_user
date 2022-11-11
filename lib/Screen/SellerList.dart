import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widgets.dart';
import 'package:eshop_multivendor/Screen/pdf_view.dart';
import 'package:eshop_multivendor/Screen/subcategory_products.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/CartProvider.dart';
import '../Provider/FavoriteProvider.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/UserProvider.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'Product_Detail.dart';
import 'Seller_Details.dart';

class SellerList extends StatefulWidget {
  String image;
  String catId;
  bool isPipe;
  String pdf;
   SellerList({
     required this.image, required this.catId, required this.isPipe, required this.pdf, Key? key}) : super(key: key);

  @override
  _SellerListState createState() => _SellerListState();
}

class _SellerListState extends State<SellerList> {
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  File? imagePath;
  //var filePath;
  List<SectionModel> sectionList = [];
  List<Product> subCatList = [];
  String? url;

  ///
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  ///
  ///
  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  bool isOnOff = false;
  List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;


  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        if (int.parse(qty) < productList[index].minOrderQuntity!) {
          qty = productList[index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty");
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          QTY: qty
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }, onError: (error) {
          setSnackbar(error.toString());
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        });
      } else {
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

  removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        int qty;

        qty =
        /*      (int.parse(productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount!)*/
        (int.parse(_controller[index].text) -
            int.parse(productList[index].qtyStepSize!));

        if (qty < productList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = ;

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!);
          }

          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }, onError: (error) {
          setSnackbar(error.toString());
          setState(() {
            _isProgress = false;
          });
        });
      } else {
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

  _setFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
        await post(setFavoriteApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "1" : productList[index].isFav = "1";

          context.read<FavoriteProvider>().addFavItem(model);
        } else {
          setSnackbar(msg!);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
        await post(removeFavApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "0" : productList[index].isFav = "0";
          context
              .read<FavoriteProvider>()
              .removeFavItem(model.prVarientList![0].id!);
        } else {
          setSnackbar(msg!);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }


  Widget listItem(int index) {
    if (index < productList.length) {
      Product model = productList[index];
      totalProduct = model.total;

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
      model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }

      double price =
      double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
            double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(
                          tag: "ProList$index${model.id}",
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              child: Stack(
                                children: [
                                  FadeInImage(
                                    image: NetworkImage(
                                        model.image!),
                                    height: 125.0,
                                    width: 135.0,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                        erroWidget(125),
                                    placeholder: placeHolder(125),
                                  ),
                                  Positioned.fill(
                                      child: model.availability == "0"
                                          ? Container(
                                        height: 55,
                                        color: Colors.white70,
                                        // width: double.maxFinite,
                                        padding: EdgeInsets.all(2),
                                        child: Center(
                                          child: Text(
                                            getTranslated(context,
                                                'OUT_OF_STOCK_LBL')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                              color: Colors.red,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                          : Container()),
                                  (off != 0 || off != 0.0 || off != 0.00)
                                      ? Container(
                                    decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        off.toStringAsFixed(2) + "%",
                                        style: TextStyle(
                                            color: colors.whiteTemp,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(5),
                                  )
                                      : Container()
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //       color: colors.red,
                                  //       borderRadius:
                                  //           BorderRadius.circular(10)),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(5.0),
                                  //     child: Text(
                                  //       off.toStringAsFixed(2) + "%",
                                  //       style: TextStyle(
                                  //           color: colors.whiteTemp,
                                  //           fontWeight: FontWeight.bold,
                                  //           fontSize: 9),
                                  //     ),
                                  //   ),
                                  //   margin: EdgeInsets.all(5),
                                  // )
                                ],
                              ))),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                model.name!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: colors.primary),
                                    // Theme.of(context)
                                    //     .colorScheme
                                    //     .primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              model.prVarientList![model.selVarient!]
                                  .attr_name !=
                                  null &&
                                  model.prVarientList![model.selVarient!]
                                      .attr_name!.isNotEmpty
                                  ? ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                  att.length >= 2 ? 2 : att.length,
                                  itemBuilder: (context, index) {
                                    return Row(children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ":",
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 5.0),
                                        child: Text(
                                          val[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      )
                                    ]);
                                  })
                                  : Container(),
                              (model.rating! == "0" || model.rating! == "0.0")
                                  ? Container()
                                  : Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: double.parse(model.rating!),
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                      //color: colors.primary,
                                    ),
                                    unratedColor:
                                    Colors.grey.withOpacity(0.5),
                                    itemCount: 5,
                                    itemSize: 18.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    " (" + model.noOfRating! + ")",
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline,
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                      double.parse(model
                                          .prVarientList![
                                      model.selVarient!]
                                          .disPrice!) !=
                                          0
                                          ? CUR_CURRENCY! +
                                          "" +
                                          model
                                              .prVarientList![
                                          model.selVarient!]
                                              .price!
                                          : "",
                                      // CUR_CURRENCY! +
                                      //     " " +
                                      //     price.toString() +
                                      //     " ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.bold)),
                                  // Text(
                                  //   double.parse(model
                                  //       .prVarientList![
                                  //   model.selVarient!]
                                  //       .disPrice!) !=
                                  //       0
                                  //       ? CUR_CURRENCY! +
                                  //       "" +
                                  //       model
                                  //           .prVarientList![
                                  //       model.selVarient!]
                                  //           .price!
                                  //       : "",
                                  //   style: Theme.of(context)
                                  //       .textTheme
                                  //       .overline!
                                  //       .copyWith(
                                  //       decoration:
                                  //       TextDecoration.lineThrough,
                                  //       letterSpacing: 0,
                                  //       fontSize: 15,
                                  //       fontWeight: FontWeight.bold
                                  //   ),
                                  // ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                     model
                                          .prVarientList![
                                      model.selVarient!]
                                          .range! !=
                                          "0"
                                          ?
                                          model
                                              .prVarientList![
                                          model.selVarient!]
                                              .range!
                                          : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.bold)),
                                  // Text(
                                  //   double.parse(model
                                  //       .prVarientList![
                                  //   model.selVarient!]
                                  //       .disPrice!) !=
                                  //       0
                                  //       ? CUR_CURRENCY! +
                                  //       "" +
                                  //       model
                                  //           .prVarientList![
                                  //       model.selVarient!]
                                  //           .price!
                                  //       : "",
                                  //   style: Theme.of(context)
                                  //       .textTheme
                                  //       .overline!
                                  //       .copyWith(
                                  //       decoration:
                                  //       TextDecoration.lineThrough,
                                  //       letterSpacing: 0,
                                  //       fontSize: 15,
                                  //       fontWeight: FontWeight.bold
                                  //   ),
                                  // ),
                                ],
                              ),
                              _controller[index].text != "0"
                                  ? Row(
                                children: [
                                  //Spacer(),
                                  model.availability == "0"
                                      ? Container()
                                      : cartBtnList
                                      ? Row(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Card(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    50),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress ==
                                                  false &&
                                                  (int.parse(_controller[
                                                  index]
                                                      .text) >
                                                      0)) {
                                                removeFromCart(
                                                    index);
                                              }
                                            },
                                          ),
                                          Container(
                                            width: 37,
                                            height: 20,
                                            child: Stack(
                                              children: [
                                                Selector<
                                                    CartProvider,
                                                    Tuple2<
                                                        List<dynamic>,
                                                        List<dynamic>>>(
                                                  builder:
                                                      (context,
                                                      data,
                                                      child) {
                                                    _controller[index]
                                                        .text = data
                                                        .item1
                                                        .contains(model
                                                        .id)
                                                        ? data
                                                        .item2[data.item1.indexWhere((element) =>
                                                    element ==
                                                        model.id)]
                                                        .toString()
                                                        : "0";
                                                    return TextField(
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      readOnly:
                                                      true,
                                                      style: TextStyle(
                                                          fontSize:
                                                          12,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .fontColor),
                                                      controller:
                                                      _controller[
                                                      index],
                                                      // _controller[index],
                                                      decoration:
                                                      InputDecoration(
                                                        border:
                                                        InputBorder.none,
                                                      ),
                                                    );
                                                  },
                                                  selector: (_,
                                                      provider) =>
                                                      Tuple2(
                                                          provider
                                                              .cartIdList,
                                                          provider
                                                              .qtyList),
                                                ),
                                                // PopupMenuButton<
                                                //     String>(
                                                //   tooltip: '',
                                                //   icon:
                                                //       const Icon(
                                                //     Icons
                                                //         .arrow_drop_down,
                                                //     size: 1,
                                                //   ),
                                                //   onSelected:
                                                //       (String
                                                //           value) {
                                                //     if (_isProgress ==
                                                //         false)
                                                //       addToCart(
                                                //           index,
                                                //           value);
                                                //   },
                                                //   itemBuilder:
                                                //       (BuildContext
                                                //           context) {
                                                //     return model
                                                //         .itemsCounter!
                                                //         .map<
                                                //             PopupMenuItem<
                                                //                 String>>((String
                                                //             value) {
                                                //       return new PopupMenuItem(
                                                //           child: new Text(
                                                //               value,
                                                //               style: TextStyle(color: Theme.of(context).colorScheme.fontColor)),
                                                //           value: value);
                                                //     }).toList();
                                                //   },
                                                // ),
                                              ],
                                            ),
                                          ), // ),

                                          GestureDetector(
                                            child: Card(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    50),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress ==
                                                  false) {
                                                addToCart(
                                                    index,
                                                    (int.parse(model
                                                        .prVarientList![model
                                                        .selVarient!]
                                                        .cartCount!) +
                                                        int.parse(
                                                            model.qtyStepSize!))
                                                        .toString());
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              )
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // model.availability == "0"
                  //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .subtitle2!
                  //             .copyWith(
                  //                 color: Colors.red,
                  //                 fontWeight: FontWeight.bold))
                  //     : Container(),
                ]),
                onTap: () {
                  Product model = productList[index];
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                          model: model,
                          index: index,
                          secPos: 0,
                          list: true,
                        )),
                  );
                },
              ),
            ),
            _controller[index].text == "0"
                ? Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 5,
              end: 45,
              child: InkWell(
                onTap: () {
                  if (_isProgress == false) {
                    addToCart(
                        index,
                        (int.parse(_controller[index].text) +
                            int.parse(model.qtyStepSize!))
                            .toString());
                  }
                },
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
            )
                : Container(),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 5,
                end: 0,
                child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: model.isFavLoading!
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 0.7,
                          )),
                    )
                        : Selector<FavoriteProvider, List<String?>>(
                      builder: (context, data, child) {
                        return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              !data.contains(model.id)
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              size: 20,
                            ),
                          ),
                          onTap: () {
                            if (CUR_USERID != null) {
                              !data.contains(model.id)
                                  ? _setFav(-1, model)
                                  :
                           _removeFav(-1, model);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            }
                          },
                        );
                      },
                      selector: (_, provider) => provider.favIdList,
                    )))
          ],
        ),
      );
    } else
      return Container();
  }

 @override
 void initState() {
    getProduct("");
    getSubCat();
    // TODO: implement initState
    super.initState();

   // url = widget.pdf;
  }

  // Future _launchURL() async {
  //   print("this is pdf url ${widget.pdf}");
  //    url = widget.pdf;
  //        //"https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf";
  //       // widget.pdf;
  //   //if (await canLaunchUrl(Uri.parse(url!))) {
  //      await launchUrl(Uri.parse(url!));
  //  // } else {
  //     throw 'Could not launch $url';
  // //  }
  // }
  Future _launchURL() async{
    var url = '$imageUrl${widget.pdf}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }



  @override
  Widget build(BuildContext context) {
    print("CATEORY ID++++++ ${widget.catId}");
    // print("CATEORY ID++++++ ${widget.catId}");
    print("new =================${image.toString()}");

    return Scaffold(
        appBar: getAppBar(getTranslated(context, 'SHOP_BY_BRAND')!, context),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 0.0),
                child: new ClipRRect(
                  // borderRadius: BorderRadius.circular(35.0),
                  child: commonHWImage(
                    widget.image,
                     // catList[index].image.toString(),
                      200.0,
                      MediaQuery.of(context).size.width,
                      "",
                      context,
                      "assets/images/splashlogo.png"),
                  // "assets/images/placeholder.png"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: colors.primary),
                        onPressed: () async {
                          if(CUR_USERID == null || CUR_USERID == "" ) {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));

                          }else{
                            _showDialog();

                          }
                        }, child: Text("Upload Estimate")),
                   widget.isPipe == true ?
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: colors.primary),
                          onPressed: () async{
                            _launchURL();
                          }, child: Text("Download Catalog")),
                    )
                       : SizedBox(
                     width: 0,
                   height: 0,)
                  ],
                ),
              ),
              _subCatSection(),
              widget.isPipe == true ?
                  SizedBox(height: 0,)
            :
              _productsSection()

             // _section()
            ],
          ),
        )
    );
  }

  Future<void> getCat() async {
    await Future.delayed(Duration.zero);
    Map parameter = {
      // "id" : widget.catId
      // CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => new Product.fromCat(data)).toList();


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
        // }
      } else {
        // setSnackbar(msg!, context);
        Fluttertoast.showToast(msg: msg!,
            backgroundColor: colors.primary
        );
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      Fluttertoast.showToast(msg: error,
          backgroundColor: colors.primary
      );
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  Future<void> getSubCat() async {
    await Future.delayed(Duration.zero);
    Map parameter = {
      "id" : widget.catId
      // CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getSubCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        subCatList =
            (data as List).map((data) => new Product.fromCat(data)).toList();

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
        // }
      } else {
        // setSnackbar(msg!, context);
        Fluttertoast.showToast(msg: msg!,
            backgroundColor: colors.primary
        );
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      Fluttertoast.showToast(msg: error,
          backgroundColor: colors.primary
      );
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  void getProduct(String top) {
    var parameter = {};
    if(widget.catId != "" && widget.catId != null ) {
      parameter = {
        LIMIT: perPage.toString(),
        OFFSET: "0", //offset.toString(),
        TOP_RETAED: top,
        "category_id": widget.catId
        // DISCOUNT: disList[curDis].toString()
      };
    }


    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    print(parameter.toString());

    apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        total = int.parse(getdata["total"]);

        if ((offset) < total) {
          productList.clear();

          var data = getdata["data"];

          productList =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          print("${productList.toString()} %% ${productList.length}");


          if (getdata.containsKey(TAG)) {
            print("we are here");
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          //getAvailVarient();

          //  offset = offset + perPage;
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg!);
        }
      } else {
        if (msg != "Products Not Found !") setSnackbar(msg!);
      }

      setState(() {
       // _productLoading = false;
      });
      // context.read<ProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString());
      setState(() {
       // _productLoading = false;
      });
      //context.read<ProductListProvider>().setProductLoading(false);
    });
  }

  Future<void> uploadEstimate(File _image) async {

    var request = http.MultipartRequest('POST', Uri.parse(
        '$uploadEstimateApi'));
    request.fields.addAll({
      'user_id': '$CUR_USERID',
      'username': nameController.text,
      'mobile': mobileController.text
    });
    print(request.toString());

    request.files.add(
        await http.MultipartFile.fromPath('estimate', _image.path));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(response.statusCode);
      String msg = "Request Sent Successfully";
      setSnackbar(msg);
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

    // apiBaseHelper.postAPICall(uploadEstimateApi, parameter).then((getdata) {
    //   print("Success@@");
    //   bool error = getdata["error"];
    //   String? msg = getdata["message"];
    //   if (!error) {
    //
    //     print(msg.toString());
    //     print("Success@@");
    //     // total = int.parse(getdata["total"]);
    //     //
    //     // if ((offset) < total) {
    //     //   productList.clear();
    //     //
    //     //   var data = getdata["data"];
    //     //
    //     //   productList =
    //     //       (data as List).map((data) => new Product.fromJson(data)).toList();
    //     //
    //     //   print("${productList.toString()} %% ${productList.length}");
    //     //
    //     //
    //     //   if (getdata.containsKey(TAG)) {
    //     //     print("we are here");
    //     //     List<String> tempList = List<String>.from(getdata[TAG]);
    //     //     if (tempList != null && tempList.length > 0) tagList = tempList;
    //     //   }
    //
    //       //getAvailVarient();
    //
    //       //  offset = offset + perPage;
    //     // } else {
    //     //   if (msg != "Products Not Found !") setSnackbar(msg!);
    //     // }
    //   } else {
    //     if (msg != "Products Not Found !") setSnackbar(msg!);
    //   }
    //
    //   setState(() {
    //     // _productLoading = false;
    //   });
    //   // context.read<ProductListProvider>().setProductLoading(false);
    // }
  //   , onError: (error) {
  //     setSnackbar(error.toString());
  //     setState(() {
  //       // _productLoading = false;
  //     });
  //     //context.read<ProductListProvider>().setProductLoading(false);
  //   });
  // }

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

  _subCatSection(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child:
      // GridView.builder(
      //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //       crossAxisCount: 3,
      //       // childAspectRatio: 16 / 20,
      //       mainAxisSpacing: 10,
      //       crossAxisSpacing: 10),
      subCatList.length == 0
          ?
      Center(
          child: Container(
            height: 20,
          child: Text("No Categories Found..!!")))
      // : listType
      //  ?
          :
      Container(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
          //  catList.length > 12 ? 12 :
          subCatList.length,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            return
              // index != 7 ?
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    print("ccccccccccccccccc${widget.catId.toString()}");
                    print("okk ${subCatList[index].id.toString()}");
                    //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubCatProducts(
                              image: "$imageUrl${subCatList[index].image.toString()}",
                              catId: widget.catId,
                              // catName: catList[index].name,
                              // subId: catList[index].subList,
                              // userLocation: currentAddress.text,
                              // getByLocation: false,
                            )));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.0),
                        child: new ClipRRect(
                          // borderRadius: BorderRadius.circular(35.0),
                          child: commonHWImage(
                              "$imageUrl${subCatList[index].image.toString()}",
                              80.0,
                              120.0,
                              "",
                              context,
                              "assets/images/splashlogo.png"),
                          // "assets/images/placeholder.png"),
                        ),
                      ),
                      Container(
                        child: Text(
                          subCatList[index].name!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        // width: 50,
                      ),
                    ],
                  ),
                ),
              );
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
      ),
    );
  }

  _productsSection(){
    return Container(
        height: 500,
        child: productList.length == 0
            ? getNoItem(context)
        // : listType
        //  ?
            : ListView.builder(
          controller: controller,
          itemCount: (offset < total)
              ? productList.length + 1
              : productList.length,
         shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return
              // (index == productList.length && isLoadingmore)
              //   ? singleItemSimmer(context) :
              listItem(index);
          },
        )
      // : GridView.count(
      // padding: EdgeInsetsDirectional.only(top: 5),
      // crossAxisCount: 2,
      // controller: controller,
      // childAspectRatio: 0.78,
      // physics: AlwaysScrollableScrollPhysics(),
      // children: List.generate(
      //   (offset < total)
      //       ? productList.length + 1
      //       : productList.length,
      //       (index) {
      //     return (index == productList.length && isLoadingmore)
      //         ? simmerSingleProduct(context)
      //         : productItem(index, index, index % 2 == 0 ? true : false);
      //   },
      // )),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                " " + CUR_CURRENCY! + " " + price.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, bottom: 5, top: 3),
                child: double.parse(sectionList[secPos]
                    .productList![index]
                    .prVarientList![0]
                    .disPrice!) !=
                    0
                    ? Row(
                  children: <Widget>[
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
                      style: Theme.of(context)
                          .textTheme
                          .overline!
                          .copyWith(
                          decoration: TextDecoration.lineThrough,
                          letterSpacing: 0,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Flexible(
                      child: Text(" | " + "$offPer%",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .overline!
                              .copyWith(
                              color: colors.primary,
                              letterSpacing: 0,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          )),
                    ),
                  ],
                )
                    : Container(
                  height: 5,
                ),
              )
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


  Future<void> getFromGallery() async {

    var result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      imagePath = File(result.files.single.path!);
      // if (mounted) {
      //   await setProfilePic(image);
      // }
    } else {
      // User canceled the picker
    }

  }

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10, bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              UPLOAD_ESTIMATE,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                            ),

                            Form(
                             //   key: _formkey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        CUSTOMER_NAME,
                                        style: Theme.of(this.context)
                                            .textTheme
                                         .subtitle1!
                                            .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 3, bottom: 10),
                                       // EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                       // fromLTRB(20.0, 0, 20.0, 0),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: TextFormField(
                                            //keyboardType: TextInputType.number,
                                           // validator: validateField,
                                            autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            //  hintText: WITHDRWAL_AMT,
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                 //color: lightBlack,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            controller: nameController,
                                          ),
                                        )),
                                    Text(
                                      CUSTOMER_MOBILE,
                                      style: Theme.of(this.context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 3, bottom: 10),
                                        // EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        // fromLTRB(20.0, 0, 20.0, 0),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            maxLength: 10,
                                            // validator: validateField,
                                            autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              counterText: "",
                                              //  hintText: WITHDRWAL_AMT,
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                //color: lightBlack,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            controller: mobileController,
                                          ),
                                        )),
                                    Text(
                                      ESTIMATE_FILE,
                                      style: Theme.of(this.context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                    ),
                                    Card(
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        width: 220,
                                        child: InkWell(
                                          onTap: () {
                                            // if (mounted) {
                                            getFromGallery();
                                            // _imgFromGallery();
                                            // onBtnSelected!();
                                            // }
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsetsDirectional.only(end: 20),
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  // shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 1.0, color: Colors.white)),
                                                //  Theme.of(context).colorScheme.primary)),
                                                child:
                                                ClipRRect(
                                                  // borderRadius: BorderRadius.circular(100.0),
                                                  child:
                                                  // Consumer<UserProvider>(builder: (context, userProvider, _) {
                                                  // return
                                                  //    userProvider.profilePic != ''
                                                  //      ?
                                                  imagePath != null ?
                                                  // Image.asset("${imagePath}")
                                                  Image.file(imagePath!)
                                                  // FadeInImage(
                                                  //   fadeInDuration: Duration(milliseconds: 150),
                                                  //   image: NetworkImage(filePath!),
                                                  // // NetworkImage(filePath!),
                                                  //  // CachedNetworkImageProvider(userProvider.profilePic.toString()),
                                                  //   height: 64.0,
                                                  //   width: 64.0,
                                                  //   fit: BoxFit.cover,
                                                  //   imageErrorBuilder: (context, error, stackTrace) =>
                                                  //       errorWidget(64),
                                                  //   placeholder: placeHolder(64),
                                                  // )
                                                      : imagePlaceHolder(62, context),
                                                  // }),
                                                ),
                                              ),
                                              Icon(Icons.download_rounded, color: colors.primary,),
                                              Text("Upload Image",),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ])),
                  actions: <Widget>[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: colors.primary
                        ),
                        child: Text(
                          "Cancel",
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                              color: Theme.of(context).colorScheme.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: colors.primary
                        ),
                        child: Text(
                          SEND_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                              color: Theme.of(context).colorScheme.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          uploadEstimate(imagePath!);
                          nameController.clear();
                          mobileController.clear();

                          Navigator.of(context).pop();
                        //  final form = _formkey.currentState!;
                        //   if (form.validate()) {
                        //     form.save();
                        //     setState(() {
                        //       Navigator.pop(context);
                        //     });
                          //  sendRequest();
                         // }
                        }
                        )
                  ],
                );
              });
        });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  Widget catItem(int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: FadeInImage(
                    image: CachedNetworkImageProvider(
                        sellerList[index].seller_profile!),
                    fadeInDuration: Duration(milliseconds: 150),
                    fit: BoxFit.fill,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        erroWidget(50),
                    placeholder: placeHolder(50),
                  )),
            ),
          ),
          Text(
            sellerList[index].seller_name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        if(sellerList[index].open_close_status == "1"){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerProfile(
                    sellerStoreName: sellerList[index].store_name ?? "",
                    sellerRating: sellerList[index].seller_rating ?? "",
                    sellerImage: sellerList[index].seller_profile ?? "",
                    sellerName: sellerList[index].seller_name ?? "",
                    sellerID: sellerList[index].seller_id,
                    storeDesc: sellerList[index].store_description,
                  )));
        } else {
          showToast("Currently Store is Off");
        }
      },
    );
  }
}
