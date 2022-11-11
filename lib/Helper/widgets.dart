import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(msg){
  Fluttertoast.showToast(
      msg: "$msg",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: colors.primary,
      textColor: Colors.white,
      fontSize: 14.0
  );
}
Widget commonHWImage(url, height, width, placeHolder, context, errorImage) {
  return CachedNetworkImage(
    imageUrl: url,
    height:height,
    width: width,
    fit: BoxFit.fill,
    placeholder: (context, url) {
      return Container(
        height:height,
        width: width,
        child: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    },
    errorWidget: (context, url, error) {
      return Image.asset(
        errorImage,
        fit: BoxFit.fill,
        height:height,
        width: width,
      );
    },
  );
}