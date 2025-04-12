import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Register.dart';
import 'enter.dart';
import 'user_info.dart';
import 'privacy_policy_page.dart';
import 'more_settings_page.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// 主入口 App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: '曲谱 App',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.currentTheme,
      home:ScoreHomePage(), // ✅ 你的主页面
      routes: {
        '/main': (context) => ScoreHomePage(),
        '/user_info': (context) => const UserInfoPage(token: '', username: ''),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/more-settings': (context) => const MoreSettingsPage(),
      },
    );
  }
}

/// 曲谱数据模型
class ScoreItem {
  final int id;
  final String name;
  final String image;
  ScoreItem({required this.id, required this.name, required this.image});
}

/// 首页：包含顶部导航、标签栏、曲谱列表和排序菜单
class ScoreHomePage extends StatefulWidget {
  @override
  _ScoreHomePageState createState() => _ScoreHomePageState();
}

class _ScoreHomePageState extends State<ScoreHomePage> {
  // 状态变量
  String activeTab = 'shelf';
  bool showSortMenu = false;
  String currentSort = '时间排序';
  TextEditingController searchController = TextEditingController();

  String token = '';
  String username = '';

  // 曲谱数据（这里补充了 id 字段）
  List<ScoreItem> scoreList = [
    ScoreItem(
      id: 1,
      name: 'Fly me to the moon',
      image:
      'https://ai-public.mastergo.com/ai/img_res/9546453bd05f12ea31d0fcd69e4a3e2b.jpg',
    ),
    ScoreItem(
      id: 2,
      name: '致爱丽丝',
      image:
      'https://ai-public.mastergo.com/ai/img_res/db5e16a5ecefa2c43c4f7135eb3abc65.jpg',
    ),
    ScoreItem(
      id: 3,
      name: '风之谷',
      image:
      'https://ai-public.mastergo.com/ai/img_res/6da2074699c4879be1bd5b3dffe93849.jpg',
    ),
    ScoreItem(
      id: 4,
      name: '天空之城',
      image:
      'https://ai-public.mastergo.com/ai/img_res/2fe5247eae6dbdb40b70a20659a8ad0f.jpg',
    ),
    ScoreItem(
      id: 5,
      name: 'Beneath the mask',
      image:
      'https://ai-public.mastergo.com/ai/img_res/28f20ce91e82db6708c3ae405c5c9e52.jpg',
    ),
    ScoreItem(
      id: 6,
      name: 'Rusty Lake',
      image:
      'https://ai-public.mastergo.com/ai/img_res/81e9c7ce85de672b95f2b7c626e5ade2.jpg',
    ),
  ];

  // 切换标签
  void switchTab(String tab) {
    setState(() {
      activeTab = tab;
    });
  }

  // 切换排序菜单显示与否
  void toggleSortMenu() {
    setState(() {
      showSortMenu = !showSortMenu;
    });
  }

  // 选择排序方式
  void selectSort(String type) {
    setState(() {
      currentSort = type == 'time' ? '时间排序' : '首字母排序';
      showSortMenu = false;
    });
  }

  // 导航到个人主页（示例页面）
  void navigateToProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? username = prefs.getString('username');

