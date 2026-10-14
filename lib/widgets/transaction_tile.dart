import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/category_icons.dart';
import '../core/formatters.dart';
import '../data/models.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final String timeLabel;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.item,
    required this.timeLabel,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isIncome ? AppColors.beige : AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon(item.iconKey),
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tagBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.categoryName,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.muted)),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            timeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    signedRupiah(item.amount, income: item.isIncome),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: item.isIncome ? AppColors.income : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.method,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
