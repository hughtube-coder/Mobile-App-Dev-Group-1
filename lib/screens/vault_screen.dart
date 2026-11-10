import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/vault_controller.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Pure Digital Delivery Downloads Vault & Order Receipt Ledger.
/// Stores all download links unlocked upon checkout so buyers can download
/// their Lightroom LUTs (.DNG/.CUBE), Sewing Patterns (.PDF/.DXF),
/// 3D Print (.STL) files, and RPG Campaign Maps (.ZIP) anytime.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final Set<String> _downloadingKeys = {};

  Future<void> _simulateDownload(UnlockedVaultItem item) async {
    if (_downloadingKeys.contains(item.licenseKey)) return;
    setState(() => _downloadingKeys.add(item.licenseKey));

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _downloadingKeys.remove(item.licenseKey));
    VaultController.instance.markDownloaded(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Saved ${item.product.downloadFileName} to device downloads!',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(UnlockedVaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.gold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Official Digital Receipt (₱)',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _receiptRow('License Key', item.licenseKey),
            _receiptRow('Buyer Name', item.buyerName),
            _receiptRow('Email', item.buyerEmail),
            _receiptRow('Payment Channel', item.paymentChannel),
            _receiptRow('Product', item.product.name),
            _receiptRow(
              'Variant / Format',
              '${item.selectedColor.name} • ${item.selectedSize}',
            ),
            _receiptRow('Quantity', '${item.quantity}'),
            _receiptRow('Unlocked File', item.product.downloadFileName),
            const Divider(color: Colors.white12, height: 18),
            _receiptRow(
              'Total Paid',
              CurrencyFormatter.format(item.totalPaid),
              highlight: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: highlight ? 14 : 11,
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w600,
                color: highlight ? AppColors.gold : AppColors.parchment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlocked Downloads Vault 🔓'),
      ),
      body: AnimatedBuilder(
        animation: VaultController.instance,
        builder: (context, _) {
          final items = VaultController.instance.unlockedItems;

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.stone,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldFaded),
                      ),
                      child: const Icon(
                        Icons.cloud_download_outlined,
                        size: 56,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Unlocked Downloads Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.parchment,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pure digital delivery—no shipping addresses or couriers required. '
                      'Once you complete Simple Checkout for any LUT preset, sewing pattern, '
                      '.STL file, or RPG asset, your instant download link unlocks here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.storefront,
                        color: AppColors.dungeon,
                      ),
                      label: const Text('Browse Dual Marketplace'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.dungeon,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final isDownloading =
                  _downloadingKeys.contains(item.licenseKey);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.stone,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.isDownloaded
                        ? Colors.greenAccent.withValues(alpha: 0.6)
                        : AppColors.goldFaded,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            item.product.primaryImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.folder_zip,
                                  color: AppColors.gold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                    child: Text(
                                      item.isDownloaded
                                          ? 'DOWNLOADED ✓'
                                          : 'UNLOCKED LINK 🔓',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.licenseKey,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.parchment,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.product.downloadFileName} • ${item.selectedSize}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showReceiptDialog(item),
                          icon: const Icon(Icons.receipt_long, size: 15),
                          label: const Text(
                            'Receipt',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.goldFaded),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: item.licenseKey),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Copied License Key ${item.licenseKey}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text(
                            'Copy Key',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.parchment,
                            side: const BorderSide(color: Colors.white24),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: isDownloading
                              ? null
                              : () => _simulateDownload(item),
                          icon: isDownloading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.dungeon,
                                  ),
                                )
                              : const Icon(Icons.download, size: 16),
                          label: Text(
                            isDownloading
                                ? 'Downloading...'
                                : (item.isDownloaded
                                      ? 'Download Again'
                                      : 'Download File'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: AppColors.dungeon,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
