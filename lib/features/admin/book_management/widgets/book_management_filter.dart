import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BookCategoryFilterItem {
  final String label;
  final int count;

  const BookCategoryFilterItem(this.label, this.count);
}

class BookManagementFilter extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTuneTap;
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelected;
  final List<BookCategoryFilterItem> categories;

  const BookManagementFilter({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onFilterTuneTap,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari judul, penulis, atau ISBN...',
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: onFilterTuneTap,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final bool isSelected = selectedCategoryIndex == index;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategorySelected(index),
                  borderRadius: BorderRadius.circular(9999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.outlineVariant.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primaryContainer.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.label,
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            isSelected ? '${cat.count}' : '(${cat.count})',
                            style: AppTypography.caption.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.outline,
                              fontSize: 10.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
