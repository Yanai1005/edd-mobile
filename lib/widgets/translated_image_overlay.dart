import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/text_block.dart';

/// 画像上に翻訳テキストをオーバーレイ表示するウィジェット
class TranslatedImageOverlay extends StatefulWidget {
  final File imageFile;
  final List<TextBlock> textBlocks;
  final bool showOriginal;

  const TranslatedImageOverlay({
    super.key,
    required this.imageFile,
    required this.textBlocks,
    this.showOriginal = false,
  });

  @override
  State<TranslatedImageOverlay> createState() => _TranslatedImageOverlayState();
}

class _TranslatedImageOverlayState extends State<TranslatedImageOverlay> {
  ui.Image? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(TranslatedImageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile != widget.imageFile) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    if (mounted) {
      setState(() {
        _image = frame.image;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _image!.width / _image!.height,
      child: CustomPaint(
        painter: _TextOverlayPainter(
          image: _image!,
          textBlocks: widget.textBlocks,
          showOriginal: widget.showOriginal,
        ),
        child: Container(),
      ),
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }
}

class _TextOverlayPainter extends CustomPainter {
  final ui.Image image;
  final List<TextBlock> textBlocks;
  final bool showOriginal;

  _TextOverlayPainter({
    required this.image,
    required this.textBlocks,
    required this.showOriginal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 画像を描画
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // スケール計算
    final scaleX = size.width / image.width;
    final scaleY = size.height / image.height;

    // 各テキストブロックをオーバーレイ
    for (final block in textBlocks) {
      final scaledBox = Rect.fromLTRB(
        block.boundingBox.left * scaleX,
        block.boundingBox.top * scaleY,
        block.boundingBox.right * scaleX,
        block.boundingBox.bottom * scaleY,
      );

      // 背景を描画（元のテキストを隠す）
      final bgPaint = Paint()
        ..color = block.isWarning 
            ? Colors.red.withOpacity(0.9) 
            : Colors.white.withOpacity(0.9);
      
      canvas.drawRect(scaledBox, bgPaint);

      // 枠線を描画
      final borderPaint = Paint()
        ..color = block.isWarning ? Colors.red : Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(scaledBox, borderPaint);

      // テキストを描画
      final textToShow = showOriginal ? block.text : block.translatedText;
      
      if (textToShow.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: textToShow,
            style: TextStyle(
              color: block.isWarning ? Colors.white : Colors.black,
              fontSize: _calculateFontSize(scaledBox),
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(
          maxWidth: scaledBox.width - 8,
        );

        // テキストを中央に配置
        final xCenter = scaledBox.left + (scaledBox.width - textPainter.width) / 2;
        final yCenter = scaledBox.top + (scaledBox.height - textPainter.height) / 2;

        textPainter.paint(
          canvas,
          Offset(xCenter, yCenter),
        );
      }

      // 警告アイコンを表示
      if (block.isWarning) {
        _drawWarningIcon(canvas, scaledBox);
      }
    }
  }

  double _calculateFontSize(Rect box) {
    // ボックスの高さに基づいてフォントサイズを計算
    final height = box.height;
    if (height < 20) return 8;
    if (height < 30) return 10;
    if (height < 40) return 12;
    if (height < 60) return 14;
    return 16;
  }

  void _drawWarningIcon(Canvas canvas, Rect box) {
    final iconSize = (box.height * 0.3).clamp(12.0, 24.0);
    final iconX = box.right - iconSize - 4;
    final iconY = box.top + 4;

    // 警告アイコンの背景円
    final circlePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(iconX + iconSize / 2, iconY + iconSize / 2),
      iconSize / 2,
      circlePaint,
    );

    // 感嘆符を描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.red,
          fontSize: iconSize * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        iconX + (iconSize - textPainter.width) / 2,
        iconY + (iconSize - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_TextOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
           oldDelegate.textBlocks != textBlocks ||
           oldDelegate.showOriginal != showOriginal;
  }
}
