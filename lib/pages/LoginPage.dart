import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kis_app/pages/HomePage.dart';
import 'package:kis_app/widgets/Request.dart';
import 'package:kis_app/widgets/Toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCtrl = new TextEditingController();
  TextEditingController pwdCtrl = new TextEditingController();
  TextEditingController captchaCtrl = new TextEditingController();

  var _submitting = false;
  var _captchaSvg;

  void _toHomePage() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new HomePage()));
  }

  _fetchCaptcha() async {
    try {
      final r = await Request.get("/api/v1/captcha");
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        _captchaSvg = SvgPicture.string(res['data']);
      });
    } catch (e) {
      Toast.show(context, "提示", e['message']);
    }
  }

  _login() async {
    if (emailCtrl.text == '') {
      Toast.show(context, "提示", "请输入邮箱");
      return;
    }
    if (pwdCtrl.text == '') {
      Toast.show(context, "提示", "请输入密码");
      return;
    }
    if (captchaCtrl.text == '') {
      Toast.show(context, "提示", "请输入验证码");
      return;
    }
    setState(() {
      _submitting = true;
    });
    await Future.delayed(Duration(seconds: 2));
    try {
      final headers = {"content-type": "application/json"};
      final body = {
        'email': emailCtrl.text,
        'password': pwdCtrl.text,
        'captcha': captchaCtrl.text
      };
      final r = await Request.post("/api/v1/login", headers: headers, body: body);
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        await _fetchCaptcha();
        return;
      }
      await Request.setCookie("token", res['data']);
      _toHomePage();
    } catch (e) {
      Toast.show(context, "提示", "登录失败");
      await _fetchCaptcha();
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录 KIS"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                  labelText: "邮箱",
                  hintText: "请输入邮箱",
                  prefixIcon: Icon(Icons.email)),
            ),
            TextField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock)),
            ),
            Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: captchaCtrl,
                    decoration: InputDecoration(
                        labelText: "验证码",
                        hintText: "请输入验证码",
                        prefixIcon: Icon(Icons.phone)),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () async {
                        _fetchCaptcha();
                      },
                      child: Container(
                        child: _captchaSvg,
                      ),
                    ))
              ],
            ),
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 40),
                child: ButtonTheme(
                  height: 50.0,
                  child: _submitting
                      ? RaisedButton(
                          child: Text("登录中..."),
                          color: Colors.teal,
                          colorBrightness: Brightness.dark,
                          onPressed: null,
                        )
                      : RaisedButton(
                          child: Text("登录"),
                          color: Colors.teal,
                          colorBrightness: Brightness.dark,
                          onPressed: () async {
                            _login();
                          },
                        ),
                ))
          ],
        ),
      ),
    );
  }
}
