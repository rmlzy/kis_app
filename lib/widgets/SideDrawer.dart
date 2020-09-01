import 'package:flutter/material.dart';

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
        avatar = Request.host + res['data']['avatar'];
        email = res['data']['email'];
        level = res['data']['level'];
      });
    } catch (e) {
      print(e);
      Toast.show(context, "提示", "获取用户信息失败");
    }
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
                  leading: Icon(Icons.attach_file),
                  title: Text('首页'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text('分类'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.tag_faces),
                  title: Text('标签'),
                  onTap: () {},
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
