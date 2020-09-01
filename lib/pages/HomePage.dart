import 'package:flutter/material.dart';
import 'package:kis_app/pages/BlogEditorPage.dart';
import 'package:kis_app/pages/BlogWebViewPage.dart';
import 'package:kis_app/widgets/SideDrawer.dart';
import 'package:kis_app/widgets/Request.dart';
import 'package:kis_app/widgets/Toast.dart';
import 'package:kis_app/widgets/Loading.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List blogs = [];

  _fetchBlogs(context) async {
    Loading.show(context);
    try {
      final r = await Request.get("/api/v1/blog");
      final res = r.json();
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      setState(() {
        blogs = res['data'];
      });
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    } finally {
      Loading.hide(context);
    }
  }

  _renderDot(status) {
    var color = Colors.grey;
    if (status == 'PUBLISHED') {
      color = Colors.green;
    }
    if (status == 'TOP') {
      color = Colors.red;
    }
    if (status == 'HIDE') {
      color = Colors.blue;
    }
    return Container(
      height: 8.0,
      width: 8.0,
      margin: EdgeInsets.only(right: 8.0),
      decoration: new BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
  }

  _renderTag(type) {
    return Container(
      margin: EdgeInsets.only(left: 8.0),
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Text(
        type == 'MARKDOWN' ? 'MD' : '富文本',
        style: TextStyle(color: Colors.blueGrey),
      ),
    );
  }

  _deleteBlog(context, id) async {
    try {
      final r = await Request.delete("/api/v1/blog/${id}");
      final res = r.json();
      print(res);
      if (!res['success']) {
        Toast.show(context, "提示", res['message']);
        return;
      }
      await _fetchBlogs(context);
    } catch (e) {
      Toast.show(context, "提示", "抱歉, 服务器开小差了");
    }
  }

  _onSelectBlog(context, blog, action) {
    if (action == 'PREVIEW') {
      _toBlogWebViewPage(blog['title'], blog['pathname']);
    }
    if (action == 'EDIT') {
      _toBlogEditorPage(blog['id']);
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
                    await _deleteBlog(context, blog['id']);
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

  _renderBlog(context, index) {
    final blog = blogs[index];
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).accentColor,
          backgroundImage: blog['User']['avatar'] == ''
              ? null
              : NetworkImage(blog['User']['avatar']),
        ),
        title: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(blog['title']),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  _renderDot(blog['status']),
                  Text("${blog['createdAt']}"),
                  _renderTag(blog['type'])
                ],
              ),
            ),
            blog['summary'] != '' ? Text("${blog['summary']}") : Container()
          ],
        ),
        trailing: PopupMenuButton(
          child: Icon(Icons.more_vert),
          onSelected: (action) {
            _onSelectBlog(context, blog, action);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "PREVIEW",
              child: Text('预览'),
            ),
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

  _toBlogWebViewPage(title, pathname) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new BlogWebViewPage(
        url: "http://poppython.com/blog/${pathname}.html",
        title: title,
      );
    }));
  }

  _toBlogEditorPage(id) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new BlogEditorPage(id: id);
    }));
  }

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      _fetchBlogs(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
            child: Text('首页'),
            onTap: () {
              _fetchBlogs(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _toBlogEditorPage(-1);
              },
            ),
          ]),
      body: Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return _renderBlog(context, index);
            }),
      ),
      drawer: Padding(
        padding: EdgeInsets.only(right: 80.0),
        child: SideDrawer(),
      ),
    );
  }
}
