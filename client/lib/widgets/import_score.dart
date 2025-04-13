import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';  // 用来获取临时目录等
import 'package:http/http.dart' as http;
import '../models/score_item.dart';

class ImportHandler {
  final BuildContext context;
  final void Function(ScoreItem) onMxlImported;
  final VoidCallback onImageImport;

  ImportHandler({
    required this.context,
    required this.onMxlImported,
    required this.onImageImport,
  });

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

  /// 以图像方式导入，然后先保存返回的 .mxl 到本地，再统一走“导入MXL”逻辑
  Future<void> importByImage() async {
    Navigator.pop(context);
    print('以图像方式导入曲谱');

    // 1. 让用户选取图像文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      print('没有选择文件');
      return;
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) return;

    // 2. 向后端发送 OMR 请求
    final uri = Uri.parse('http://10.0.2.2:5000/omr');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: result.files.first.name,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // 3. 把返回的 bytes 先保存到本地文件，如 temp_imported.mxl
      final mxlBytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final savedFilePath = '${dir.path}/temp_imported.mxl';
      final file = File(savedFilePath);
      await file.writeAsBytes(mxlBytes);

      print('✅ 已将后端返回的 MXL 保存到本地: $savedFilePath');

      // 4. 再用同样的 MXL 导入逻辑进行解析
      //    这样“图片导入”与“直接选择MXL”就真正统一了
      final success = await _importMxlFromLocalFile(savedFilePath, '新导入曲谱(OMR)');
      if (!success) {
        print('❌ 从本地文件导入 MXL 失败');
      }
    } else {
      print('服务端返回错误：${response.statusCode}');
    }
  }

  /// 以 MXL 文件直接导入
  Future<void> importByMXL() async {
    Navigator.pop(context);
    print('以MXL文件导入曲谱');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mxl'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      print('没有选择文件');
      return;
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) return;

    // 也可以先写到本地再读，但这里直接读内存也OK
    final xmlString = _unzipMxlToXml(fileBytes);
    if (xmlString == null) {
      print('❌ 无法从选定的 MXL 中解出 XML');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);  // ⭐ 确保目录存在
    }
    final fileName = 'score_${DateTime.now().millisecondsSinceEpoch}.mxl';
    final savedPath = '${dir.path}/$fileName';
    final file = File(savedPath);
    await file.writeAsBytes(fileBytes);
    final newItem = ScoreItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '新导入曲谱',
      image: 'https://ai-public.mastergo.com/ai/img_res/9546453bd05f12ea31d0fcd69e4a3e2b.jpg',
      mxlPath: savedPath,
    );
    onMxlImported(newItem);
  }

  /// 从本地文件读取 MXL 并解析出 XML
  Future<bool> _importMxlFromLocalFile(String filePath, String name) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ 文件不存在: \$filePath');
        return false;
      }

      final newItem = ScoreItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        image: 'https://ai-public.mastergo.com/ai/img_res/9546453bd05f12ea31d0fcd69e4a3e2b.jpg',
        mxlPath: filePath,
      );

      onMxlImported(newItem);
      return true;
    } catch (e) {
      print('❌ _importMxlFromLocalFile: \$e');
      return false;
    }
  }
  }

  /// 解压 .mxl 并读取其中的 .xml
  /// 注意最好使用 utf8.decode() 而非 String.fromCharCodes()
  String? _unzipMxlToXml(Uint8List fileBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(fileBytes);
      for (final file in archive) {
        if (file.name.endsWith('.xml')) {
          final content = file.content as List<int>;
          return utf8.decode(content);  // 避免 BOM/编码导致的缺失
        }
      }
      return null;
    } catch (e) {
      print('Error unzipping MXL: $e');
      return null;
    }
  }


class ImportDialog extends StatelessWidget {
  final VoidCallback onImportByImage;
  final VoidCallback onImportByMXL;

  const ImportDialog({
    required this.onImportByImage,
    required this.onImportByMXL,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Container(
        width: 280.0,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择导入方式', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: onImportByImage,
              child: Text('以图像方式导入曲谱'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: onImportByMXL,
              child: Text('以MXL文件导入曲谱'),
            ),
            SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
          ],
        ),
      ),
    );
  }
}
