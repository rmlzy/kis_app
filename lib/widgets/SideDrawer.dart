import 'package:flutter/material.dart';

import 'package:kis_app/pages/HomePage.dart';
import 'package:kis_app/pages/CategoryPage.dart';
import 'package:kis_app/pages/TagPage.dart';
import 'package:kis_app/widgets/Request.dart';
import 'package:kis_app/widgets/Toast.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => new _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String nickname = '';
  String avatar = '';
  String email = '';
  String level = '';

  _fetchUserInfo() async {
    try {
      final token = await Request.getCookie('token');
      final r = await Request.get("/api/v1/user-info",
          queryParameters: {'token': token});
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        nickname = res['data']['nickname'];
        avatar = res['data']['avatar'];
        email = res['data']['email'];
        level = res['data']['level'];
      });
    } catch (e) {
      print(e);
      Toast.show(context, "提示", "获取用户信息失败");
    }
  }

  _toHomePage() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new HomePage()));
  }

  _toCategoryPage() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new CategoryPage()));
  }

  _toTagPage() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new TagPage()));
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(nickname),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: avatar == '' ? null : NetworkImage(avatar),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('控制台'),
                  onTap: () {
                    _toHomePage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text('分类管理'),
                  onTap: () {
                    _toCategoryPage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_offer),
                  title: Text('标签管理'),
                  onTap: () {
                    _toTagPage();
                  },
                ),
                Divider(
                  height: 1.0,
                  color: Colors.grey,
                ),
                ListTile(
                  leading: Icon(Icons.settings_power),
                  title: Text('退出'),
                  onTap: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
