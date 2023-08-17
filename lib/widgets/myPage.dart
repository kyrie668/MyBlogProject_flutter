import 'dart:convert';

import 'package:blob_flutter/widgets/myButton.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constant.dart';
import '../method/localStorage.dart';
import 'myBlogList.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isLoggedIn = false;
  String username = '';
  String avatar = '';
  List blogs = [];

  // bool isLoggedIn = GetStorage().read('token').isNotEmpty;
  // String username = GetStorage().read('username');

  void logout() async {
    // 退出登录逻辑处理
    await LocalStorage.removeData('token');
    await LocalStorage.removeData('avatar');
    await LocalStorage.removeData('username');
    setState(() {
      isLoggedIn = false;
      username = '';
      avatar = '';
      blogs = [];
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 获取当前用户的信息，包括用户名、头像、token（用户id）
  void loadData() async {
    Map userData = await LocalStorage.loadUserData();
    if (userData['token'] != null && userData['token'].isNotEmpty) {
      try {
        // 发送HTTP GET请求获取数据
        var response = await http.get(
          Uri.parse('${Constants.apiUrl}:3300/api/blog'),
          headers: {
            'Content-Type': 'application/json',
            'token': userData['token']
          },
        );
        var responseData = jsonDecode(response.body);
        var msg = responseData['message'];
        if (response.statusCode == 200) {
          // 解析JSON数据
          var data = jsonDecode(response.body);
          List list = data['data'];
          setState(() {
            // 将临时列表中的数据赋值给正式数据列表
            blogs = list;
          });
        } else {
          Fluttertoast.showToast(
              msg: msg,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (e) {
        print('发生错误111：$e');
      }
    }
    setState(() {
      isLoggedIn = userData['token'] != null && userData['token'].isNotEmpty;
      username = userData['username'];
      avatar = userData['avatar'];
    });
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // 加入下边框
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(120, 167, 226, 0.15),
                    width: 3.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage(isLoggedIn
                        ? 'images/avatar/$avatar'
                        : 'images/no-login.png'),
                    // 根据实际路径设置用户头像
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    ' ${isLoggedIn ? username : '未登录'}',
                    style: const TextStyle(fontSize: 32.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('发布过的博客', style: TextStyle(fontSize: 24.0)),
            const SizedBox(height: 16.0),

            // 加入一个博客列表
            MyBlogList(blogs: blogs),
            const SizedBox(height: 150.0),
            Container(
              // 加入下边距
              margin: const EdgeInsets.only(bottom: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isLoggedIn
                      ? Center(
                          child: MyButton(
                            color: Colors.red,
                            onPressed: logout,
                            child: const Text('退出登录'),
                          ),
                        )
                      : Column(
                          children: [
                            Center(
                              child: MyButton(
                                color: Colors.blue,
                                onPressed: () {
                                  // 跳转到登录页面的逻辑处理
                                  Get.toNamed("/login");
                                },
                                child: const Text('登录'),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Center(
                              child: MyButton(
                                color: Colors.blue,
                                onPressed: () {
                                  // 跳转到注册页面的逻辑处理
                                  Get.toNamed("/register");
                                },
                                child: const Text('注册'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
