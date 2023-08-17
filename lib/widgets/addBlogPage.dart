import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';
import '../method/localStorage.dart';
import 'dart:convert';

enum BlogType { Flutter, React, Angular, Vue, JavaScript }

extension BlogTypeExtension on BlogType {
  String get value {
    switch (this) {
      case BlogType.Flutter:
        return 'Flutter';
      case BlogType.React:
        return 'React';
      case BlogType.Angular:
        return 'Angular';
      case BlogType.Vue:
        return 'Vue';
      case BlogType.JavaScript:
        return 'JavaScript';
    }
  }
}

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({Key? key}) : super(key: key);

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  BlogType selectedType = BlogType.Flutter;
  String title = '';
  String description = '';
  dynamic curBlogData = {};
  dynamic curBlogId = Get.parameters['id'];
  // 编辑博客时，回显博客内容
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  void _updateSelectedType(String category) {
    switch (category) {
      case 'Flutter':
        setState(() {
          selectedType = BlogType.Flutter;
        });
        break;
      case 'React':
        setState(() {
          selectedType = BlogType.React;
        });
        break;
      case 'Angular':
        setState(() {
          selectedType = BlogType.Angular;
        });
        break;
      case 'Vue':
        setState(() {
          selectedType = BlogType.Vue;
        });
        break;
      case 'JavaScript':
        setState(() {
          selectedType = BlogType.JavaScript;
        });
        break;
      default:
        // 处理未知的后端数据
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // 特殊路由字段add表示为新发布博客，否则为编辑博客
    if (curBlogId != 'add') {
      // 根据 id 获取博客内容信息，并将其赋值给相应的变量
      fetchBlogContent(curBlogId);
    } else {
      _titleController.text = title;
      _descController.text = description;
    }
  }

  // 回显博客内容
  Future<void> fetchBlogContent(String id) async {
    // 发送 HTTP 请求获取博客内容信息，并将结果保存到相应的变量中
    try {
      // 发送HTTP
      var response = await http.get(
        Uri.parse('${Constants.apiUrl}:3300/api/blog/$id'),
      );
      var responseData = jsonDecode(response.body);
      var msg = responseData['message'];

      if (response.statusCode == 200) {
        Map blogInfo = responseData['data'];
        _updateSelectedType(blogInfo['category']);
        setState(() {
          curBlogData = blogInfo;
        });
        _titleController.text = blogInfo['title'];
        _descController.text = blogInfo['desc'];
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

  // 发布博客
  void addBlog() async {
    var authorId = await LocalStorage.getData('token');
    dynamic title = _titleController.text;
    dynamic description = _descController.text;
    // 判断 title 和 description 是否为空
    if (title.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(
          msg: "博客标题和博客描述不能为空",
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
          await http.post(Uri.parse('${Constants.apiUrl}:3300/api/blog'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'title': title,
                'desc': description,
                'category': selectedType.value,
                'authorId': authorId,
              }));
      var responseData = jsonDecode(response.body);
      var msg = responseData['message'];
      if (response.statusCode == 201) {
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

  // 编辑博客
  void editBlog() async {
    // 获取当前作者token（id）
    var curAuthorId = await LocalStorage.getData('token');
    dynamic title = _titleController.text;
    dynamic description = _descController.text;
    // 判断 title 和 description 是否为空
    if (title.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(
          msg: "博客标题和博客描述不能为空",
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
      var response = await http.put(
          Uri.parse('${Constants.apiUrl}:3300/api/blog/$curBlogId'),
          headers: {
            'Content-Type': 'application/json',
            if (curAuthorId != null) 'token': curAuthorId
          },
          body: jsonEncode({
            'title': title,
            'desc': description,
            'category': selectedType.value,
            'authorId': curAuthorId,
          }));
      var responseData = jsonDecode(response.body);
      var msg = responseData['message'];
      if (response.statusCode == 200) {
        // 返回上一级路由
        Get.back();
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
      appBar: AppBar(
        title: Text(curBlogId == 'add' ? '发布博客' : '编辑博客'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Get.back();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('博客标题'),
              TextFormField(
                controller: _titleController,
                onChanged: (value) {},
                decoration: const InputDecoration(
                  hintText: '请输入博客标题',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('博客类型'),
              ListTile(
                title: const Text('Flutter'),
                leading: Radio<BlogType>(
                  value: BlogType.Flutter,
                  groupValue: selectedType,
                  onChanged: (value) {
                    // 更新选中的博客类型
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('React'),
                leading: Radio<BlogType>(
                  value: BlogType.React,
                  groupValue: selectedType,
                  onChanged: (value) {
                    // 更新选中的博客类型
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Vue'),
                leading: Radio<BlogType>(
                  value: BlogType.Vue,
                  groupValue: selectedType,
                  onChanged: (value) {
                    // 更新选中的博客类型
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Angular'),
                leading: Radio<BlogType>(
                  value: BlogType.Angular,
                  groupValue: selectedType,
                  onChanged: (value) {
                    // 更新选中的博客类型
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('JavaScript'),
                leading: Radio<BlogType>(
                  value: BlogType.JavaScript,
                  groupValue: selectedType,
                  onChanged: (value) {
                    // 更新选中的博客类型
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('博客描述'),
              TextField(
                // 填入博客描述
                // controller: TextEditingController(text: description),
                controller: _descController,
                onChanged: (value) {},
                maxLines: null, // 设置为 null 以支持多行输入
                decoration: const InputDecoration(
                  hintText: '请输入博客描述',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: curBlogId == 'add' ? addBlog : editBlog,
                  child: Text(curBlogId == 'add' ? '发布' : '保存'),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
