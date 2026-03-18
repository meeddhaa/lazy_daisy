import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _notes = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps_rounded, 'color': Color(0xFF7C6FF7)},
    {'label': 'Personal', 'icon': Icons.person_rounded, 'color': Color(0xFFFF7BAC)},
    {'label': 'Work', 'icon': Icons.work_rounded, 'color': Color(0xFF4FC3A1)},
    {'label': 'Study', 'icon': Icons.school_rounded, 'color': Color(0xFFFFB347)},
    {'label': 'Ideas', 'icon': Icons.lightbulb_rounded, 'color': Color(0xFF64B5F6)},
  ];

  static const List<List<Color>> _cardPalettes = [
    [Color(0xFF1A1040), Color(0xFF2D1B69)],
    [Color(0xFF0D1F3C), Color(0xFF1A3A5C)],
    [Color(0xFF1A0A2E), Color(0xFF2E1050)],
    [Color(0xFF0A1F1A), Color(0xFF0D3028)],
    [Color(0xFF1F0A0A), Color(0xFF3C1414)],
    [Color(0xFF1A1800), Color(0xFF332E00)],
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('notes_v2');
    if (json != null) {
      final List decoded = jsonDecode(json);
      setState(() {
        _notes = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_v2', jsonEncode(_notes));
  }

  List<Map<String, dynamic>> get _filteredNotes {
    List<Map<String, dynamic>> result = _notes;
    if (_selectedCategory != 'All') {
      result = result.where((n) => n['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((n) {
        final title = (n['title'] ?? '').toLowerCase();
        final content = (n['content'] ?? '').toLowerCase();
        return title.contains(_searchQuery) || content.contains(_searchQuery);
      }).toList();
    }
    return result;
  }

  void _showNoteEditor({int? index}) {
    final isEditing = index != null;
    final note = isEditing ? _notes[index] : null;
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController = TextEditingController(text: note?['content'] ?? '');
    String selectedCategory = note?['category'] ?? 'Personal';

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => _NoteEditorPage(
          titleController: titleController,
          contentController: contentController,
          selectedCategory: selectedCategory,
          categories: _categories,
          onSave: (title, content, category) {
            if (title.trim().isEmpty) return;
            setState(() {
              final entry = {
                'title': title.trim(),
                'content': content.trim(),
                'category': category,
                'date': isEditing ? note!['date'] : DateTime.now().toIso8601String(),
                'editedDate': DateTime.now().toIso8601String(),
                'pinned': isEditing ? (note!['pinned'] ?? false) : false,
              };
              if (isEditing) {
                _notes[index] = entry;
              } else {
                _notes.insert(0, entry);
              }
              _sortNotes();
            });
            _saveNotes();
          },
        ),
        transitionsBuilder: (context, anim, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  void _sortNotes() {
    _notes.sort((a, b) {
      if ((a['pinned'] ?? false) && !(b['pinned'] ?? false)) return -1;
      if (!(a['pinned'] ?? false) && (b['pinned'] ?? false)) return 1;
      return DateTime.parse(b['editedDate'] ?? b['date'])
          .compareTo(DateTime.parse(a['editedDate'] ?? a['date']));
    });
  }

  void _togglePin(int index) {
    setState(() {
      _notes[index]['pinned'] = !(_notes[index]['pinned'] ?? false);
      _sortNotes();
    });
    _saveNotes();
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This note will be permanently deleted.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _notes.removeAt(index));
              _saveNotes();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Map<String, dynamic> _getCategoryInfo(String cat) {
    return _categories.firstWhere(
      (c) => c['label'] == cat,
      orElse: () => _categories[1],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;
    final pinnedNotes = notes.where((n) => n['pinned'] == true).toList();
    final otherNotes = notes.where((n) => n['pinned'] != true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0914),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _isSearching
                            ? Container(
                                key: const ValueKey('search'),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF7C6FF7).withOpacity(0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        autofocus: true,
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        decoration: InputDecoration(
                                          hintText: 'Search notes...',
                                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _isSearching = false);
                                      },
                                      child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                key: const ValueKey('title'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'My Notes',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    '${_notes.length} note${_notes.length != 1 ? 's' : ''}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!_isSearching)
                      GestureDetector(
                        onTap: () => setState(() => _isSearching = true),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.6), size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat['label'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['label']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (cat['color'] as Color).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? cat['color'] as Color
                                : Colors.white.withOpacity(0.08),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 14,
                              color: isSelected ? cat['color'] as Color : Colors.white38,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                color: isSelected ? cat['color'] as Color : Colors.white38,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Empty state
            if (notes.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12101E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.sticky_note_2_outlined,
                        size: 48,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty ? 'No notes found' : 'Nothing here yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isNotEmpty ? 'Try a different search' : 'Tap + to write your first note',
                        style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

            // Pinned section
            if (pinnedNotes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 6),
                      Text(
                        'PINNED',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildNoteCard(pinnedNotes[index], _notes.indexOf(pinnedNotes[index])),
                  childCount: pinnedNotes.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Text(
                    'ALL NOTES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],

            // Other notes
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNoteCard(otherNotes[index], _notes.indexOf(otherNotes[index])),
                childCount: otherNotes.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteEditor(),
        backgroundColor: const Color(0xFF7C6FF7),
        elevation: 8,
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
        label: const Text('New Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, int originalIndex) {
    final paletteIndex = originalIndex % _cardPalettes.length;
    final palette = _cardPalettes[paletteIndex];
    final catInfo = _getCategoryInfo(note['category'] ?? 'Personal');
    final isPinned = note['pinned'] ?? false;

    return GestureDetector(
      onTap: () => _showNoteEditor(index: originalIndex),
      onLongPress: () => _showNoteOptions(originalIndex),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: palette,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (catInfo['color'] as Color).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: palette[1].withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (catInfo['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(catInfo['icon'], size: 10, color: catInfo['color']),
                      const SizedBox(width: 4),
                      Text(
                        note['category'] ?? 'Personal',
                        style: TextStyle(
                          color: catInfo['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.push_pin_rounded, size: 14, color: Colors.white54),
                  ),
                Text(
                  _formatDate(note['editedDate'] ?? note['date']),
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note['title'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (note['content'] != null && (note['content'] as String).isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note['content'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNoteOptions(int index) {
    final note = _notes[index];
    final isPinned = note['pinned'] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1B2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit_rounded,
              label: 'Edit Note',
              color: const Color(0xFF7C6FF7),
              onTap: () { Navigator.pop(context); _showNoteEditor(index: index); },
            ),
            _OptionTile(
              icon: isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              label: isPinned ? 'Unpin' : 'Pin to Top',
              color: const Color(0xFFFFB347),
              onTap: () { Navigator.pop(context); _togglePin(index); },
            ),
            _OptionTile(
              icon: Icons.delete_rounded,
              label: 'Delete',
              color: const Color(0xFFFF4757),
              onTap: () { Navigator.pop(context); _deleteNote(index); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// Full-screen note editor
class _NoteEditorPage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final String selectedCategory;
  final List<Map<String, dynamic>> categories;
  final Function(String, String, String) onSave;

  const _NoteEditorPage({
    required this.titleController,
    required this.contentController,
    required this.selectedCategory,
    required this.categories,
    required this.onSave,
  });

  @override
  State<_NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<_NoteEditorPage> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final catInfo = widget.categories.firstWhere(
      (c) => c['label'] == _selectedCategory,
      orElse: () => widget.categories[1],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0914),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0914),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
          ),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.categories.skip(1).map((cat) {
              final isSelected = _selectedCategory == cat['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (cat['color'] as Color).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? cat['color'] as Color : Colors.white12,
                    ),
                  ),
                  child: Text(
                    cat['label'],
                    style: TextStyle(
                      color: isSelected ? cat['color'] as Color : Colors.white38,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              widget.onSave(
                widget.titleController.text,
                widget.contentController.text,
                _selectedCategory,
              );
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: (catInfo['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: catInfo['color'] as Color, width: 1.5),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: catInfo['color'],
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            TextField(
              controller: widget.titleController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.06), height: 16),
            Expanded(
              child: TextField(
                controller: widget.contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}