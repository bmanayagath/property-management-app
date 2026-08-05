import 'package:flutter/material.dart';

import '../../domain/models/villa_model.dart';

class VillaFilterChips extends StatelessWidget {
  final List<VillaModel> villas;
  final String? selectedVillaId;
  final ValueChanged<String?> onSelected;

  const VillaFilterChips({
    super.key,
    required this.villas,
    required this.selectedVillaId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeVillas = villas.where((villa) => !villa.isDeleted).toList()
      ..sort((a, b) => a.villaName.compareTo(b.villaName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Selector',
          style: TextStyle(
            color: Color(0xFF646B7A),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _VillaChip(
                label: 'All Villas',
                selected: selectedVillaId == null,
                onTap: () => onSelected(null),
              ),
              for (final villa in activeVillas)
                _VillaChip(
                  label: villa.villaName.trim().isEmpty
                      ? 'Villa'
                      : villa.villaName.trim(),
                  selected: selectedVillaId == villa.id,
                  onTap: () => onSelected(villa.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VillaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VillaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        selectedColor: const Color(0xFF161B36),
        backgroundColor: const Color(0xFFE4E7EE),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF34394B),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
