import 'package:flutter/material.dart';
import '../../../data/models.dart';

class UserEducationPage extends StatefulWidget {
  const UserEducationPage({super.key, required this.user});

  final User user;

  @override
  State<UserEducationPage> createState() => _UserEducationPageState();
}

class _UserEducationPageState extends State<UserEducationPage> {
  // Controller untuk search/filter artikel edukasi
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Kategori artikel
  final List<String> _categories = [
    'Semua',
    'Kecemasan',
    'Depresi',
    'Stress',
    'Motivasi',
    'Tips Sehat'
  ];
  String _selectedCategory = 'Semua';

  // Dummy data artikel edukasi
  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Mengelola Stress Akademik',
      'category': 'Stress',
      'excerpt': 'Tips praktis untuk mahasiswa menghadapi tekanan kuliah...',
      'image': '📚',
      'readTime': '5 min',
    },
    {
      'title': 'Mengatasi Kecemasan Sosial',
      'category': 'Kecemasan',
      'excerpt': 'Cara efektif mengurangi kecemasan saat berinteraksi...',
      'image': '🤝',
      'readTime': '7 min',
    },
    {
      'title': 'Pentingnya Self-Care',
      'category': 'Tips Sehat',
      'excerpt': 'Rutinitas harian yang dapat meningkatkan kesehatan mental...',
      'image': '💆',
      'readTime': '6 min',
    },
    {
      'title': 'Motivasi di Masa Sulit',
      'category': 'Motivasi',
      'excerpt': 'Bangkit dari keterpurukan dan menemukan semangat baru...',
      'image': '💪',
      'readTime': '4 min',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArticles {
    return _articles.where((article) {
      final matchesCategory = _selectedCategory == 'Semua' || 
                              article['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
                            article['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan search bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edukasi Kesehatan Mental',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    style: const TextStyle(color: Color(0xFF111827)),
                    cursorColor: Color(0xFF7C3AED),
                    decoration: InputDecoration(
                      hintText: 'Cari artikel...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category filter
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF7C3AED),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Articles list
            Expanded(
              child: _filteredArticles.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada artikel ditemukan',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return _buildArticleCard(article);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to article detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Membuka: ${article['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    article['image'],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['excerpt'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article['category'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          article['readTime'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
