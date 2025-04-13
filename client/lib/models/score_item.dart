/// 曲谱数据模型
class ScoreItem {
  final String id;
  final String name;
  final String image;
  final String? mxlPath; // ✅ 改为保存本地 MXL 文件路径

  ScoreItem({
    required this.id,
    required this.name,
    required this.image,
    this.mxlPath,
  });
}
