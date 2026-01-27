import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/project.dart';

class ProjectFilter extends StatelessWidget {
  final ProjectCategory? selectedCategory;
  final ValueChanged<ProjectCategory?> onCategoryChanged;
  
  const ProjectFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        _FilterChip(
          label: 'Tümü',
          isSelected: selectedCategory == null,
          onTap: () => onCategoryChanged(null),
          color: AppTheme.accent,
        ),
        ...ProjectCategory.values.map((category) {
          return _FilterChip(
            label: category.displayName,
            icon: category.icon,
            isSelected: selectedCategory == category,
            onTap: () => onCategoryChanged(category),
            color: _getCategoryColor(category),
          );
        }),
      ],
    );
  }
  
  Color _getCategoryColor(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.electronics:
        return AppTheme.electronics;
      case ProjectCategory.mechanical:
        return AppTheme.mechanical;
      case ProjectCategory.software:
        return AppTheme.software;
    }
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  
  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });
  
  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? widget.color.withOpacity(0.15)
                : _isHovered 
                    ? AppTheme.surfaceLight
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected 
                  ? widget.color 
                  : _isHovered
                      ? AppTheme.border
                      : AppTheme.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Text(
                  widget.icon!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: widget.isSelected 
                      ? widget.color 
                      : _isHovered
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                  fontWeight: widget.isSelected 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
