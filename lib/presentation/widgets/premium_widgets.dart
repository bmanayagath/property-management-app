import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'currency_amount_text.dart';

class PremiumTokens {
  PremiumTokens._();

  static const background = Color(0xFFF7F8FC);
  static const card = Colors.white;
  static const ink = Color(0xFF171A24);
  static const muted = Color(0xFF697085);
  static const line = Color(0xFFE9ECF4);
  static const glowLavender = Color(0xFFEAE6FF);
  static const glowMint = Color(0xFFE7F8F1);
  static const glowPeach = Color(0xFFFFEFE5);
  static const radius = 22.0;
  static const pagePadding = EdgeInsets.fromLTRB(18, 14, 18, 140);

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF64708A).withValues(alpha: 0.10),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
}

class PremiumScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool extendBody;

  const PremiumScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      backgroundColor: PremiumTokens.background,
      appBar: appBar,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}

class PremiumPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  const PremiumPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.padding = PremiumTokens.pagePadding,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: padding,
      children: [
        PremiumPageHeader(
          title: title,
          subtitle: subtitle,
          actions: actions,
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

class PremiumPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const PremiumPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: PremiumTokens.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.06,
                    ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PremiumTokens.muted,
                        height: 1.35,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: actions,
          ),
        ],
      ],
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = PremiumTokens.card,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PremiumTokens.radius),
        border: Border.all(color: PremiumTokens.line),
        boxShadow: PremiumTokens.softShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumTokens.radius),
        child: content,
      ),
    );
  }
}

class SoftStatCard extends StatelessWidget {
  final String title;
  final String? value;
  final num? amount;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const SoftStatCard({
    super.key,
    required this.title,
    this.value,
    this.amount,
    required this.icon,
    this.color = AppColors.primary,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: amount != null
                ? CurrencyAmountText(
                    amount: amount!,
                    amountColor: PremiumTokens.ink,
                    amountFontSize: 22,
                    currencyFontSize: 11,
                  )
                : Text(
                    value ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: PremiumTokens.ink,
                        ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PremiumTokens.muted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PremiumTokens.muted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final String value;
  final VoidCallback? onClear;

  const PremiumSearchBar({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.value = '',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}

class PremiumFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const PremiumFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class PremiumDropdown<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const PremiumDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(labelText: labelText),
      borderRadius: BorderRadius.circular(18),
    );
  }
}

class PremiumButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final bool filled;

  const PremiumButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check_rounded),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.check_rounded),
      label: Text(label),
    );
  }
}

class ModuleActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool fullWidth;
  final bool isLoading;

  const ModuleActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.fullWidth = false,
    this.isLoading = false,
  });

  const ModuleActionButton.income({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    required this.label,
    this.fullWidth = false,
    this.isLoading = false,
  }) : color = AppColors.income;

  const ModuleActionButton.expense({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    required this.label,
    this.fullWidth = false,
    this.isLoading = false,
  }) : color = AppColors.expense;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, color: Colors.white, size: 19),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withValues(alpha: 0.48),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        minimumSize: Size(fullWidth ? double.infinity : 0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
        elevation: 0,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: onPressed == null ? 0 : 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child:
          fullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class ModuleActionFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final String heroTag;
  final IconData icon;
  final String label;
  final Color color;

  const ModuleActionFab({
    super.key,
    required this.onPressed,
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.color,
  });

  const ModuleActionFab.income({
    super.key,
    required this.onPressed,
    required this.heroTag,
    this.icon = Icons.add_rounded,
    this.label = 'Add Income',
  }) : color = AppColors.income;

  const ModuleActionFab.expense({
    super.key,
    required this.onPressed,
    required this.heroTag,
    this.icon = Icons.add_rounded,
    this.label = 'Add Expense',
  }) : color = AppColors.expense;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class RoundedActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final Color color;
  final bool filled;
  final String? tooltip;

  const RoundedActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.color = AppColors.primary,
    this.filled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final content = label == null
        ? Icon(icon, size: 20)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 7),
              Text(label!),
            ],
          );
    final button = Material(
      color: filled ? color : color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 42,
          constraints: BoxConstraints(
            minWidth: label == null ? 42 : 0,
          ),
          padding: label == null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
            child: IconTheme(
              data: IconThemeData(color: filled ? Colors.white : color),
              child: content,
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<FloatingBottomNavItem> items;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding > 0 ? 8 : 12),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(31),
          border: Border.all(color: PremiumTokens.line),
          boxShadow: PremiumTokens.softShadow,
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.22)
                          : Colors.transparent,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 25,
                          color: isSelected
                              ? AppColors.primary
                              : PremiumTokens.muted,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : PremiumTokens.muted,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class FloatingBottomNavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const FloatingBottomNavItem({
    required this.activeIcon,
    required this.icon,
    required this.label,
  });
}

class GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: PremiumTokens.line,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clamped,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: PremiumTokens.glowLavender,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTokens.muted,
                ),
          ),
        ],
      ),
    );
  }
}
