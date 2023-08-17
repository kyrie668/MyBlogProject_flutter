import 'dart:ffi';

import 'package:blob_flutter/constant.dart';
import 'package:blob_flutter/widgets/blogDetailPage.dart';
import 'package:blob_flutter/widgets/myPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'method/localStorage.dart';
import 'widgets/addBlogPage.dart';
import 'widgets/auth.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyBlob Flutter App',
      initialRoute: '/',
      getPages: [
        // 发布、编辑博客页面
        GetPage(name: '/addBlobPage/:id', page: () => const AddBlogPage()),
        // 博客详情页面
        GetPage(name: '/blogDetail/:id', page: () => const BlogDetailPage()),
        // 我的页面
        GetPage(name: '/myPage', page: () => const MyPage()),
        // 登录页面
        GetPage(name: '/login', page: () => const AuthPage(type: 'login')),
        // 注册页面
        GetPage(
            name: '/register', page: () => const AuthPage(type: 'register')),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MyBlob Flutter App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _blogList = [
    // {
    //   "_id": "6486da89f06aec0c79a213c4",
    //   "title": "Angular框架",
    //   "desc": "Angular 是一个应用设计框架与开发平台，旨在创建高效而精致的单页面应用。",
    //   "category": "Angular",
    //   "authorId": "6482d0bed7f17ad5cf76eb6d",
    //   "likes": [],
    //   "createdAt": "2023-06-12T08:42:49.388Z",
    //   "updatedAt": "2023-06-12T08:42:49.388Z",
    //   "__v": 0
    // },
  ];
  // 获取token
  // Future<String?> authorId = LocalStorage.getData('token');
  // 导航栏索引
  int _selectedIndex = 0;
  // Future authorId = LocalStorage.getData('token');
  String authorId = '';

  // 在初始化状态时获取token

  @override
  void initState() {
    super.initState();
    fetchData();
    // getAuthorId();
  }

  // 获取博客列表
  Future<void> fetchData() async {
    String? authorId = await LocalStorage.getData('token');
    setState(() {
      authorId = authorId;
    });
    try {
      // 发送HTTP GET请求获取数据
      var response =
          await http.get(Uri.parse('${Constants.apiUrl}:3300/api/blog'));
      if (response.statusCode == 200) {
        // 解析JSON数据
        var data = jsonDecode(response.body);
        var list = data['data'];
        setState(() {
          // 将临时列表中的数据赋值给正式数据列表
          _blogList = list;
        });
      } else {
        print('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('发生错误：$e');
    }
  }

  // 获取token
  Future<void> getAuthorId() async {
    String? authorId = await LocalStorage.getData('token');
    setState(() {
      authorId = authorId;
    });
  }

  bool isIdExists(List likes) {
    if (likes.isNotEmpty) {
      print(likes);
      print(authorId);

      return likes.contains(authorId);
    }
    return false;
  }

  List<Container> _buildGridTitleList() {
    return List<Container>.generate(
      _blogList.length,
      (int index) => Container(
        // 添加边框
        decoration: BoxDecoration(
          border:
              Border.all(width: 2, color: Color.fromRGBO(120, 167, 226, 0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
            onTap: () {
              // 跳转至详情页面
              Get.toNamed("/blogDetail/${_blogList[index]['_id']}");
            },
            child: Column(
              children: [
                Image.asset('images/${_blogList[index]['category']}.png',
                    width: 300, height: 200, fit: BoxFit.fill),
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        child: Text(
                          _blogList[index]['title'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        width: 40,
                        height: 15,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  _blogList[index]['likes'].length.toString(),
                                  style: const TextStyle(fontSize: 14)),
                            )),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Baseline(
                                    baselineType:
                                        TextBaseline.alphabetic, // 使用基线对齐方式
                                    baseline: 0, // 调整基线位置
                                    child: Container(
                                      child: const Icon(
                                        Icons.thumb_up,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                    ))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _blogList[index]['desc'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '发布时间：${_blogList[index]['createdAt'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(_blogList[index]['createdAt'])).toString() : '-'} ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            // appBar: AppBar(title: const Text("博客列表")),
            // 添加一个底部导航栏，包括主页和我的页面
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '主页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              onTap: (index) {
                // 点击导航栏跳转到对应的页面
                setState(() {
                  // 更新选中的导航栏
                  _selectedIndex = index;
                });
              },
            ),
            // 添加一个浮动的发布按钮
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton(
                    onPressed: () async {
                      String? authorId = await LocalStorage.getData('token');
                      if (authorId == null || authorId.isEmpty) {
                        Get.toNamed("/login");
                        return;
                      }
                      Get.toNamed("/addBlobPage/add");
                    },
                    tooltip: '发布博客',
                    child: const Icon(Icons.add),
                  )
                : null,
            body: _selectedIndex == 0
                ? _blogList.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: RefreshIndicator(
                            onRefresh: fetchData,
                            child: GridView.extent(
                              maxCrossAxisExtent: 300,
                              padding: const EdgeInsets.all(10),
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                              childAspectRatio: 0.7, //宽度和高度的比例
                              children: _buildGridTitleList(),
                            )),
                      )
                    : const Center(child: Text('暂无数据'))
                : const MyPage()));
  }
}
