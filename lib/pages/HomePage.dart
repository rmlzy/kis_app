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

  _renderPaper(context, index) {
    final blog = blogs[index];
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        title: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(blog['title']),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Text("${blog['createdAt']}"),
            ),
            blog['summary'] != '' ? Text("${blog['summary']}") : Container()
          ],
        ),
        trailing: Icon(Icons.arrow_right),
        onTap: () {
//          _toBlogWebViewPage(blog['title'], blog['pathname']);
          _toBlogEditorPage(blog['id']);
        },
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
              return _renderPaper(context, index);
            }),
      ),
      drawer: Padding(
        padding: EdgeInsets.only(right: 80.0),
        child: SideDrawer(),
      ),
    );
  }
}
