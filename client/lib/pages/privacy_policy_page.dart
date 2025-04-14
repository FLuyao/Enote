import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策'),backgroundColor: Color(0xFFFFE9BF),
      foregroundColor: Colors.black,
      elevation: 1),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '''
隐私政策示例：

我们非常重视您的隐私保护。本政策旨在帮助您了解我们如何收集、使用和保护您的个人信息。
1. 信息收集
我们会在您注册账户、使用服务时收集您提供的信息，包括但不限于用户名、邮箱、登录时间等。

2. 信息使用
我们收集的信息仅用于提升服务质量、改善用户体验以及发送重要通知。

3. 信息保护
我们采用业界通行的安全技术手段，保障您的信息不被非法获取、篡改或泄露。

4. 权利说明
您有权访问、更正或删除自己的信息，并有权拒绝我们对某些信息的收集。

请您务必阅读完整政策内容，并点击下方按钮确认。
                ''',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ElevatedButton(

              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFCE78)),
              child: const Text('我已阅读并同意',style: TextStyle(
    color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
