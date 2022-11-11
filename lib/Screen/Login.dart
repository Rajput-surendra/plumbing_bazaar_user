import 'dart:async';
import 'dart:convert';

import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/SendOtp.dart';
import 'package:eshop_multivendor/Screen/SignUp.dart';
import 'package:eshop_multivendor/Screen/Verify_Otp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String? countryName;
  String? countrycode;
  FocusNode? passFocus, monoFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getToken();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      // getVerifyUser();
      getLoginUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  String? token;

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    print("fcm is $token");
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getLoginUser() async {
    var data = {MOBILE: mobileController.text.toString()};
    Response response =
        await post(loginWithOtpApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);
    bool error = getdata["error"];
    String? msg = getdata["message"];
    int? otp = getdata['data']['otp'];

    await buttonController!.reverse();

    if (error = true) {
      setSnackbar(otp.toString());
      var i = getdata["userdata"];
      id = i[ID];
      username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
      image = i[IMAGE];

      CUR_USERID = id;
      // CUR_USERNAME = username;

      UserProvider userProvider =
          Provider.of<UserProvider>(this.context, listen: false);
      userProvider.setName(username ?? "");
      userProvider.setEmail(email ?? "");
      userProvider.setProfilePic(image ?? "");

      SettingProvider settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
          address, pincode, latitude, longitude, image, context);
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyOtp(
                  login: true,
                  otp: otp,
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: getTranslated(context, 'SEND_OTP_TITLE'),
                )));
      });


    } else {
      // Future.delayed(Duration(seconds: 1)).then((_) {
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => VerifyOtp(
      //             login: true,
      //             otp: otp,
      //             mobileNumber: mobile!,
      //             countryCode: countrycode,
      //             title: getTranslated(context, 'SEND_OTP_TITLE'),
      //           )));
      // });
      setSnackbar(msg!);
    }
  }

  // Future<void> getLoginUser() async {
  //   try {
  //     var data = {MOBILE: mobileController.text};
  //     Response response =
  //     await post(loginWithOtpApi, body: data, headers: headers)
  //         .timeout(Duration(seconds: timeOut));
  //
  //     var getdata = json.decode(response.body);
  //     bool? error = getdata["error"];
  //     String? msg = getdata["message"];
  //     await buttonController!.reverse();
  //
  //     SettingProvider settingsProvider =
  //     Provider.of<SettingProvider>(context, listen: false);
  //     print("this is msg and otp $msg & ${getdata["data"]["otp"]}");
  //     // if(widget.checkForgot == "false"){
  //      // if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
  //         if (error!) {
  //           int otp = getdata["data"]["otp"];
  //           // setSnackbar(otp.toString());
  //           Fluttertoast.showToast(msg: otp.toString(),
  //               backgroundColor: colors.primary
  //           );
  //           // setSnackbar(msg!);
  //           // settingsProvider.setPrefrence(MOBILE, mobile!);
  //           // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
  //
  //           Future.delayed(Duration(seconds: 1)).then((_) {
  //             Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => VerifyOtp(
  //                       login: true,
  //                       otp: otp,
  //                       mobileNumber: mobile!,
  //                       countryCode: countrycode,
  //                       title: getTranslated(context, 'SEND_OTP_TITLE'),
  //                     )));
  //           });
  //         } else {
  //           setSnackbar(msg!);
  //         }
  //     //  }
  //     // } else {
  //       //if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
  //       //   if (!error) {
  //       //     int otp = getdata["data"]["otp"];
  //       //     Fluttertoast.showToast(msg: otp.toString(),
  //       //         backgroundColor: colors.primary
  //       //     );
  //       //     // setSnackbar(otp.toString());
  //       //     // settingsProvider.setPrefrence(MOBILE, mobile!);
  //       //     // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
  //       //     Future.delayed(Duration(seconds: 1)).then((_) {
  //       //       Navigator.pushReplacement(
  //       //           context,
  //       //           MaterialPageRoute(
  //       //               builder: (context) => VerifyOtp(
  //       //                 otp: otp,
  //       //                 mobileNumber: mobile!,
  //       //                 countryCode: countrycode,
  //       //                 title: getTranslated(context, 'FORGOT_PASS_TITLE'),
  //       //               )));
  //       //     });
  //       //   } else {
  //       //     setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!);
  //       //   }
  //      // }
  //     // }
  //   } on TimeoutException catch (_) {
  //     setSnackbar(getTranslated(context, 'somethingMSg')!);
  //     await buttonController!.reverse();
  //   }
  // }

  _subLogo() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset(
          'assets/images/homelogo.png',
        ),
      ),
    );
  }

  signInTxt() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            getTranslated(context, 'SIGNIN_LBL')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  // setMobileNo() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.85,
  //     padding: EdgeInsets.only(
  //       top: 30.0,
  //     ),
  //     child: TextFormField(
  //       maxLength: 10,
  //       onFieldSubmitted: (v) {
  //         FocusScope.of(context).requestFocus(passFocus);
  //       },
  //       keyboardType: TextInputType.number,
  //     /  controller: mobileController,
  //       style: TextStyle(
  //         color: Theme.of(context).colorScheme.fontColor,
  //         fontWeight: FontWeight.normal,
  //       ),
  //       focusNode: monoFocus,
  //       textInputAction: TextInputAction.next,
  //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       validator: (val) => validateMob(
  //           val!,
  //           getTranslated(context, 'MOB_REQUIRED'),
  //           getTranslated(context, 'VALID_MOB')),
  //       onSaved: (String? value) {
  //         mobile = value;
  //       },
  //       decoration: InputDecoration(
  //         counterText: '',
  //         prefixIcon: Icon(
  //           Icons.phone_android,
  //           color: Theme.of(context).colorScheme.fontColor,
  //           size: 20,
  //         ),
  //         hintText: "Mobile Number",
  //         hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
  //             color: Theme.of(context).colorScheme.fontColor,
  //             fontWeight: FontWeight.normal),
  //         filled: true,
  //         fillColor: Theme.of(context).colorScheme.white,
  //         contentPadding: EdgeInsets.symmetric(
  //           horizontal: 10,
  //           vertical: 5,
  //         ),
  //         focusedBorder: UnderlineInputBorder(
  //           borderSide: BorderSide(color: colors.primary),
  //           borderRadius: BorderRadius.circular(7.0),
  //         ),
  //         prefixIconConstraints: BoxConstraints(
  //           minWidth: 40,
  //           maxHeight: 20,
  //         ),
  //
  //         enabledBorder: UnderlineInputBorder(
  //           borderSide:
  //               BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
  //           borderRadius: BorderRadius.circular(7.0),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   return Container(
  //     width: deviceWidth! * 0.7,
  //     padding: EdgeInsetsDirectional.only(
  //       top: 30.0,
  //     ),
  //     child: TextFormField(
  //       onFieldSubmitted: (v) {
  //         FocusScope.of(context).requestFocus(passFocus);
  //       },
  //       keyboardType: TextInputType.number,
  //       controller: mobileController,
  //       style: TextStyle(
  //           color: Theme.of(context).colorScheme.fontColor,
  //           fontWeight: FontWeight.normal),
  //       focusNode: monoFocus,
  //       textInputAction: TextInputAction.next,
  //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       validator: (val) => validateMob(
  //           val!,
  //           getTranslated(context, 'MOB_REQUIRED'),
  //           getTranslated(context, 'VALID_MOB')),
  //       onSaved: (String? value) {
  //         mobile = value;
  //       },
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(
  //           Icons.call_outlined,
  //           color: Theme.of(context).colorScheme.fontColor,
  //           size: 17,
  //         ),
  //         hintText: getTranslated(context, 'MOBILEHINT_LBL'),
  //         hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
  //             color: Theme.of(context).colorScheme.fontColor,
  //             fontWeight: FontWeight.normal),
  //         filled: true,
  //         fillColor: Theme.of(context).colorScheme.lightWhite,
  //         contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //         prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide:
  //               BorderSide(color: Theme.of(context).colorScheme.fontColor),
  //           borderRadius: BorderRadius.circular(7.0),
  //         ),
  //         enabledBorder: UnderlineInputBorder(
  //           borderSide:
  //               BorderSide(color: Theme.of(context).colorScheme.lightWhite),
  //           borderRadius: BorderRadius.circular(7.0),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  setPass() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: passwordController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        focusNode: passFocus,
        textInputAction: TextInputAction.next,
        validator: (val) => validatePass(
            val!,
            getTranslated(context, 'PWD_REQUIRED'),
            getTranslated(context, 'PWD_LENGTH')),
        onSaved: (String? value) {
          password = value;
        },
        decoration: InputDecoration(
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
            color: Theme.of(context).colorScheme.fontColor,
          ),

          suffixIcon: InkWell(
            onTap: () {
              // SettingProvider settingsProvider =
              // Provider.of<SettingProvider>(this.context, listen: false);
              //
              // settingsProvider.setPrefrence(ID, id!);
              // settingsProvider.setPrefrence(MOBILE, mobile!);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SendOtp(
                            checkForgot : "true",
                            title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                          )));
            },
            child: Text(
              getTranslated(context, "FORGOT_LBL")!,
              style: TextStyle(
                color: colors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          hintText: getTranslated(context, "PASSHINT_LBL")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          //filled: true,
          fillColor: Theme.of(context).colorScheme.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          suffixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          // focusedBorder: OutlineInputBorder(
          //     //   borderSide: BorderSide(color: fontColor),
          //     // borderRadius: BorderRadius.circular(7.0),
          //     ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  forgetPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                SettingProvider settingsProvider =
                    Provider.of<SettingProvider>(this.context, listen: false);

                settingsProvider.setPrefrence(ID, id!);
                settingsProvider.setPrefrence(MOBILE, mobile!);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendOtp(
                              title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                            )));
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal)),
            ),
          ],
        ));
  }

  termAndPolicyTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'DONT_HAVE_AN_ACC')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                fontSize: 16
              )),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SendOtp(
                        checkForgot: "false",
                        title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ));
              },
              child: Text(
                getTranslated(context, 'SIGN_UP_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ))
        ],
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, 'SIGNIN_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: back(),
                  ),
                  Image.asset(
                    'assets/images/doodle.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  // getLoginContainer() {
  //   return Positioned.directional(
  //     start: MediaQuery.of(context).size.width * 0.025,
  //     // end: width * 0.025,
  //     // top: width * 0.45,
  //     top: MediaQuery.of(context).size.height * 0.2, //original
  //     //    bottom: height * 0.1,
  //     textDirection: Directionality.of(context),
  //     child: ClipPath(
  //       clipper: ContainerClipper(),
  //       child: Container(
  //         alignment: Alignment.center,
  //         padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
  //         height: MediaQuery.of(context).size.height * 0.7,
  //         width: MediaQuery.of(context).size.width * 0.95,
  //         color: Theme.of(context).colorScheme.white,
  //         child: Form(
  //           key: _formkey,
  //           child: ScrollConfiguration(
  //             behavior: MyBehavior(),
  //             child: SingleChildScrollView(
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   maxHeight: MediaQuery.of(context).size.height * 2,
  //                 ),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     SizedBox(
  //                       height: MediaQuery.of(context).size.height * 0.10,
  //                     ),
  //                     setSignInLabel(),
  //                     setMobileNo(),
  //                     // setPass(),
  //                     loginBtn(),
  //                     termAndPolicyTxt(),
  //                     SizedBox(
  //                       height: MediaQuery.of(context).size.height * 0.10,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, // //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.6),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            // widget.title ==
                            //     getTranslated(context, 'SEND_OTP_TITLE')
                            //     ?
                            getTranslated(context, 'LOG_IN_LBL')!,
                                // : getTranslated(
                                // context, 'FORGOT_PASSWORDTITILE')!,
                            style: const TextStyle(
                              color: colors.primary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // setMobileNo(),
                      // setPass(),
                      // loginBtn(),
                      verifyCodeTxt(),
                      setCodeWithMono(),
                      verifyBtn(),
                      termAndPolicyTxt(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget verifyBtn() {
    return AppBtn(
        // title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        //     ?
        title: getTranslated(context, 'SEND_OTP'),
            // : getTranslated(context, 'GET_PASSWORD'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        });
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          'assets/images/loginlogo.png',
        ),
      ),
    );
  }
  Widget verifyCodeTxt() {
    return Padding(
        padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            getTranslated(context, 'SEND_VERIFY_CODE_LBL')!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 1,
          ),
        ));
  }

  Widget setCodeWithMono() {
    return Container(
        width: deviceWidth! * 0.9,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: setCountryCode(),
            ),
            Expanded(
              flex: 4,
              child: setMono(),
            )
          ],
        ));
  }
  Widget setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight! * 0.9;
    return CountryCodePicker(
        showCountryOnly: false,
        searchStyle: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
        ),
        flagWidth: 20,
        boxDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
        ),
        searchDecoration: InputDecoration(
          hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          fillColor: Theme.of(context).colorScheme.fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'IN',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst("+", "");
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst("+", "");
        });
  }

  Widget setMono() {
    return TextFormField(
        maxLength: 10,
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          counterText: '',
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          // ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          ),
        ));
  }
  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: const TextStyle(
            color: colors.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