    if (token != null && username != null) {
      // 已登录，跳转到用户信息页
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInfoPage(token: token,username: username)),
      );
    } else {
      // 未登录，跳转到登录页
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ProfilePage()),
      );
    }
  }



  // 搜索框点击：这里清空输入框，可进一步拓展为自动聚焦等逻辑
  void showSearch() {
    setState(() {
      searchController.clear();
    });
  }

  // 显示导入方式选择对话框
  void showImportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ImportDialog(
          onImportByImage: importByImage,
          onImportByMXL: importByMXL,
        );
      },
    );
  }

  // 以图像方式导入曲谱
  void importByImage() {
    Navigator.pop(context); // 关闭弹窗
    // 在这里处理图像导入逻辑
    print('以图像方式导入曲谱');
  }

  // 以MXL文件导入曲谱
  void importByMXL() {
    Navigator.pop(context); // 关闭弹窗
    // 在这里处理 MXL 文件导入逻辑
    print('以MXL文件导入曲谱');
  }

  // 导航到曲谱详情页面
  void navigateToScoreDetail(ScoreItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScoreDetailPage(scoreItem: item)),
    );
  }

  @override

  void initState() {
    super.initState();
    _loadUserData().then((data) {
      setState(() {
        token = data['token']!;
        username = data['username']!;
      });
    });
  }

  Future<Map<String, String>> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String username = prefs.getString('username') ?? '';
    return {'token': token, 'username': username};
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // 顶部导航栏
              Container(
                padding:
                EdgeInsets.only(left: 30.0, right: 30.0, top: 55.0),
                color: Color(0xFFFFE9BF),
                child: Row(
                  children: [
                    // 头像区域（点击跳转到个人主页）
                    GestureDetector(
                      onTap: navigateToProfile,
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFFDFDFD),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person,
                            size: 24.0, color: Color(0xFF666666)),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    // 搜索框区域
                    Expanded(
                      child: GestureDetector(
                        onTap: showSearch,
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xFFFDFDFD),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          // alignment: Alignment.center, // 也可以直接使用 alignment
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // 垂直方向居中
                            children: [
                              Icon(Icons.search, size: 20, color: Color(0xFF999999)),
                              SizedBox(width: 10),
                              Text(
                                '搜索我的曲谱',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // 添加按钮区域（点击弹出导入对话框）
                    GestureDetector(
                      onTap: showImportDialog,
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        child: Icon(Icons.add,
                            size: 24.0, color: Color(0xFF666666)),
                      ),
                    ),
                  ],
                ),
              ),
              // 分类标签栏
              Container(
                padding:
                EdgeInsets.only(left: 30.0, right: 30.0, top:15.0, bottom: 15.0),
                color: Color(0xFFFFE9BF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 标签组
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => switchTab('shelf'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '谱架',
                              style: TextStyle(
                                fontSize: activeTab == 'shelf' ? 22.0 : 18.0,
                                color: activeTab == 'shelf'
                                    ? Color(0xFF333333)
                                    : Color(0xFF999999),
                                fontWeight: activeTab == 'shelf'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40.0),
                        GestureDetector(
                          onTap: () => switchTab('collection'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '谱集',
                              style: TextStyle(
                                fontSize:
                                activeTab == 'collection' ? 22.0 : 18.0,
                                color: activeTab == 'collection'
                                    ? Color(0xFF333333)
                                    : Color(0xFF999999),
                                fontWeight: activeTab == 'collection'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 排序按钮（显示当前排序方式，并可展开排序菜单）
                    GestureDetector(
                      onTap: toggleSortMenu,
                      child: Row(
                        children: [
                          Text(currentSort,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF666666))),
                          Icon(Icons.arrow_drop_down,
                              size: 14.0, color: Color(0xFF666666)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 曲谱列表（网格布局）
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left:20, right:20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio: 0.8
                    ),
                    itemCount: scoreList.length,
                    itemBuilder: (context, index) {
                      final item = scoreList[index];
                      return GestureDetector(
                        onTap: () => navigateToScoreDetail(item),
                        child: Column(
                          children: [
                            // 曲谱封面图片
                            Container(
                              width: 110.0,
                              height: 110.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                image: DecorationImage(
                                  image: NetworkImage(item.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            // 曲谱名称（居中、单行显示省略号）
                            Container(
                              width: 110.0,
                              child: Text(
                                item.name,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFF333333)),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // 排序菜单（通过 Positioned 实现固定位置）
          if (showSortMenu)
            Positioned(
              top: 180.0,
              right: 30.0,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => selectSort('time'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('时间排序',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color(0xFF333333))),
                        ),
                      ),
                      InkWell(
                        onTap: () => selectSort('letter'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text('首字母排序',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color(0xFF333333))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 导入方式选择对话框
class ImportDialog extends StatelessWidget {
  final VoidCallback onImportByImage;
  final VoidCallback onImportByMXL;

  ImportDialog({
    required this.onImportByImage,
    required this.onImportByMXL,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Container(
        width: 280.0,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Text(
              '选择导入方式',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            // 两个导入方式按钮
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF5F5F5),
                    foregroundColor: Color(0xFF333333),
                    minimumSize: Size(double.infinity, 44.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                  ),
                  onPressed: onImportByImage,
                  child: Text('以图像方式导入曲谱',
                      style: TextStyle(fontSize: 14.0)),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF5F5F5),
                    foregroundColor: Color(0xFF333333),
                    minimumSize: Size(double.infinity, 44.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                  ),
                  onPressed: onImportByMXL,
                  child: Text('以MXL文件导入曲谱',
                      style: TextStyle(fontSize: 14.0)),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            // 取消按钮
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xFFC0C0C0),
                minimumSize: Size(double.infinity, 44.0),
                side: BorderSide(color: Color(0xFFE5E5E5), width: 2.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }
}

//个人主页
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<String?> usernameFuture;

  final Color primaryColor = Color(0xFFFFE9BF);
  final Color secondaryColor = Color(0xFF3C3C39);
  final Color backgroundColor = Colors.white;
  final Color buttonYellow = Color(0xFFFADB7D);

  @override
  void initState() {
    super.initState();
    usernameFuture = _getUsername();
  }

  Future<String?> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: Colors.black),
          onPressed: () async {
            // 清除登录信息
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('username');

            // 跳转到主页面并清空栈（防止用户返回）
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ScoreHomePage()), // 你主页面的 widget
                  (Route<dynamic> route) => false,
            );
          },
        ),

        title: Text(
          "个人主页",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: usernameFuture,
        builder: (context, snapshot) {
          final username = snapshot.data ?? '未登录';

          return SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 头像区域
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: secondaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          username.isNotEmpty ? username : '未登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    // 按钮区域
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                            fixedSize: Size(240, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                            setState(() {
                              usernameFuture = _getUsername(); // 登录回来刷新昵称
                            });
                          },
                          child: Text(
                            '登录',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: secondaryColor),
                            foregroundColor: Colors.black,
                            fixedSize: Size(240, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            '注册',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      '登录后可开启云同步功能',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
/// 页面显示头像+昵称+是否开启云同步+设置
/// 信息保存至本地sqlite数据库


/// 曲谱详情页（示例页面）
class ScoreDetailPage extends StatelessWidget {
  final ScoreItem scoreItem;
  ScoreDetailPage({required this.scoreItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(scoreItem.name)),
      body: Center(child: Text("曲谱详情：${scoreItem.name}")),
    );
  }
}




