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
            ? Colors.red.withValues(alpha: 0.9) 
            : Colors.white.withValues(alpha: 0.9);
      
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
        _drawText(canvas, textToShow, scaledBox, block.isWarning);
      }

      // 警告アイコンを表示
      if (block.isWarning) {
        _drawWarningIcon(canvas, scaledBox);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Rect box, bool isWarning) {
    // テキストが空の場合はデバッグ表示
    if (text.trim().isEmpty) {
      _drawDebugMarker(canvas, box, '空');
      return;
    }

    // パディング
    const padding = 4.0;
    final maxWidth = box.width - padding * 2;
    final maxHeight = box.height - padding * 2;

    if (maxWidth <= 0 || maxHeight <= 0) {
      _drawDebugMarker(canvas, box, '小');
      return;
    }

    // 初期フォントサイズを計算
    double fontSize = _calculateFontSize(box);
    TextPainter? textPainter;

    // テキストがボックスに収まるまでフォントサイズを調整
    for (int i = 0; i < 10; i++) {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: isWarning ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: _getMaxLines(box.height, fontSize),
        ellipsis: '...',
      );

      textPainter.layout(maxWidth: maxWidth);

      // テキストが収まったらループを抜ける
      if (textPainter.height <= maxHeight) {
        break;
      }

      // フォントサイズを縮小
      fontSize = fontSize * 0.9;
      if (fontSize < 8) {  // 最小フォントサイズを8に
        fontSize = 8;
        break;
      }
    }

    if (textPainter == null) return;

    // 最終レイアウト
    textPainter.layout(maxWidth: maxWidth);

    // テキストを中央に配置
    final x = box.left + padding + (maxWidth - textPainter.width) / 2;
    final y = box.top + padding + (maxHeight - textPainter.height) / 2;

    // 安全に座標をクランプ
    final safeX = x.clamp(box.left, (box.right - textPainter.width).clamp(box.left, box.right));
    final safeY = y.clamp(box.top, (box.bottom - textPainter.height).clamp(box.top, box.bottom));

    // クリッピングしてはみ出しを防ぐ
    canvas.save();
    canvas.clipRect(box);
    textPainter.paint(canvas, Offset(safeX, safeY));
    canvas.restore();
  }

  void _drawDebugMarker(Canvas canvas, Rect box, String marker) {
    // デバッグ用マーカーを描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: marker,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final x = box.left + (box.width - textPainter.width) / 2;
    final y = box.top + (box.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  int _getMaxLines(double height, double fontSize) {
    // 高さに基づいて最大行数を計算
    final lines = (height / (fontSize * 1.1)).floor();
    return lines.clamp(1, 3);
  }

  double _calculateFontSize(Rect box) {
    // ボックスのサイズに基づいてフォントサイズを計算
    final height = box.height;
    final width = box.width;
    
    double size;
    if (height < 20) {
      size = 10;  // 最小サイズを上げる
    } else if (height < 30) {
      size = 12;
    } else if (height < 40) {
      size = 14;
    } else if (height < 60) {
      size = 16;
    } else {
      size = 18;
    }

    // 幅が狭い場合は調整
    if (width < 60) {
      size = size.clamp(9.0, 12.0);
    } else if (width < 100) {
      size = size.clamp(10.0, 14.0);
    }

    return size;
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
