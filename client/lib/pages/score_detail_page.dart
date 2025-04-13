import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/score_item.dart';


/// 普通曲谱详情页
class ScoreDetailPage extends StatelessWidget {
  final ScoreItem scoreItem;
  ScoreDetailPage({required this.scoreItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scoreItem.name),
      ),
      body: Center(
        child: Text("普通曲谱详情：${scoreItem.name}"),
      ),
    );
  }
}

/// MXL 曲谱详情页：使用 Flat 编辑器（代替 OSMD）
class MxlScoreDetailPage extends StatefulWidget {
  final ScoreItem scoreItem;
  MxlScoreDetailPage({required this.scoreItem});

  @override
  _MxlScoreDetailPageState createState() => _MxlScoreDetailPageState();
}

class _MxlScoreDetailPageState extends State<MxlScoreDetailPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            developer.log('❌ Web error: ${error.description}');
          },
          onPageFinished: (url) {
            developer.log('✅ 页面加载完成: $url');
            _sendXmlToWebView();
          },
        ),
      )
      ..loadFlutterAsset('assets/web/editor.html');
  }

  Future<void> _sendXmlToWebView() async {
    final xml = widget.scoreItem.xml;
    if (xml == null || xml.isEmpty) return;

    final escapedXml = _escapeForJS(xml);
    final jsCode = "receiveXmlFromFlutter(`$escapedXml`);";
    developer.log("⚡ 发送 XML 到 WebView");
    await _controller.runJavaScript(jsCode);
  }

  String _escapeForJS(String input) {
    return input
        .replaceAll("\\", "\\\\")
        .replaceAll("`", "\\`")
        .replaceAll("\$", "\\\$");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.scoreItem.name)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
