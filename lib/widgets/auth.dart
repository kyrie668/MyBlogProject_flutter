import 'dart:convert';

import 'package:blob_flutter/widgets/myButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import '../constant.dart';
import '../method/localStorage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthPage extends StatefulWidget {
  final String type;

  const AuthPage({Key? key, required this.type}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String username = '';
  String password = '';
  String email = '';
  final box = GetStorage();

  // 登录
  Future<void> login() async {
    // 校验邮箱、密码是否为空
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
          msg: "邮箱、密码不能为空",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    try {
      // 发送HTTP
      var response =
          await http.post(Uri.parse('${Constants.apiUrl}:3300/api/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': email,
                'password': password,
              }));
      var responseData = jsonDecode(response.body);
      var msg = responseData['message'];
      if (response.statusCode == 200) {
        // 解析JSON数据
        var data = jsonDecode(response.body);
        var userData = data['data'];
        // 存入持久化数据
        await LocalStorage.saveData('token', userData['_id']);
        await LocalStorage.saveData('avatar', userData['avatarUrl']);
        await LocalStorage.saveData('username', userData['username']);
        Get.offAllNamed("/");
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
      print('发生错误：$e');
    }
  }

  // 注册
  Future<void> register() async {
    // 校验用户名、密码、邮箱是否为空
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      Fluttertoast.showToast(
          msg: "用户名、密码、邮箱不能为空",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    try {
      // 随机生成1-8的整数
      var random = Random();
      int num = random.nextInt(8) + 1;

      // 发送HTTP
      var response =
          await http.post(Uri.parse('${Constants.apiUrl}:3300/api/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': username,
                'email': email,
                'password': password,
                'avatarUrl': '$num.png'
              }));
      var responseData = jsonDecode(response.body);
      var msg = responseData['message'];
      if (response.statusCode == 201) {
        // 解析JSON数据
        var data = jsonDecode(response.body);
        var userData = data['data'];
        // 存入持久化数据
        await LocalStorage.saveData('token', userData['_id']);
        await LocalStorage.saveData('avatar', userData['avatarUrl']);
        await LocalStorage.saveData('username', userData['username']);
        Get.offAllNamed("/");
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
      print('发生错误：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('My Page'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.type == 'register'
                ? Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '用户名',
                        ),
                        onChanged: (value) {
                          setState(() {
                            username = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  )
                : Container(),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '邮箱',
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true, // 密码输入框隐藏输入内容
              decoration: const InputDecoration(
                labelText: '密码',
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            const SizedBox(height: 32.0),
            widget.type == 'login'
                ? MyButton(
                    onPressed: login,
                    child: const Text('登录'),
                  )
                : MyButton(
                    onPressed: register,
                    child: const Text('注册'),
                  ),
            const SizedBox(height: 18.0),
            MyButton(
              color: const Color.fromRGBO(120, 167, 226, 1),
              onPressed: () {
                Get.offAllNamed("/");
              },
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }
}
