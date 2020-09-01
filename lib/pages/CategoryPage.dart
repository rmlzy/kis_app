import 'package:flutter/material.dart';

import 'package:kis_app/widgets/Request.dart';
import 'package:kis_app/widgets/Loading.dart';
import 'package:kis_app/widgets/Toast.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final nameCtrl = new TextEditingController();
  final pathnameCtrl = new TextEditingController();
  final descriptionCtrl = new TextEditingController();
  List categories = [];
  var submitting = false;
  var id = -1;

  _renderCategory(context, index) {
    final category = categories[index];
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        title: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(category['name']),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            category['description'] != ''
                ? Text("${category['description']}")
                : Container()
          ],
        ),
        trailing: PopupMenuButton(
          child: Icon(Icons.more_vert),
          onSelected: (action) {
            _onSelectCategory(context, category, action);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "EDIT",
              child: Text('编辑'),
            ),
            const PopupMenuItem(
              value: "DELETE",
              child: Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        onTap: null,
      ),
    );
  }

  _renderDrawer() {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
        child: ListView(
          children: [
            Text(
              id == -1 ? "新增分类" : '编辑分类',
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              autofocus: false,
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "*标题",
              ),
            ),
            TextField(
              autofocus: false,
              controller: pathnameCtrl,
              decoration: InputDecoration(
                labelText: "*路径",
              ),
            ),
            TextField(
              autofocus: false,
              maxLines: 4,
              controller: descriptionCtrl,
              decoration: InputDecoration(
                labelText: "描述",
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: submitting
                  ? RaisedButton(
                      child: Text("提交中..."),
                      color: Colors.blueGrey,
                      colorBrightness: Brightness.dark,
                      onPressed: null,
                    )
                  : RaisedButton(
                      color: Colors.blueGrey,
                      onPressed: () {
                        _saveCategory(context);
                      },
                      child: Text('提交', style: TextStyle(color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _fetchCategories(context) async {
    Loading.show(context);
    try {
      final r = await Request.get("/api/v1/category");
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        categories = res['data'];
      });
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    } finally {
      Loading.hide(context);
    }
  }

  _showDrawer(context) {
    setState(() {
      id = -1;
    });
    nameCtrl.text = '';
    pathnameCtrl.text = '';
    descriptionCtrl.text = '';
    _scaffoldKey.currentState.openEndDrawer();
  }

  _deleteCategory(context, id) async {
    try {
      final r = await Request.delete("/api/v1/category/${id}");
      final res = r.json();
      print(res);
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      await _fetchCategories(context);
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    }
  }

  _onSelectCategory(context, category, action) {
    if (action == 'EDIT') {
      setState(() {
        id = category['id'];
      });
      nameCtrl.text = category['name'];
      pathnameCtrl.text = category['pathname'];
      descriptionCtrl.text = category['description'];
      _scaffoldKey.currentState.openEndDrawer();
    }
    if (action == 'DELETE') {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text("删除以后无法恢复, 是否继续?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("确认", style: TextStyle(color: Colors.grey)),
                  onPressed: () async {
                    await _deleteCategory(context, category['id']);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  _saveCategory(context) async {
    if (nameCtrl.text == '') {
      Toast.show(context, "提示", "请输入名称");
      return;
    }
    if (pathnameCtrl.text == '') {
      Toast.show(context, "提示", "请输入路径");
      return;
    }
    var formData = {
      "name": nameCtrl.text,
      "pathname": pathnameCtrl.text,
      "description": descriptionCtrl.text
    };
    var headers = {"content-type": "application/json"};
    setState(() {
      submitting = true;
    });
    try {
      var r;
      if (id == -1) {
        r = await Request.post("/api/v1/category",
            headers: headers, body: formData);
      } else {
        r = await Request.put("/api/v1/category/${id}",
            headers: headers, body: formData);
      }
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text(res['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text("确认"),
                  onPressed: () async {
                    // Reload Data
                    await _fetchCategories(context);
                    // Close Dialog
                    Navigator.of(context).pop();
                    // Close Drawer
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      _fetchCategories(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("分类管理"), actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _showDrawer(context);
          },
        ),
      ]),
      body: Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _renderCategory(context, index);
            }),
      ),
      endDrawer: Padding(
        padding: EdgeInsets.only(left: 40.0),
        child: _renderDrawer(),
      ),
    );
  }
}
