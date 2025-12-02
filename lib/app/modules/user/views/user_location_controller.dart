import 'package:flutter/material.dart';
import '../../../data/models.dart';

class UserLocationPage extends StatefulWidget {
  const UserLocationPage({super.key, required this.user});

  final User user;

  @override
  State<UserLocationPage> createState() => _UserLocationPageState();
}

class _UserLocationPageState extends State<UserLocationPage> {
  // Controller untuk search lokasi
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filter jenis layanan
  String _selectedService = 'Semua';
  final List<String> _services = [
    'Semua',
    'Psikolog',
    'Psikiater',
    'Konseling',
    'Hotline'
  ];

  // Dummy data lokasi layanan kesehatan mental
  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Klinik Psikologi Universitas',
      'type': 'Psikolog',
      'address': 'Gedung Rektorat Lt.3, Kampus',
      'phone': '(021) 1234-5678',
      'hours': 'Senin-Jumat 08:00-16:00',
      'distance': '0.5 km',
      'icon': '🏥',
      'available': true,
    },
    {
      'name': 'RS Jiwa Jakarta',
      'type': 'Psikiater',
      'address': 'Jl. Kesehatan No. 10, Jakarta',
      'phone': '(021) 8765-4321',
      'hours': '24 Jam',
      'distance': '2.3 km',
      'icon': '🏥',
      'available': true,
    },
    {
      'name': 'Pusat Konseling Mahasiswa',
      'type': 'Konseling',
      'address': 'Gedung Kemahasiswaan Lt.2',
      'phone': '(021) 5555-1234',
      'hours': 'Senin-Sabtu 09:00-17:00',
      'distance': '0.8 km',
      'icon': '💬',
      'available': true,
    },
    {
      'name': 'Hotline Kesehatan Mental 24/7',
      'type': 'Hotline',
      'address': 'Layanan Telepon',
      'phone': '119 ext. 8',
      'hours': '24 Jam',
      'distance': '-',
      'icon': '📞',
      'available': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredLocations {
    return _locations.where((location) {
      final matchesService = _selectedService == 'Semua' || 
                             location['type'] == _selectedService;
      final matchesSearch = _searchQuery.isEmpty ||
                            location['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesService && matchesSearch;
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
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Lokasi Layanan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
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
                      hintText: 'Cari lokasi terdekat...',
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
            
            // Service filter
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = service == _selectedService;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(service),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedService = service);
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
            
            // Locations list
            Expanded(
              child: _filteredLocations.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada lokasi ditemukan',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        return _buildLocationCard(location);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      location['icon'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
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
                          location['type'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Distance
                if (location['distance'] != '-')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      location['distance'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Details
            _buildDetailRow(Icons.location_on, location['address']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.phone, location['phone']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, location['hours']),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Menelepon ${location['name']}')),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Hubungi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka rute ke ${location['name']}')),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Rute'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
