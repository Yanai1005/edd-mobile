import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_scan_provider.dart';
import '../models/menu_item.dart';
import '../widgets/translated_image_overlay.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スキャン結果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 言語切り替えボタン
          IconButton(
            icon: Icon(_showOriginal ? Icons.translate : Icons.language),
            tooltip: _showOriginal ? '日本語' : '原文',
            onPressed: () {
              setState(() {
                _showOriginal = !_showOriginal;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<MenuScanProvider>();
              provider.clearScan();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<MenuScanProvider>(
        builder: (context, provider, child) {
          if (provider.scannedImage == null) {
            return const Center(
              child: Text('画像がありません'),
            );
          }

          return _buildOverlayView(provider);
        },
      ),
    );
  }

  Widget _buildOverlayView(MenuScanProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // オーバーレイ表示のヒント
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showOriginal 
                        ? '原文を表示しています。翻訳アイコンをタップで日本語表示'
                        : '翻訳を表示しています。言語アイコンをタップで原文表示',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 警告サマリー
          if (provider.textBlocks.any((block) => block.isWarning))
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚠️ 警告',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'アレルギー物質が検出された料理があります（赤色で表示）',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // オーバーレイ画像
          Padding(
            padding: const EdgeInsets.all(16),
            child: TranslatedImageOverlay(
              imageFile: provider.scannedImage!,
              textBlocks: provider.textBlocks,
              showOriginal: _showOriginal,
            ),
          ),

          // 料理リスト
          if (provider.menuItems.isNotEmpty) ...[
            const Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        '料理一覧',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...provider.menuItems.map((item) => _buildMenuItem(item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: item.isWarning ? 3 : 1,
      color: item.isWarning ? Colors.red.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 料理名（翻訳）
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 20,
                  color: item.isWarning ? Colors.red : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.translatedText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: item.isWarning ? Colors.red.shade900 : Colors.black,
                    ),
                  ),
                ),
                if (item.isWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '注意',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // 原文（小さく表示）
            if (item.originalText != item.translatedText) ...[
              const SizedBox(height: 4),
              Text(
                item.originalText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // アレルギー物質
            if (item.detectedAllergens.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          '含まれるアレルギー物質',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.detectedAllergens
                          .map((allergen) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  allergen,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
