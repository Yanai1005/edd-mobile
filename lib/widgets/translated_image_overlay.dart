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
    // テキストが空の場合はスキップ
    if (text.trim().isEmpty) {
      return;
    }

    // パディングをさらに小さく（小さいボックスにはほぼなし）
    final padding = (box.width < 20 || box.height < 10) ? 0.5 : 1.5;
    final maxWidth = box.width - padding * 2;
    final maxHeight = box.height - padding * 2;

    // ボックスが極端に小さい場合でも描画を試みる
    if (maxWidth < 3 || maxHeight < 3) {
      return; // さすがに小さすぎる場合はスキップ
    }

    // 初期フォントサイズを計算
    double fontSize = _calculateFontSize(box);
    TextPainter? textPainter;

    // テキストがボックスに収まるまでフォントサイズを調整
    for (int i = 0; i < 20; i++) {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: isWarning ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.0, // 行間を最小に
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: _getMaxLines(box.height, fontSize),
        ellipsis: '...',
      );

      textPainter.layout(maxWidth: maxWidth);

      // テキストが収まったらループを抜ける
      if (textPainter.height <= maxHeight && textPainter.width <= maxWidth) {
        break;
      }

      // フォントサイズを縮小
      fontSize = fontSize * 0.85;
      if (fontSize < 4) {
        // 最小フォントサイズを4まで下げる
        fontSize = 4;
        break;
      }
    }

    if (textPainter == null) return;

    // 最終レイアウト
    textPainter.layout(maxWidth: maxWidth);

    // テキストを中央に配置
    double x = box.left + padding;
    double y = box.top + padding;

    // 中央寄せを計算
    if (textPainter.width < maxWidth) {
      x = box.left + padding + (maxWidth - textPainter.width) / 2;
    }
    if (textPainter.height < maxHeight) {
      y = box.top + padding + (maxHeight - textPainter.height) / 2;
    }

    // 座標が有効な範囲内にあることを確認
    x = x.clamp(box.left, box.right - 1);
    y = y.clamp(box.top, box.bottom - 1);

    // クリッピングしてはみ出しを防ぐ
    canvas.save();
    canvas.clipRect(box);
    textPainter.paint(canvas, Offset(x, y));
    canvas.restore();
  }


  int _getMaxLines(double height, double fontSize) {
    // 高さに基づいて最大行数を計算
    final lines = (height / fontSize).floor();
    return lines.clamp(1, 3);
  }

  double _calculateFontSize(Rect box) {
    // ボックスのサイズに基づいてフォントサイズを計算
    final height = box.height;
    final width = box.width;

    double size;
    if (height < 10) {
      size = 6; // 極小ボックス用
    } else if (height < 15) {
      size = 8;
    } else if (height < 20) {
      size = 10;
    } else if (height < 30) {
      size = 12;
    } else if (height < 40) {
      size = 14;
    } else if (height < 60) {
      size = 16;
    } else {
      size = 18;
    }

    // 幅が狭い場合はさらに調整
    if (width < 30) {
      size = size.clamp(5.0, 9.0);
    } else if (width < 50) {
      size = size.clamp(6.0, 11.0);
    } else if (width < 80) {
      size = size.clamp(8.0, 13.0);
    }

    return size.clamp(4.0, 20.0); // 絶対的な最小・最大値
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
