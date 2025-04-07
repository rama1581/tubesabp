// home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'settings_screen.dart';
import 'live_chat_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late FirebaseMessaging _firebaseMessaging;
  final Map<String, Duration> _discountTimers = {};
  Timer? _timer;
  String _searchQuery = "";

  String _selectedCategory = "Semua";
  String _selectedLocation = "Semua";
  double _minPrice = 0;
  double _maxPrice = 1000000;

  final List<String> _categories = ["Semua", "Elektronik", "Fashion", "Kendaraan"];
  final List<String> _locations = ["Semua", "Gate 2", "Gate 3"];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _initializeDiscountTimers();
    _startDiscountTimers();
  }

  void _setupFirebaseMessaging() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 Izin notifikasi diberikan');
    } else {
      debugPrint('🚫 Izin notifikasi ditolak');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? "Notifikasi Baru"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _initializeDiscountTimers() {
    FirebaseFirestore.instance.collection('products').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        String productId = doc.id;
        _discountTimers.putIfAbsent(productId, () => const Duration(hours: 1));
      }
      setState(() {});
    });
  }

  void _startDiscountTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _discountTimers.forEach((key, value) {
          if (value.inSeconds > 0) {
            _discountTimers[key] = value - const Duration(seconds: 1);
          }
        });
      });
    });
  }

  String _formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        debugPrint("Navigasi ke halaman Notifikasi");
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  items: _locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc,
                      child: Text(loc),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Lokasi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (value) => setState(() => _selectedLocation = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Harga", style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000000,
            divisions: 20,
            labels: RangeLabels("Rp ${_minPrice.toInt()}", "Rp ${_maxPrice.toInt()}"),
            onChanged: (values) => setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            }),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = "Semua";
                  _selectedLocation = "Semua";
                  _minPrice = 0;
                  _maxPrice = 1000000;
                });
              },
              child: const Text("Reset Filter", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(width: double.infinity, height: 200, color: const Color(0xFFD84040)),
              Center(
                child: Image.asset('assets/logo.png', height: 150, opacity: const AlwaysStoppedAnimation(0.2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Cari produk...",
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (value) {
                                  setState(() => _searchQuery = value.toLowerCase());
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chat, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LiveChatScreen()));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("Category", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          _buildFilterSection(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Tidak ada produk tersedia"));
                  }

                  var products = snapshot.data!.docs.where((doc) {
                    var product = doc.data() as Map<String, dynamic>;
                    final name = product['name'].toString().toLowerCase();
                    final category = product['category'].toString();
                    final location = product['location'].toString();
                    final price = double.tryParse(product['price'].toString()) ?? 0;

                    return name.contains(_searchQuery) &&
                        (_selectedCategory == "Semua" || category == _selectedCategory) &&
                        (_selectedLocation == "Semua" || location == _selectedLocation) &&
                        price >= _minPrice && price <= _maxPrice;
                  }).toList();

                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      var product = products[index].data() as Map<String, dynamic>;
                      String productId = products[index].id;
                      _discountTimers.putIfAbsent(productId, () => const Duration(hours: 1));

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Expanded(child: Image.network(product["image"], fit: BoxFit.cover)),
                                  Text(product["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: _discountTimers[productId]! > const Duration(seconds: 0)
                                  ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "🔥 ${_formatDuration(_discountTimers[productId]!)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFFD84040),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
        ],
      ),
    );
  }
}
