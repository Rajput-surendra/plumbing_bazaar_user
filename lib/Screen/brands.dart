import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Helper/widgets.dart';
import '../Model/Section_Model.dart';
import '../Provider/HomeProvider.dart';
import 'HomePage.dart';
import 'Search.dart';
import 'SellerList.dart';

class Brands extends StatefulWidget {
  const Brands({Key? key}) : super(key: key);

  @override
  State<Brands> createState() => _BrandsState();
}

class _BrandsState extends State<Brands> {

bool isPipe = false;
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
      appBar: getAppBar(getTranslated(context, 'BRANDS')!, context),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // childAspectRatio: 16 / 20,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          itemCount:
          //  catList.length > 12 ? 12 :
          catList.length,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            return
              // index != 7 ?
              GestureDetector(
                onTap: () async {
                  categoryId = brandList[index]['id'].toString();
                  cStatus = brandList[index]['c_status'].toString();
                  pdf = brandList[index]['banner'].toString();
                  if(cStatus == "1"){
                    isPipe = true;
                  }else{
                    isPipe = false;
                  }
                  //   Navigator.push(context, MaterialPageRoute(builder: (context)=> CategoryShopList()));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerList(
                            image: catList[index].image.toString(),
                            catId: categoryId.toString(),
                            isPipe : isPipe,
                            pdf: pdf.toString(),
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
                            catList[index].image.toString(),
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
      ),
    );
  }
}
