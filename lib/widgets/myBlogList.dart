import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyBlogList extends StatelessWidget {
  final List blogs;

  const MyBlogList({super.key, required this.blogs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 220,
        child: blogs.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: blogs.length,
                itemBuilder: (BuildContext context, int index) {
                  Map blog = blogs[index];
                  return GestureDetector(
                      onTap: () {
                        // 跳转至详情页面
                        Get.toNamed("/blogDetail/${blog['_id']}");
                      },
                      child: Container(
                        // 添加边框
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: Color.fromRGBO(120, 167, 226, 0.15)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          width: 250,
                          child: Column(
                            children: [
                              Image.asset('images/${blog['category']}.png',
                                  height: 150, fit: BoxFit.cover),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                width: 250,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 200,
                                      child: Text(
                                        blog['title'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 18),
                                        // 文本居左
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                      width: 40,
                                      height: 15,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Expanded(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                blog['likes'].length.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          )),
                                          const SizedBox(width: 6),
                                          Expanded(
                                              child: Baseline(
                                                  baselineType: TextBaseline
                                                      .alphabetic, // 使用基线对齐方式
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
                                padding:
                                    const EdgeInsets.only(left: 2, right: 2),
                                width: 300,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      blog['desc'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '发布时间：${blog['createdAt'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(blog['createdAt'])).toString() : '-'} ',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              )
            : const Center(
                child: Text('暂无数据'),
              ));
  }
}
