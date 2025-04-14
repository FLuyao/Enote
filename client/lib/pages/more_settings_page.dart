import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

class MoreSettingsPage extends StatefulWidget {
  const MoreSettingsPage({super.key});

  @override
  State<MoreSettingsPage> createState() => _MoreSettingsPageState();
}

class _MoreSettingsPageState extends State<MoreSettingsPage> {
  bool _isDarkMode = false;


  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });

    // TODO: 可接入 Provider 或其他主题管理逻辑
    // context.read<ThemeProvider>().toggleTheme(value);
  }


  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '本隐私政策仅为演示用途，可在此嵌入 WebView 页面或完整政策文本...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多设置'),
        backgroundColor: Color(0xFFFFE9BF),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('黑暗模式'),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          ListTile(
            title: const Text('隐私政策'),
            onTap: () {
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
        ],
      ),
    );
  }
}
