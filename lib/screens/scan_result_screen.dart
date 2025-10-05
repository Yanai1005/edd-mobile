import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/menu_scan_provider.dart';
import '../models/menu_item.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スキャン結果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
                  child: _buildImage(provider.scannedImage),
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
        },
      ),
    );
  }

  Widget _buildImage(dynamic image) {
    if (kIsWeb) {
      // Web版ではXFileから表示
      if (image is XFile) {
        return Image.network(
          image.path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('画像を表示できません'),
            );
          },
        );
      }
    } else {
      // モバイル版ではFileから表示
      if (image is File) {
        return Image.file(
          image,
          fit: BoxFit.contain,
        );
      }
    }
    return const Center(
      child: Text('画像を表示できません'),
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
