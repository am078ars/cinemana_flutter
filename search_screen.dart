import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../show_detail/show_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<ShowItem> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _loading = true);
      try {
        final data = await ApiService.search(q.trim());
        final items = (data['data'] as List? ?? [])
            .map((e) => ShowItem.fromJson(e))
            .toList();
        setState(() {
          _results = items;
          _loading = false;
        });
      } catch (_) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onSearch,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'ابحث عن فيلم أو مسلسل...',
            hintStyle: TextStyle(color: AppTheme.textMuted),
            border: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _results.isEmpty
              ? const Center(
                  child: Text('ابحث عن محتوى تريد مشاهدته',
                      style: TextStyle(color: AppTheme.textMuted)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) {
                    final item = _results[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ShowDetailScreen(showId: item.id)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item.style.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
