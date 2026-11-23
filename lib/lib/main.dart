import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const AiAtlasApp());

class Repo {
  final int rank;
  final String name;
  final String url;
  final String description;
  final String language;
  final int stars;
  final String license;

  const Repo({
    required this.rank,
    required this.name,
    required this.url,
    required this.description,
    required this.language,
    required this.stars,
    required this.license,
  });

  factory Repo.fromJson(Map<String, dynamic> j) => Repo(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        name: j['full_name']?.toString() ?? '',
        url: j['url']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        language: j['language']?.toString() ?? '',
        stars: (j['stars'] as num?)?.toInt() ?? 0,
        license: j['license']?.toString() ?? '',
      );
}

class AiAtlasApp extends StatelessWidget {
  const AiAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Atlas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.dark,
        ),
      ),
      home: const RepoExplorerPage(),
    );
  }
}

class RepoExplorerPage extends StatefulWidget {
  const RepoExplorerPage({super.key});

  @override
  State<RepoExplorerPage> createState() => _RepoExplorerPageState();
}

class _RepoExplorerPageState extends State<RepoExplorerPage> {
  List<Repo> _all = [];
  String _query = '';
  String _language = 'All';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/repos.json');
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _all = data
            .map((e) => Repo.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load the database: $e';
        _loading = false;
      });
    }
  }

  List<String> get _languages {
    final set = <String>{};
    for (final r in _all) {
      if (r.language.isNotEmpty) set.add(r.language);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<Repo> get _filtered {
    final q = _query.trim().toLowerCase();
    return _all.where((r) {
      if (_language != 'All' && r.language != _language) return false;
      if (q.isEmpty) return true;
      return r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
    }).toList();
  }

  static String _fmtStars(int s) {
    if (s >= 1000000) return '${(s / 1000000).toStringAsFixed(2)}M';
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}k';
    return '$s';
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Atlas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _loading
                    ? 'Loading database...'
                    : '${items.length} of ${_all.length} top GitHub repositories',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name or topic...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          for (final lang in _languages)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(lang),
                                selected: _language == lang,
                                onSelected: (_) =>
                                    setState(() => _language = lang),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(child: Text('No matches.'))
                          : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final r = items[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    onTap: () => _showDetails(context, r),
                                    title: Text(
                                      r.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (r.description.isNotEmpty)
                                          Text(
                                            r.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            if (r.language.isNotEmpty)
                                              _tag(context, r.language),
                                            _tag(context,
                                                '★ ${_fmtStars(r.stars)}'),
                                            if (r.license.isNotEmpty)
                                              _tag(context, r.license),
                                          ],
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      child: Text('${r.rank}'),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  void _showDetails(BuildContext context, Repo r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('#${r.rank}  ${r.name}',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (r.description.isNotEmpty) Text(r.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (r.language.isNotEmpty) Chip(label: Text(r.language)),
                Chip(label: Text('★ ${_fmtStars(r.stars)} stars')),
                Chip(
                    label: Text(r.license.isEmpty
                        ? 'License: unknown'
                        : r.license)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open on GitHub'),
                onPressed: () async {
                  final uri = Uri.parse(r.url);
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
