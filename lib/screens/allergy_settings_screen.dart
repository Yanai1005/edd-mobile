import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_scan_provider.dart';
import '../services/allergy_service.dart';

class AllergySettingsScreen extends StatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  State<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends State<AllergySettingsScreen> {
  final List<String> _selectedAllergies = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<MenuScanProvider>();
    _selectedAllergies.addAll(provider.userAllergies);
  }

  @override
  Widget build(BuildContext context) {
    final allergies = AllergyService.getAllergies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('アレルギー設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () async {
              final provider = context.read<MenuScanProvider>();
              await provider.updateUserAllergies(_selectedAllergies);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('アレルギー情報を保存しました'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'あなたのアレルギー情報を選択してください',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '選択した項目がメニューに含まれている場合、警告が表示されます',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                final allergy = allergies[index];
                final isSelected = _selectedAllergies.contains(allergy.name);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    title: Text(
                      allergy.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(allergy.nameEn),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: allergy.keywords
                              .take(5)
                              .map((keyword) => Chip(
                                    label: Text(
                                      keyword,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    value: isSelected,
                    activeColor: Colors.red,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedAllergies.add(allergy.name);
                        } else {
                          _selectedAllergies.remove(allergy.name);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (_selectedAllergies.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '選択中: ${_selectedAllergies.length}件',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _selectedAllergies
                        .map((allergy) => Chip(
                              label: Text(allergy),
                              backgroundColor: Colors.red.shade100,
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedAllergies.remove(allergy);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
