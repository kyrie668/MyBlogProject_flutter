import 'dart:convert';
import 'dart:math';

import 'package:blob_flutter/method/localStorage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constant.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage({Key? key}) : super(key: key);

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final blogId = Get.parameters['id'];
  final colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange
  ];

  bool isLike = false;
  bool isAuthor = false;
  Map blogData = {};
  List commentList = [];
  String comment = '';
  // 当前登录用户头像
  String imgUrl = '';
  // 当前登录用户id
  String loginId = '';
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getBlogDetail();
    getBlogComments();
  }

  // 生成随机颜色
  Color getRandomColor() {
    Random random = Random();
    int index = random.nextInt(colorList.length);
    return colorList[index];
  }

  // 获取博客详情
  Future<void> getBlogDetail() async {
    // 发送HTTP
    var response = await http.get(
      Uri.parse('${Constants.apiUrl}:3300/api/blog/$blogId'),
    );
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 200) {
      // 解析JSON数据
      var data = jsonDecode(response.body);
      var curBlogData = data['data'];
      dynamic curLike = curBlogData['likes'];
      dynamic token = await LocalStorage.getData('token');
      dynamic avatar = await LocalStorage.getData('avatar');
      setState(() {
        imgUrl = avatar;
        loginId = token;
        blogData = curBlogData;
      });
      if (curLike.length > 0 && curLike.contains(loginId)) {
        setState(() {
          isLike = true;
        });
      }
      // 是否为作者
      if (loginId == curBlogData['authorId']['_id']) {
        setState(() {
          isAuthor = true;
        });
      }
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
  }

  // 获取评论列表
  Future<void> getBlogComments() async {
    // 发送HTTP
    var response = await http.get(
      Uri.parse('${Constants.apiUrl}:3300/api/comment/$blogId'),
    );
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 200) {
      // 解析JSON数据
      var data = jsonDecode(response.body);
      var curList = data['data'];
      setState(() {
        commentList = curList;
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
  }

  // 点赞事件
  Future<void> clickLike() async {
    if (loginId.isEmpty) {
      Fluttertoast.showToast(
          msg: '请先登录',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.toNamed('/login');
      return;
    }
    // 发送HTTP
    var response = await http.put(
      Uri.parse('${Constants.apiUrl}:3300/api/blog/$blogId/like'),
      headers: {'Content-Type': 'application/json', 'token': loginId},
    );
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 200) {
      // 更新内容
      setState(() {
        isLike = !isLike;
      });
      await getBlogDetail();
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
  }

  // 添加评论
  Future<void> commitComment() async {
    dynamic comment = _commentController.text;
    if (loginId.isEmpty) {
      Fluttertoast.showToast(
          msg: '请先登录',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.toNamed('/login');
      return;
    }
    if (comment.isEmpty) {
      Fluttertoast.showToast(
          msg: '请先输入留言',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    // 发送HTTP
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}:3300/api/comment'),
        headers: {'Content-Type': 'application/json', 'token': loginId},
        body: jsonEncode(
            {'blogId': blogId, 'authorId': loginId, 'text': comment}));
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 201) {
      // 重置评论框内容
      _commentController.text = '';
      getBlogComments();
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
  }

  // 删除评论
  Future<void> deleteComment(String id) async {
    // 发送HTTP
    var response = await http.delete(
      Uri.parse('${Constants.apiUrl}:3300/api/comment/$id'),
      headers: {'Content-Type': 'application/json', 'token': loginId},
    );
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 200) {
      // 重置评论框内容
      getBlogComments();
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
  }

  // 删除博客
  Future<void> deleteBlog() async {
    // 发送HTTP
    var response = await http.delete(
      Uri.parse('${Constants.apiUrl}:3300/api/blog/$blogId'),
      headers: {'Content-Type': 'application/json', 'token': loginId},
    );
    var responseData = jsonDecode(response.body);
    var msg = responseData['message'];
    if (response.statusCode == 200) {
      Get.offAllNamed('/');
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
  }

  // 渲染评论列表
  Widget _buildCommentList(List commentList, String loginId) {
    return commentList.isNotEmpty
        ? Container(
            // 添加边框
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(120, 167, 226, 0.15),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 600,
            child: ListView.builder(
              itemCount: commentList.length,
              itemBuilder: (context, index) {
                Map comment = commentList[index];
                return Container(
                  // 添加上下外边距
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  // 添加下边框
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromRGBO(120, 167, 226, 0.15),
                        width: 2.0,
                      ),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(comment['authorId']
                                        ['avatarUrl'] !=
                                    null &&
                                comment['authorId']['avatarUrl'].isNotEmpty
                            ? 'images/avatar/${comment['authorId']?['avatarUrl']}'
                            : 'images/no-login.png'),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  // 添加背景颜色
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    // 用随机数生成colorList中的某一个颜色
                                    color: getRandomColor(),

                                    // color: const Color.fromRGBO(45, 183, 245, 1.0),
                                  ),
                                  child: Text(
                                    '${comment['authorId']?['username'] ?? '-'} ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  comment['authorId']['createdAt'] != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              comment['authorId']['createdAt']))
                                          .toString()
                                      : '-' '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              comment['text'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // 添加一个删除按钮
                      if (loginId == comment['authorId']['_id'])
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              deleteComment(comment['_id']);
                            },
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          )
        : const Center(child: Text('评论区是一片荒地'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // 返回上一级路由时重新请求上一级路由的initState
      // body: WillPopScope(

      appBar: AppBar(
        title: const Text('博客详情'),
      ),
      body: WillPopScope(
        // 主页重新发送请求
        onWillPop: () async {
          Get.offAllNamed('/');
          return true;
        },
        child: Container(
          // 加入边框
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(120, 167, 226, 0.15),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                            'images/${blogData['category'] ?? 'loading'}.png',
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            blogData['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // 根据id判断是否为当前博客作者，添加编辑和删除按钮
                          isAuthor
                              ? Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () {
                                        Get.toNamed('/addBlobPage/$blogId');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: deleteBlog,
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('技术分类：'),
                              const SizedBox(width: 10.0),
                              Container(
                                // 背景颜色
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      const Color.fromRGBO(45, 183, 245, 1.0),
                                ),
                                child: Text(
                                  blogData['category'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                              height: 20,
                              width: 60,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          blogData['likes'] is List
                                              ? blogData['likes']
                                                  .length
                                                  .toString()
                                              : '0',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 4.0),
                                        GestureDetector(
                                          onTap: () async {
                                            await clickLike();
                                          },
                                          child: Icon(
                                            Icons.thumb_up,
                                            size: 20,
                                            color: isLike
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '内容：${blogData['desc'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Container(
                            // 背景颜色
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F5FF),
                            ),
                            child: Text(
                              blogData['authorId']?['username'] ?? '-',
                              style: const TextStyle(
                                color: Color(0xFF1D39C4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                              '发布于：${blogData['createdAt'] != null ? DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(blogData['createdAt'])).toString() : '-' ''}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0x82000000),
                              )),
                          const SizedBox(width: 10.0),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            // 展示头像
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(imgUrl.isEmpty
                                  ? 'images/no-login.png'
                                  : 'images/avatar/$imgUrl'),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: SizedBox(
                                height: 80,
                                child: TextField(
                                  controller: _commentController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: '请输入评论',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 80,
                              // 添加背景蓝色
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(45, 183, 245, 1.0),
                              ),
                              child: SizedBox(
                                height: 80,
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  color: Colors.white,
                                  onPressed: commitComment,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildCommentList(commentList, loginId),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
