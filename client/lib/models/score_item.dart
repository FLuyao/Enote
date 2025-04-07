/// 曲谱数据模型
class ScoreItem {
  final int id;
  final String name;
  final String image;
  final String? xml;

  ScoreItem({
    required this.id,
    required this.name,
    required this.image,
    this.xml,
  });
}