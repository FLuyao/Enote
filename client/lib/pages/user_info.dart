import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'more_settings_page.dart';

class UserInfoPage extends StatefulWidget {
  final String token;
  final String username;

  const UserInfoPage({
    super.key,
    required this.token,
    required this.username,
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  bool _syncEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
        title: const Text(
          '我的资料',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFFFFE9BF),
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                // 用户头像部分
                _buildProfileSection(),
                // 设置项列表
                _buildSettingsList(),
              ],
            ),
          ),
          // 底部退出按钮
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://ai-public.mastergo.com/ai/img_res/f9d4bf75acdf5668fd86035de83af545.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.username,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.pen, size: 16),
            color: const Color(0xFFFFE9BF),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 云同步设置
          _buildSettingItem(
            icon: FontAwesomeIcons.cloud,
            title: '云同步',
            description: '开启后可自动同步数据到云端',
            hasSwitch: true,
            onTap: () => _showSyncHelp(),
            textColor: Colors.black, // 固定为黑色
          ),
          // 更多设置
          _buildSettingItem(
            icon: FontAwesomeIcons.gear,
            title: '更多设置',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoreSettingsPage(),
                ),
              );
            },
          ),
          // 关于我们
          _buildSettingItem(
            icon: FontAwesomeIcons.circleInfo,
            title: '关于我们',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? description,
    bool hasSwitch = false,
    VoidCallback? onTap,
    Color? textColor, // ✅ 传入 textColor 参数
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: description != null ? const Color(0xFFFFF9E6) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, size: 20, color: const Color(0xFF666666)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color, // 使用 bodyLarge
                  ),
                ),
                if (description != null)
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.circleQuestion, size: 14),
                    color: const Color(0xFFFADB7D),
                    padding: EdgeInsets.zero,
                    onPressed: onTap,
                  ),
              ],
            ),
            if (description != null)
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor ?? Colors.grey[600], // 默认使用灰色，如果没有传入 textColor
                ),
              ),
          ],
        ),
        trailing: hasSwitch
            ? Switch(
          value: _syncEnabled,
          activeColor: const Color(0xFFEFCE78),
          onChanged: (value) => setState(() => _syncEnabled = value),
        )
            : const Icon(FontAwesomeIcons.chevronRight, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFCE78),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: _logout,
        child: const Text(
          '退出登录',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showSyncHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('云同步功能说明'),
        content: const Text(
            '开启云同步后，您的数据将自动备份到云端服务器，确保数据安全。\n\n'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');

    // 跳转到个人主页（清除当前页面栈）
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
          (Route<dynamic> route) => false,
    );
  }
}
