import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'dart:typed_data';
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

  void importByImage() {
    Navigator.pop(context);
    onImageImport(); // 调用主页面传入的回调
  }

  Future<void> importByMXL() async {
    Navigator.pop(context);
    print('以MXL文件导入曲谱');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mxl'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) return;

    final xmlString = _unzipMxlToXml(fileBytes);
    if (xmlString == null) return;

    final newItem = ScoreItem(
      id: DateTime.now().millisecondsSinceEpoch,
      name: '新导入曲谱',
      image: 'https://ai-public.mastergo.com/ai/img_res/9546453bd05f12ea31d0fcd69e4a3e2b.jpg',
      xml: xmlString,
    );

    onMxlImported(newItem);
  }

  String? _unzipMxlToXml(Uint8List fileBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(fileBytes);
      for (final file in archive) {
        if (file.name.endsWith('.xml')) {
          return String.fromCharCodes(file.content as List<int>);
        }
      }
      return null;
    } catch (e) {
      print('Error unzipping MXL: $e');
      return null;
    }
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
