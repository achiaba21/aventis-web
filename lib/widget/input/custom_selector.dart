import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class CustomSelector<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) label;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final String hint;
  final String title;

  const CustomSelector({
    super.key,
    required this.items,
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.hint,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final s = selected;
    return GestureDetector(
      onTap: () => _showModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: s != null ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextSeed(
                s != null ? label(s) : hint,
                fontSize: 14,
                color: s != null ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: s != null ? AppColors.accent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomSelectorModal<T>(
        items: items,
        label: label,
        selected: selected,
        onChanged: onChanged,
        title: title,
      ),
    );
  }
}

class _CustomSelectorModal<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) label;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final String title;

  const _CustomSelectorModal({
    required this.items,
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.title,
  });

  @override
  State<_CustomSelectorModal<T>> createState() => _CustomSelectorModalState<T>();
}

class _CustomSelectorModalState<T> extends State<_CustomSelectorModal<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items.where((i) => widget.label(i).toLowerCase().contains(q)).toList();
    });
  }

  void _select(T? item) {
    widget.onChanged(item);
    Navigator.pop(context);
  }

  bool _isSelected(T item) {
    final s = widget.selected;
    if (s == null) return false;
    return widget.label(item) == widget.label(s);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearch(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surface)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextSeed(
              widget.title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildItem('Tous', widget.selected == null, () => _select(null));
        }
        final item = _filtered[index - 1];
        return _buildItem(widget.label(item), _isSelected(item), () => _select(item));
      },
    );
  }

  Widget _buildItem(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : null,
          border: Border(bottom: BorderSide(color: AppColors.surface, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextSeed(
                text,
                fontSize: 14,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}
