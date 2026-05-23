import 'package:flutter/material.dart';

import '../data/cities.dart';
import '../theme/app_colors.dart';

/// A search-as-you-type birth-place picker.
///
/// Shows a TextField; tapping it (or typing) opens a modal sheet
/// with a live-filtered list of cities. Selecting a city returns
/// the full [City] (with latitude/longitude) via [onSelected].
///
/// Use this everywhere a birth location is captured so that the
/// Prokerala API gets accurate coordinates while the UI shows a
/// friendly name ("Mumbai, Maharashtra, India").
class CityPicker extends StatefulWidget {
  final City? initialCity;

  /// Pre-filled display name to show when no city object is available
  /// (e.g. legacy profile that only stored a string).
  final String? initialText;

  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<City> onSelected;

  /// Optional clear callback — when provided, a small "x" appears
  /// next to the field to clear it.
  final VoidCallback? onCleared;

  const CityPicker({
    super.key,
    this.initialCity,
    this.initialText,
    this.label = 'Birth City',
    this.hint = 'Tap to search city',
    this.icon = Icons.location_city_rounded,
    required this.onSelected,
    this.onCleared,
  });

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialCity?.displayName ?? widget.initialText ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant CityPicker old) {
    super.didUpdateWidget(old);
    final next = widget.initialCity?.displayName ?? widget.initialText ?? '';
    if (next != _controller.text) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    final picked = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CitySearchSheet(),
    );
    if (picked != null) {
      setState(() => _controller.text = picked.displayName);
      widget.onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _controller.text.isNotEmpty;
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: _openPicker,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),
        suffixIcon: hasValue && widget.onCleared != null
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  setState(() => _controller.clear());
                  widget.onCleared?.call();
                },
                tooltip: 'Clear',
              )
            : const Icon(Icons.search_rounded, size: 20),
      ),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet();

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  String _query = '';
  late List<City> _results;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _results = CityDatabase.search('', limit: 30);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _query = value;
      _results = CityDatabase.search(value, limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.cardDark : Colors.white;
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.accentViolet.withOpacity(0.4)
                      : AppColors.headerViolet.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Birth city',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      hintText: 'Search Mumbai, Delhi, Goa, London…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onChanged('');
                              },
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: _results.isEmpty
                      ? _buildEmpty(theme)
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 56,
                            color: isDark
                                ? AppColors.borderDark
                                : Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final city = _results[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.accentViolet
                                    .withOpacity(0.15),
                                child: Text(
                                  city.name[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.accentViolet
                                        : AppColors.headerViolet,
                                  ),
                                ),
                              ),
                              title: Text(
                                city.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                [city.region, city.country]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                              onTap: () => Navigator.of(context).pop(city),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No cities match "$_query"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Try a major nearby city instead.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
