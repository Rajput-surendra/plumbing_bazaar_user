import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widgets.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import '../Model/SubCate_Model.dart';
import 'HomePage.dart';
import 'ProductList.dart';
import 'SellerList.dart';

class AllCategory extends StatefulWidget {


  // AllCategory({Key? key, required this.isAppBar}) : super(key: key);

  @override
  State<AllCategory> createState() => _AllCategoryState();
}

class _AllCategoryState extends State<AllCategory> {
  bool isPipe = false;
  @override
  void initState() {
    super.initState();
    subCate();
    // getCat();
  }

  Future<SubCateModel?> subCate()async{
    var request = http.Request('POST', Uri.parse('$getAllCatApi'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      return SubCateModel.fromJson(json.decode(data)
      );
    }
    else {
      return null;
    }

  }


  Future<void> getCat() async {
    await Future.delayed(Duration.zero);
    Map parameter = {
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar:
      // getAppBar(getTranslated(context, 'BRANDS')!, context),
      body:   Container(
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
                    itemBuilder: (c,i){
                      print("CAT ID: == ${model.data![i].id}");
                      return Column(

                        children: [

                          Padding(
                            padding: const EdgeInsets.only(left: 120.0, right: 120),
                            child: Divider(
                              color: colors.primary,),
                          ),
                          Text("${model.data![i].name}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),),
                          Padding(
                            padding: const EdgeInsets.only(left: 120.0, right: 120),
                            child: Divider(
                              color: colors.primary,),
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
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                // childAspectRatio: 16 / 20,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10),
                            itemCount:
                            model.data![i].subcategory!.length > 12 ? 12 :
                            model.data![i].subcategory!.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return
                                // index != 7 ?
                                GestureDetector(
                                  onTap: () async {
                                    //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
                                    categoryId = model.data![i].id.toString();
                                    image = "$imageUrl${model.data![i].subcategory![index].image.toString()}";
                                    // cStatus = brandList[index]['c_status'].toString();
                                    cStatus = model.data![i].status.toString();
                                    pdf = model.data![i].subcategory![index].banner.toString();
                                    // pdf = brandList[index]['banner'].toString();
                                    print("this is *** $cStatus");
                                    if(cStatus == "1"){
                                      isPipe = true;
                                    }else{
                                      isPipe = false;
                                    }
                                    //print("Image============${brandList[i]}");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SellerList(
                                              image: image.toString(),
                                              catId: categoryId.toString(),
                                              isPipe : isPipe,
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0.0),
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
                    }
                );
              } else if (snapshot.hasError) {
                return Icon(Icons.error_outline, color: colors.red,);
              } else {
                return Center(child: CircularProgressIndicator(
                  color: colors.primary,
                ));
              }
            }),
      )

      // Padding(
      //   padding: const EdgeInsets.all(15.0),
      //   child:
      //   GridView.builder(
      //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //         crossAxisCount: 3,
      //         // childAspectRatio: 16 / 20,
      //         mainAxisSpacing: 10,
      //         crossAxisSpacing: 10),
      //     itemCount:
      //     //  catList.length > 12 ? 12 :
      //     catList.length,
      //     shrinkWrap: true,
      //     physics: ScrollPhysics(),
      //     itemBuilder: (context, index) {
      //       return
      //         // index != 7 ?
      //         GestureDetector(
      //           onTap: () async {
      //             categoryId = brandList[index]['id'].toString();
      //             cStatus = brandList[index]['c_status'].toString();
      //             pdf = brandList[index]['banner'].toString();
      //             if(cStatus == "1"){
      //               isPipe = true;
      //             }else{
      //               isPipe = false;
      //             }
      //             //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
      //
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => SellerList(
      //                       image: catList[index].image.toString(),
      //                        catId: categoryId.toString(),
      //                       isPipe: isPipe,
      //                       pdf: pdf.toString(),
      //                       // catName: catList[index].name,
      //                       // subId: catList[index].subList,
      //                       // userLocation: currentAddress.text,
      //                       // getByLocation: false,
      //                     )));
      //           },
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             mainAxisAlignment: MainAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: <Widget>[
      //               Padding(
      //                 padding: EdgeInsets.only(bottom: 0.0),
      //                 child: new ClipRRect(
      //                   // borderRadius: BorderRadius.circular(35.0),
      //                   child: commonHWImage(
      //                       catList[index].image.toString(),
      //                       80.0,
      //                       120.0,
      //                       "",
      //                       context,
      //                       "assets/images/splashlogo.png"),
      //                   // "assets/images/placeholder.png"),
      //                 ),
      //               ),
      //               // Container(
      //               //   child: Text(
      //               //     catList[index].name!,
      //               //     style: Theme.of(context)
      //               //         .textTheme
      //               //         .caption!
      //               //         .copyWith(
      //               //         color: Theme.of(context)
      //               //             .colorScheme
      //               //             .fontColor,
      //               //         fontWeight: FontWeight.w600,
      //               //         fontSize: 12),
      //               //     overflow: TextOverflow.ellipsis,
      //               //     textAlign: TextAlign.center,
      //               //   ),
      //               //   // width: 50,
      //               // ),
      //             ],
      //           ),
      //         );
      //       //     : Column(
      //       //   children: [
      //       //     FloatingActionButton( backgroundColor:colors.whiteTemp,
      //       //       onPressed: () async {
      //       //         // Navigator.push(
      //       //         //     context,
      //       //         //     MaterialPageRoute(
      //       //         //         builder: (context) =>
      //       //         //             Category(catList.toList())));
      //       //       },
      //       //       child: Icon(Icons.keyboard_arrow_down_rounded,size: 30,),),
      //       //     Container(height: 10,),
      //       //     Text(
      //       //       "View All",
      //       //       style: TextStyle(
      //       //           fontSize: 13.0,
      //       //           fontWeight: FontWeight.w700,
      //       //           color:
      //       //           Theme.of(context).colorScheme.fontColor),
      //       //     ),
      //       //   ],
      //       // );
      //     },
      //   ),
      // ),
    );
  }

  // Future<void> getCat() async {
  //   await Future.delayed(Duration.zero);
  //   Map parameter = {
  //    // CAT_FILTER: "false",
  //   };
  //   apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];
  //
  //       catList =
  //           (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //
  //       if (getdata.containsKey("popular_categories")) {
  //         var data = getdata["popular_categories"];
  //         popularList =
  //             (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //         if (popularList.length > 0) {
  //           Product pop =
  //               new Product.popular("Popular", imagePath + "popular.svg");
  //           catList.insert(0, pop);
  //           context.read<CategoryProvider>().setSubList(popularList);
  //         }
  //       }
  //     } else {
  //       // setSnackbar(msg!, context);
  //       Fluttertoast.showToast(msg: msg!,
  //         backgroundColor: colors.primary
  //       );
  //     }
  //
  //     context.read<HomeProvider>().setCatLoading(false);
  //   }, onError: (error) {
  //     // setSnackbar(error.toString(), context);
  //     Fluttertoast.showToast(msg: error,
  //         backgroundColor: colors.primary
  //     );
  //     context.read<HomeProvider>().setCatLoading(false);
  //   });
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Consumer<HomeProvider>(
  //       builder: (context, homeProvider, _) {
  //         if (homeProvider.catLoading) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //         return catList.length > 0
  //             ? Column(
  //                 children: [
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Expanded(
  //                     child: Selector<CategoryProvider, List<Product>>(
  //                       builder: (context, data, child) {
  //                         return data.length > 0
  //                             ? GridView.builder(
  //                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                               crossAxisCount: 3,
  //                               // childAspectRatio: 16 / 20,
  //                               mainAxisSpacing: 10,
  //                               crossAxisSpacing: 10),
  //                           itemCount:
  //                           //catList.length > 12 ? 12 :
  //                           catList.length,
  //                           shrinkWrap: true,
  //                           physics: NeverScrollableScrollPhysics(),
  //                           itemBuilder: (context, index) {
  //                             return
  //                               // index != 7 ?
  //                               GestureDetector(
  //                                 onTap: () async {
  //                                   //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
  //                                   Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                           builder: (context) => SellerList(
  //                                             image: catList[index].image.toString(),
  //                                             // catId: catList[index].id,
  //                                             // catName: catList[index].name,
  //                                             // subId: catList[index].subList,
  //                                             // userLocation: currentAddress.text,
  //                                             // getByLocation: false,
  //                                           )));
  //                                 },
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.center,
  //                                   mainAxisAlignment: MainAxisAlignment.start,
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: <Widget>[
  //                                     Padding(
  //                                       padding: EdgeInsets.only(bottom: 0.0),
  //                                       child: new ClipRRect(
  //                                         // borderRadius: BorderRadius.circular(35.0),
  //                                         child: commonHWImage(
  //                                             catList[index].image.toString(),
  //                                             80.0,
  //                                             120.0,
  //                                             "",
  //                                             context,
  //                                             "assets/images/splashlogo.png"),
  //                                         // "assets/images/placeholder.png"),
  //                                       ),
  //                                     ),
  //                                     // Container(
  //                                     //   child: Text(
  //                                     //     catList[index].name!,
  //                                     //     style: Theme.of(context)
  //                                     //         .textTheme
  //                                     //         .caption!
  //                                     //         .copyWith(
  //                                     //         color: Theme.of(context)
  //                                     //             .colorScheme
  //                                     //             .fontColor,
  //                                     //         fontWeight: FontWeight.w600,
  //                                     //         fontSize: 12),
  //                                     //     overflow: TextOverflow.ellipsis,
  //                                     //     textAlign: TextAlign.center,
  //                                     //   ),
  //                                     //   // width: 50,
  //                                     // ),
  //                                   ],
  //                                 ),
  //                               );
  //                             //     : Column(
  //                             //   children: [
  //                             //     FloatingActionButton( backgroundColor:colors.whiteTemp,
  //                             //       onPressed: () async {
  //                             //         // Navigator.push(
  //                             //         //     context,
  //                             //         //     MaterialPageRoute(
  //                             //         //         builder: (context) =>
  //                             //         //             Category(catList.toList())));
  //                             //       },
  //                             //       child: Icon(Icons.keyboard_arrow_down_rounded,size: 30,),),
  //                             //     Container(height: 10,),
  //                             //     Text(
  //                             //       "View All",
  //                             //       style: TextStyle(
  //                             //           fontSize: 13.0,
  //                             //           fontWeight: FontWeight.w700,
  //                             //           color:
  //                             //           Theme.of(context).colorScheme.fontColor),
  //                             //     ),
  //                             //   ],
  //                             // );
  //                           },
  //                         )
  //                         // GridView.count(
  //                         //         padding: EdgeInsets.symmetric(horizontal: 20),
  //                         //         crossAxisCount: 3,
  //                         //         shrinkWrap: true,
  //                         //         crossAxisSpacing: 5,
  //                         //         children: List.generate(
  //                         //           data.length,
  //                         //           (index) {
  //                         //             return subCatItem(data, index, context);
  //                         //           },
  //                         //         ))
  //                             : Center(
  //                                 child:
  //                                     Text(getTranslated(context, 'noItem')!));
  //                       },
  //                       selector: (_, categoryProvider) =>
  //                           categoryProvider.subList,
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : Container();
  //       },
  //     ),
  //   );
  // }
  //
  // Widget catItem(int index, BuildContext context1) {
  //   return Selector<CategoryProvider, int>(
  //     builder: (context, data, child) {
  //       if (index == 0 && (popularList.length > 0)) {
  //         return GestureDetector(
  //           child: Container(
  //             height: 100,
  //             decoration: BoxDecoration(
  //                 shape: BoxShape.rectangle,
  //                 color: data == index
  //                     ? Theme.of(context).colorScheme.white
  //                     : Colors.transparent,
  //                 border: data == index
  //                     ? Border(
  //                         left: BorderSide(width: 5.0, color: colors.primary),
  //                       )
  //                     : null
  //                 // borderRadius: BorderRadius.all(Radius.circular(20))
  //                 ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(25.0),
  //                     child: SvgPicture.asset(
  //                       data == index
  //                           ? imagePath + "popular_sel.svg"
  //                           : imagePath + "popular.svg",
  //                       color: colors.primary,
  //                     ),
  //                   ),
  //                 ),
  //                 Text(
  //                   catList[index].name! + "\n",
  //                   textAlign: TextAlign.center,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: Theme.of(context1).textTheme.caption!.copyWith(
  //                       color: data == index
  //                           ? colors.primary
  //                           : Theme.of(context).colorScheme.fontColor),
  //                 )
  //               ],
  //             ),
  //           ),
  //           onTap: () {
  //             context1.read<CategoryProvider>().setCurSelected(index);
  //             context1.read<CategoryProvider>().setSubList(popularList);
  //           },
  //         );
  //       } else {
  //         return GestureDetector(
  //           child: Container(
  //             height: 100,
  //             decoration: BoxDecoration(
  //                 shape: BoxShape.rectangle,
  //                 color: data == index
  //                     ? Theme.of(context).colorScheme.white
  //                     : Colors.transparent,
  //                 border: data == index
  //                     ? Border(
  //                         left: BorderSide(width: 5.0, color: colors.primary),
  //                       )
  //                     : null),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Expanded(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(25.0),
  //                         child: FadeInImage(
  //                           image: CachedNetworkImageProvider(
  //                               catList[index].image!),
  //                           fadeInDuration: Duration(milliseconds: 150),
  //                           fit: BoxFit.contain,
  //                           imageErrorBuilder: (context, error, stackTrace) =>
  //                               erroWidget(50),
  //                           placeholder: placeHolder(50),
  //                         )),
  //                   ),
  //                 ),
  //                 Text(
  //                   catList[index].name! + "\n",
  //                   textAlign: TextAlign.center,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: Theme.of(context1).textTheme.caption!.copyWith(
  //                       color: data == index
  //                           ? colors.primary
  //                           : Theme.of(context).colorScheme.fontColor),
  //                 )
  //               ],
  //             ),
  //           ),
  //           onTap: () {
  //             context1.read<CategoryProvider>().setCurSelected(index);
  //             if (catList[index].subList == null ||
  //                 catList[index].subList!.length == 0) {
  //               print("kjhasdashjkdkashjdksahdsahdk");
  //               context1.read<CategoryProvider>().setSubList([]);
  //               Navigator.push(
  //                   context1,
  //                   MaterialPageRoute(
  //                     builder: (context) => ProductList(
  //                       name: catList[index].name,
  //                       id: catList[index].id,
  //                       tag: false,
  //                       fromSeller: false,
  //                     ),
  //                   ));
  //             } else {
  //               context1
  //                   .read<CategoryProvider>()
  //                   .setSubList(catList[index].subList);
  //             }
  //           },
  //         );
  //       }
  //     },
  //     selector: (_, cat) => cat.curCat,
  //   );
  // }
  //
  // subCatItem(List<Product> subList, int index, BuildContext context) {
  //   return GestureDetector(
  //     child: Column(
  //       children: <Widget>[
  //         Expanded(
  //             child: Card(
  //           elevation: 4,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(15),
  //                 image: DecorationImage(
  //                     fit: BoxFit.contain,
  //                     image: NetworkImage('${subList[index].image!}'))),
  //             // child: FadeInImage(
  //             //   image: CachedNetworkImageProvider(subList[index].image!),
  //             //   fadeInDuration: Duration(milliseconds: 150),
  //             //   fit: BoxFit.cover,
  //             //   imageErrorBuilder: (context, error, stackTrace) =>
  //             //       erroWidget(50),
  //             //   placeholder: placeHolder(50),
  //             // ),
  //           ),
  //         )),
  //         Text(
  //           subList[index].name! + "\n",
  //           textAlign: TextAlign.center,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //           style: Theme.of(context)
  //               .textTheme
  //               .caption!
  //               .copyWith(color: Theme.of(context).colorScheme.fontColor),
  //         )
  //       ],
  //     ),
  //     onTap: () {
  //       if (context.read<CategoryProvider>().curCat == 0 &&
  //           popularList.length > 0) {
  //         if (popularList[index].subList == null ||
  //             popularList[index].subList!.length == 0) {
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ProductList(
  //                   name: popularList[index].name,
  //                   id: popularList[index].id,
  //                   tag: false,
  //                   fromSeller: false,
  //                 ),
  //               ));
  //         } else {
  //
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => SubCategory(
  //                   subList: popularList[index].subList,
  //                   title: popularList[index].name ?? "",
  //                 ),
  //               ));
  //         }
  //       } else if (subList[index].subList == null ||
  //           subList[index].subList!.length == 0) {
  //         print(StackTrace.current);
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ProductList(
  //                 name: subList[index].name,
  //                 id: subList[index].id,
  //                 tag: false,
  //                 fromSeller: false,
  //               ),
  //             ));
  //       } else {
  //         print(StackTrace.current);
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => SubCategory(
  //                 subList: subList[index].subList,
  //                 title: subList[index].name ?? "",
  //               ),
  //             ));
  //       }
  //     },
  //   );
  // }
}
