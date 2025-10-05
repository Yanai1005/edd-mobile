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
  bool _showOverlay = true;
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スキャン結果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 表示切り替えボタン
          IconButton(
            icon: Icon(_showOverlay ? Icons.list : Icons.image),
            tooltip: _showOverlay ? 'リスト表示' : 'オーバーレイ表示',
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
          ),
          // 言語切り替えボタン（オーバーレイ表示時のみ）
          if (_showOverlay)
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

          return _showOverlay 
              ? _buildOverlayView(provider)
              : _buildListView(provider);
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
        ],
      ),
    );
  }

  Widget _buildListView(MenuScanProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 撮影した画像
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            child: Image.file(
              provider.scannedImage!,
              fit: BoxFit.contain,
            ),
          ),
          
          // 警告サマリー
          if (provider.menuItems.any((item) => item.isWarning))
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
                          'アレルギー物質が検出された料理があります',
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

          // メニューアイテムリスト
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メニュー一覧',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.menuItems.map((item) => _buildMenuItem(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: item.isWarning ? 4 : 1,
      color: item.isWarning ? Colors.red.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 警告アイコン
            if (item.isWarning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '注意',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (item.isWarning) const SizedBox(height: 12),

            // 原文
            Text(
              item.originalText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // 翻訳
            Text(
              item.translatedText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // アレルギー物質
            if (item.detectedAllergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '検出されたアレルギー物質:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.detectedAllergens
                    .map((allergen) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            allergen,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
