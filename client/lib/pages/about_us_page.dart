import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
        backgroundColor: const Color(0xFFFFE9BF),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'E谱——编谱|享谱一站式工具',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '版本号：v1.0.0\n\n'
                  'E谱 是一个支持云同步的覆盖曲谱获取、编辑与管理的全流程工具链，旨在为用户提供高效、简洁的曲谱记录体验。\n\n'
                  '开发者：wrf lqy fly\n邮箱：2388720311@qq.com\n\n'
                  '感谢您的支持！',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
