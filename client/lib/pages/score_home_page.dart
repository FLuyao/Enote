import 'package:flutter/material.dart';
import 'score_detail_page.dart';  // 这里是你创建的 dart 文件路径
import '../widgets/import_score.dart';
import '../models/score_item.dart';

/// 首页：包含顶部导航、标签栏、曲谱列表和排序菜单
class ScoreHomePage extends StatefulWidget {
  @override
  _ScoreHomePageState createState() => _ScoreHomePageState();
}

class _ScoreHomePageState extends State<ScoreHomePage> {
  late ImportHandler importHandler;
  List<ScoreItem> scoreList = [
    ScoreItem(
      id: 1,
      name: 'Fly me to the moon',
      image: 'https://ai-public.mastergo.com/ai/img_res/9546453bd05f12ea31d0fcd69e4a3e2b.jpg',
    ),
  ];



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      importHandler = ImportHandler(
        context: context,
        onImageImport: () {
          print('以图像方式导入曲谱');
          // 这里可以实现你自己的逻辑，比如跳转或状态更新
        },
        onMxlImported: (ScoreItem item) {
          setState(() {
            scoreList.add(item);
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MxlScoreDetailPage(scoreItem: item),
            ),
          );
        },
      );
    });
  }

  // 状态变量
  String activeTab = 'shelf';
  bool showSortMenu = false;
  String currentSort = '时间排序';
  TextEditingController searchController = TextEditingController();



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
  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  // 搜索框点击：这里清空输入框，可进一步拓展为自动聚焦等逻辑
  void showSearch() {
    setState(() {
      searchController.clear();
    });
  }

  void navigateToScoreDetail(ScoreItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreDetailPage(scoreItem: item),
      ),
    );
  }

  void navigateToMxlScoreDetail(ScoreItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MxlScoreDetailPage(scoreItem: item),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF8),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.search,
                                  size: 20, color: Color(0xFF999999)),
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
                      onTap: () => importHandler.showImportDialog(),
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
                padding: EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
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
                                fontSize: activeTab == 'collection'
                                    ? 22.0
                                    : 18.0,
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
                          Text(
                            currentSort,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF666666),
                            ),
                          ),
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
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: scoreList.length,
                    itemBuilder: (context, index) {
                      final item = scoreList[index];
                      return GestureDetector(
                        onTap: () {
                          // 如果有 xml 字段，则说明是 MXL 曲谱
                          if (item.xml != null) {
                            navigateToMxlScoreDetail(item);
                          } else {
                            navigateToScoreDetail(item);
                          }
                        },
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
                                  color: Color(0xFF333333),
                                ),
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
                          child: Text(
                            '时间排序',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => selectSort('letter'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            '首字母排序',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF333333),
                            ),
                          ),
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


/// 个人主页（示例页面）
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("个人主页")),
      body: Center(child: Text("这里是个人主页内容")),
    );
  }
}