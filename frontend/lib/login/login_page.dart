import 'package:flutter/material.dart';
import 'package:week_3/login/login_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_kakao_login/flutter_kakao_login.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:week_3/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<LoadingWrapperState> _loadingWrapperKey =
      GlobalKey<LoadingWrapperState>();

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: _loadingWrapperKey,
      builder: (context, loading) {
        return Stack(
          children: [
            Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: Container(
                      width: 340.0,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 200.0),
                          _buildHeader(context),
                          SizedBox(height: 50.0),
                          _buildButtons(context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: Center(
                        child: SpinKitChasingDots(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        );
      },
    );
  }

  Widget _buildHeader(context) {
    return Text(
      "카이스트 학생\n상품 소식을 누구보다\n빠르게 접해보세요",
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      softWrap: true,
    );
  }

  Widget _buildButtons(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        // LoginButton(
        //   text: "구글과 연결하기",
        //   icon: FontAwesomeIcons.google,
        //   color: Color(0xff3488f1),
        //   onPressed: () => _loginWithGoogle(context),
        // ),
        // SizedBox(height: 10.0),
        LoginButton(
          text: "페이스북과 연결하기",
          icon: FontAwesomeIcons.facebookF,
          color: Color(0xff3a5c93),
          onPressed: () => _loginWithFacebook(context),
        ),
        SizedBox(height: 10.0),
        LoginButton(
          text: "네이버와 연결하기",
          color: Color(0xff00cf63),
          onPressed: () => _loginWithNaver(context),
        ),
        SizedBox(height: 10.0),
        LoginButton(
          text: "카카오톡과 연결하기",
          color: Color(0xffffe535),
          onPressed: () => _loginWithKakao(context),
        ),
        SizedBox(height: 30.0),
        Text(
          "SNS 로그인 후 카이스트 학생 인증을 하게 됩니다.",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  //구글로 연결
  void _loginWithGoogle(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      // final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      // GoogleSignInAccount googleUser = await googleSignIn.signIn();
      // GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // var token = googleAuth.accessToken;

      // var res = await Dio()
      //     .postUri(getUri('/api/auth/google'), data: {'access_token': token});

      // if (res.statusCode == 200) {
      //   // _id = json.decode(res.body);
      //   // _submitAnimationController.forward();
      // } else {
      //   showSnackBar(context, "로그인 실패");
      // }
    }, onError: (e) {
      log.e(e);
      showSnackBar(context, "로그인 실패");
    });
  }

  //네이버로 연결
  void _loginWithNaver(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      NaverLoginResult result = await FlutterNaverLogin.logIn();
      switch (result.status) {
        case NaverLoginStatus.loggedIn:
          var tokenResult = await FlutterNaverLogin.currentAccessToken;
          final res = await Dio().postUri(getUri('/api/auth/naver'),
              data: {'access_token': tokenResult.accessToken});
          if (res.statusCode == 200) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', res.data);
          }
          break;
        case NaverLoginStatus.cancelledByUser:
          break;
        case NaverLoginStatus.error:
          showSnackBar(context, "로그인 실패");
          break;
      }
    }, onError: (e) {
      log.e(e);
    });
  }

  //카카오로 연결
  void _loginWithKakao(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      FlutterKakaoLogin kakaoSignIn = FlutterKakaoLogin();
      final KakaoLoginResult result = await kakaoSignIn.logIn();

      switch (result.status) {
        case KakaoLoginStatus.loggedIn:
          var token = await kakaoSignIn.currentAccessToken;
          final res = await Dio().postUri(getUri('/api/auth/kakao'),
              data: {'access_token': token.token});
          if (res.statusCode == 200) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', res.data);
            log.i(res.data);
          }
          break;
        case KakaoLoginStatus.loggedOut:
          log.i("로그 아웃");
          break;
        case KakaoLoginStatus.error:
          log.e("로그인 에러" + result.errorMessage);
          showSnackBar(context, "로그인 실패");
          break;
      }
      return 1;
    });
  }

  //페이스북으로 연결
  void _loginWithFacebook(context) {
    _loadingWrapperKey.currentState.loadFuture(() async {
      var facebookLogin = FacebookLogin();

      var result = await facebookLogin.logInWithReadPermissions(['email']);

      switch (result.status) {
        case FacebookLoginStatus.error:
          print(result.errorMessage);
          print("Error");
          break;
        case FacebookLoginStatus.cancelledByUser:
          print("CancelledByUser");
          break;
        case FacebookLoginStatus.loggedIn:
          print("LoggedIn");
          var token = result.accessToken.token;
          var res = await Dio().postUri(getUri('/api/auth/facebook'),
              data: {'access_token': token});

          if (res.statusCode == 200) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', res.data);
          } else {
            showSnackBar(context, "로그인 실패");
          }
          break;
      }
    }, onError: (e) {
      log.e(e);
      showSnackBar(context, "로그인 실패");
    });
  }
}