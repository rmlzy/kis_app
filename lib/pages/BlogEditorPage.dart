import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'package:notus/convert.dart';
import 'package:kis_app/pages/HomePage.dart';
import 'package:kis_app/widgets/Request.dart';
import 'package:kis_app/widgets/Toast.dart';
import 'package:kis_app/widgets/Loading.dart';

class BlogEditorPage extends StatefulWidget {
  BlogEditorPage({Key key, this.id}) : super(key: key);

  final int id;

  @override
  BlogEditorPageState createState() => BlogEditorPageState();
}

class BlogEditorPageState extends State<BlogEditorPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final titleCtrl = new TextEditingController();
  final summaryCtrl = new TextEditingController();
  final pathnameCtrl = new TextEditingController();
  ZefyrController _controller;
  FocusNode _focusNode;
  List categories = [];
  List tags = [];
  List statusList = [
    {"label": "草稿", "value": "DRAFT"},
    {"label": "立即发布", "value": "PUBLISHED"},
    {"label": "置顶", "value": "TOP"},
    {"label": "隐藏", "value": "HIDE"},
  ];
  String content = '';
  String status = 'DRAFT';
  int categoryId = 0;
  List tagIds = [];
  var submitting = false;

  _fetchBlog(context) async {
    // id 为 -1 代表新增
    if (widget.id == -1) {
      return;
    }
    Loading.show(context);
    try {
      final r = await Request.get("/api/v1/blog/${widget.id}");
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        final blog = res['data'];
        content = blog['content'];
        titleCtrl.text = blog['title'];
        summaryCtrl.text = blog['summary'];
        pathnameCtrl.text = blog['pathname'];
        categoryId = blog['categoryId'];
        status = blog['status'];
        for (var item in blog['Tags']) {
          tagIds.add(item['id']);
        }

        // content 赋值到编辑器
        final delta = Delta()..insert("${content}\n");
        final document = NotusDocument.fromDelta(delta);
        _controller = ZefyrController(document);
      });
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    } finally {
      Loading.hide(context);
    }
  }

  _fetchCategories(context) async {
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
    }
  }

  _fetchTags(context) async {
    try {
      final r = await Request.get("/api/v1/tag");
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        tags = res['data'];
      });
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    }
  }

  _showDrawer(context) {
    _scaffoldKey.currentState.openEndDrawer();
  }

  _saveBlog(context) async {
    final _delta = _controller.document.toDelta();
    final _content = notusMarkdown.encode(_delta);
    if (titleCtrl.text == '') {
      Toast.show(context, "提示", "请输入标题");
      return;
    }
    if (_content == '') {
      Toast.show(context, "提示", "请输入正文");
      return;
    }
    if (categoryId == 0) {
      Toast.show(context, "提示", "请选择分类");
      return;
    }
    if (tagIds.length == 0) {
      Toast.show(context, "提示", "请选择分类");
      return;
    }
    var formData = {
      "title": titleCtrl.text,
      "content": _content,
      "summary": summaryCtrl.text,
      "pathname": pathnameCtrl.text,
      "status": status,
      "categoryId": categoryId,
      "tagIds": tagIds
    };
    var headers = {"content-type": "application/json"};
    setState(() {
      submitting = true;
    });
    try {
      var r;
      if (widget.id == -1) {
        r = await Request.post("/api/v1/blog",
            headers: headers, body: formData);
      } else {
        formData['id'] = widget.id;
        r = await Request.put("/api/v1/blog/${widget.id}",
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 跳转到首页
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new HomePage()));
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

  _renderDrawer() {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
        child: ListView(
          children: [
            Text(
              "发布",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              autofocus: false,
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: "*标题",
              ),
            ),
            TextField(
              autofocus: false,
              controller: pathnameCtrl,
              decoration: InputDecoration(
                labelText: "路径",
              ),
            ),
            TextField(
              autofocus: false,
              controller: summaryCtrl,
              decoration: InputDecoration(
                labelText: "摘要",
              ),
            ),

            // 分类
            Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "*分类 (单选):",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Wrap(
              children: categories
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: FlatButton(
                        child: Text(
                          item['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        color: categoryId == item['id']
                            ? Colors.blueGrey
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            categoryId = item['id'];
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),

            // 标签
            Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "*标签 (多选):",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Wrap(
              children: tags
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: FlatButton(
                        child: Text(
                          item['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        color: tagIds.contains(item['id'])
                            ? Colors.blueGrey
                            : Colors.grey,
                        onPressed: () {
                          setState(() {
                            if (tagIds.contains(item['id'])) {
                              tagIds.remove(item['id']);
                            } else {
                              tagIds.add(item['id']);
                            }
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),

            // 状态
            Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "*状态 (单选):",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Wrap(
              children: statusList
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: FlatButton(
                        child: Text(
                          item['label'],
                          style: TextStyle(color: Colors.white),
                        ),
                        color:
                            status == item['value'] ? Colors.blueGrey : Colors.grey,
                        onPressed: () {
                          setState(() {
                            status = item['value'];
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
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
                        _saveBlog(context);
                      },
                      child: Text('提交', style: TextStyle(color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      _fetchCategories(context);
      _fetchBlog(context);
      _fetchTags(context);
    });
    final delta = Delta()..insert("\n");
    final document = NotusDocument.fromDelta(delta);
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(titleCtrl.text),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _showDrawer(context),
            ),
          )
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          padding: EdgeInsets.all(16),
          controller: _controller,
          focusNode: _focusNode,
        ),
      ),
      endDrawer: Padding(
        padding: EdgeInsets.only(left: 40.0),
        child: _renderDrawer(),
      ),
    );
  }
}
