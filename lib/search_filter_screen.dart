import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchFilterScreen extends StatefulWidget {
  @override
  _SearchFilterScreenState createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String _searchQuery = "";
  String? _selectedCategory;
  double? _minPrice, _maxPrice;
  String? _selectedLocation;

  final List<String> _categories = ["Semua", "Elektronik", "Fashion", "Kendaraan"];
  final List<String> _locations = ["Semua", "Bandung", "Jakarta", "Surabaya"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cari Produk")),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterOptions(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari produk...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropdownButton<String>(
          value: _selectedCategory,
          hint: Text("Kategori"),
          items: _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategory = value);
          },
        ),
        DropdownButton<String>(
          value: _selectedLocation,
          hint: Text("Lokasi"),
          items: _locations.map((location) {
            return DropdownMenuItem(value: location, child: Text(location));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedLocation = value);
          },
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var products = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String name = data['name'].toLowerCase();
          String category = data['category'];
          String location = data['location'];

          bool matchesSearch = name.contains(_searchQuery);
          bool matchesCategory = _selectedCategory == null || _selectedCategory == "Semua" || category == _selectedCategory;
          bool matchesLocation = _selectedLocation == null || _selectedLocation == "Semua" || location == _selectedLocation;

          return matchesSearch && matchesCategory && matchesLocation;
        }).toList();

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: Image.network(product['imageUrl'], width: 50, height: 50),
              title: Text(product['name']),
              subtitle: Text("${product['category']} - ${product['location']}"),
              trailing: Text("Rp ${product['price']}"),
              onTap: () {
                // TODO: Navigasi ke halaman detail produk
              },
            );
          },
        );
      },
    );
  }
}
