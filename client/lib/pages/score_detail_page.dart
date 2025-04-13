import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/score_item.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';




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
            developer.log('❌ Web error: \${error.description}');
          },
          onPageFinished: (url) {
            developer.log('✅ 页面加载完成: \$url');
            _sendXmlToWebView();
          },
        ),
      )
      ..loadFlutterAsset('assets/web/editor.html');
  }

  Future<void> _sendXmlToWebView() async {
    final path = widget.scoreItem.mxlPath;
    if (path == null || path.isEmpty) {
      developer.log('❌ mxlPath is null or empty');
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      developer.log('❌ File not found at path: $path');
      return;
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // ✅ 打印所有 MXL 内部文件名
    for (final entry in archive) {
      developer.log('📦 MXL entry: ${entry.name}');
    }

    // ✅ 寻找第一个 .xml 文件
    String? xml;
    for (final file in archive) {
      if (file.name.endsWith('.xml')) {
        final content = file.content as List<int>;
        xml = utf8.decode(content);
        break;
      }
    }

    if (xml == null) {
      developer.log('❌ 未找到 .xml 文件');
      return;
    }

    developer.log('📤 准备发送 XML 到 WebView（预览前 300 字）:\n${xml.substring(0, xml.length > 300 ? 300 : xml.length)}');

    final escapedXml = _escapeForJS(xml);
    final jsCode = "receiveXmlFromFlutter(`$escapedXml`);";
    await _controller.runJavaScript(jsCode);
    developer.log('✅ XML 已发送至 WebView');
  }


  String _escapeForJS(String input) {
    return input
        .replaceAll("\\", "\\\\")
        .replaceAll("`", "\\`")
        .replaceAll("\$", "\\\$");
  }

  String? _unzipMxlToXml(Uint8List fileBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(fileBytes);
      for (final file in archive) {
        if (file.name.endsWith('.xml')) {
          final content = file.content as List<int>;
          return utf8.decode(content);
        }
      }
      return null;
    } catch (e) {
      developer.log('解压失败: \$e');
      return null;
    }
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
