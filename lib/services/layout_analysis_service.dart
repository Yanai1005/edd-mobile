import 'dart:ui';
import '../models/text_block.dart';
import '../models/menu_item.dart';

/// メニューのレイアウトを解析して構造を理解するサービス
class LayoutAnalysisService {
  /// テキストブロックをレイアウト解析してメニューアイテムに変換
  List<MenuItem> analyzeMenuLayout({
    required List<TextBlock> textBlocks,
    required List<String> userAllergies,
  }) {
    if (textBlocks.isEmpty) return [];

    // 1. テキストブロックを上から下、左から右の順にソート
    final sortedBlocks = _sortBlocksByPosition(textBlocks);

    // 2. 料理名候補を抽出
    final menuCandidates = <MenuItem>[];

    for (int i = 0; i < sortedBlocks.length; i++) {
      final block = sortedBlocks[i];
      final text = block.text.trim();

      // 料理名として適切か判定
      if (!_isLikelyMenuItemText(text)) {
        continue;
      }

      // 近くの価格情報を探す
      String? price = _findNearbyPrice(block, sortedBlocks);

      // メニューアイテムを作成
      menuCandidates.add(MenuItem(
        originalText: block.text,
        translatedText: block.translatedText,
        detectedAllergens: block.detectedAllergens,
        isWarning: block.isWarning,
      ));
    }

    return menuCandidates;
  }

  /// テキストブロックを位置でソート（上から下、左から右）
  List<TextBlock> _sortBlocksByPosition(List<TextBlock> blocks) {
    final sorted = List<TextBlock>.from(blocks);
    sorted.sort((a, b) {
      // まず垂直位置で比較（上から下）
      final verticalDiff = a.boundingBox.top - b.boundingBox.top;
      if (verticalDiff.abs() > 20) {
        // 20px以上の差があれば、明らかに別の行
        return verticalDiff.sign.toInt();
      }
      // 同じ行とみなして、水平位置で比較（左から右）
      return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
    });
    return sorted;
  }

  /// テキストが料理名らしいか判定
  bool _isLikelyMenuItemText(String text) {
    if (text.isEmpty) return false;

    // 極端に短いテキストを除外
    if (text.length <= 2) return false;

    // 価格パターンを除外
    final pricePatterns = [
      r'\$',
      r'¥',
      r'円',
      r'￥',
      r'%',
      r'％',
      r'^\d+$',
      r'^\d+\.\d+$',
    ];

    final lowerText = text.toLowerCase();
    for (final pattern in pricePatterns) {
      if (RegExp(pattern).hasMatch(lowerText)) {
        return false;
      }
    }

    // サイズ・単位パターンを除外
    final sizePatterns = [
      r'\d+\s*g\b',
      r'\d+\s*ml\b',
      r'\d+\s*l\b',
      r'\d+\s*kg\b',
      r'\d+\s*個\b',
    ];

    for (final pattern in sizePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerText)) {
        return false;
      }
    }

    // 数字のみを除外
    if (RegExp(r'^[\d\s\.\,\-\/]+$').hasMatch(text)) {
      return false;
    }

    return true;
  }

  /// 指定されたブロックの近くにある価格情報を探す
  String? _findNearbyPrice(TextBlock block, List<TextBlock> allBlocks) {
    final blockCenter = Offset(
      block.boundingBox.left + block.boundingBox.width / 2,
      block.boundingBox.top + block.boundingBox.height / 2,
    );

    String? closestPrice;
    double closestDistance = double.infinity;

    for (final candidate in allBlocks) {
      if (candidate == block) continue;

      // 価格パターンかチェック
      if (!_isPriceText(candidate.text)) continue;

      // 距離を計算
      final candidateCenter = Offset(
        candidate.boundingBox.left + candidate.boundingBox.width / 2,
        candidate.boundingBox.top + candidate.boundingBox.height / 2,
      );

      final distance = (blockCenter - candidateCenter).distance;

      // より近い価格があれば更新
      if (distance < closestDistance && distance < 200) {
        // 200px以内のみ
        closestDistance = distance;
        closestPrice = candidate.text;
      }
    }

    return closestPrice;
  }

  /// テキストが価格情報かチェック
  bool _isPriceText(String text) {
    final pricePatterns = [
      r'\$\s*\d+',
      r'¥\s*\d+',
      r'￥\s*\d+',
      r'\d+\s*円',
      r'\d+\s*yen',
      r'\d+\s*dollar',
    ];

    final lowerText = text.toLowerCase();
    for (final pattern in pricePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerText)) {
        return true;
      }
    }

    return false;
  }

  /// テキストブロックをカテゴリーに分類
  Map<String, List<TextBlock>> categorizeByLayout(List<TextBlock> blocks) {
    final categories = <String, List<TextBlock>>{
      'header': [],
      'menuItem': [],
      'price': [],
      'description': [],
      'other': [],
    };

    for (final block in blocks) {
      final text = block.text;
      final height = block.boundingBox.height;
      final width = block.boundingBox.width;

      // サイズに基づいて分類
      if (height > 30) {
        // 大きいテキスト → ヘッダー
        categories['header']!.add(block);
      } else if (_isPriceText(text)) {
        // 価格パターン
        categories['price']!.add(block);
      } else if (text.length > 50) {
        // 長いテキスト → 説明文
        categories['description']!.add(block);
      } else if (_isLikelyMenuItemText(text)) {
        // 料理名候補
        categories['menuItem']!.add(block);
      } else {
        categories['other']!.add(block);
      }
    }

    return categories;
  }

  /// 垂直方向に近い（同じ行の）ブロックをグループ化
  List<List<TextBlock>> groupByRow(List<TextBlock> blocks) {
    if (blocks.isEmpty) return [];

    final sorted = _sortBlocksByPosition(blocks);
    final rows = <List<TextBlock>>[];
    List<TextBlock> currentRow = [sorted[0]];
    double rowTop = sorted[0].boundingBox.top;

    for (int i = 1; i < sorted.length; i++) {
      final block = sorted[i];
      final verticalDiff = (block.boundingBox.top - rowTop).abs();

      if (verticalDiff <= 20) {
        // 同じ行
        currentRow.add(block);
      } else {
        // 新しい行
        rows.add(currentRow);
        currentRow = [block];
        rowTop = block.boundingBox.top;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }
}
