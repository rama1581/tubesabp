import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'settings_screen.dart'; // Import halaman Settings
import 'live_chat_screen.dart'; // Import halaman Live Chat

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> products = [
    {"name": "Pisau Dapur Tajam", "price": "Rp. 150.000", "image": "assets/knife.png"},
    {"name": "KitchenAid Mixer", "price": "RM3100", "image": "assets/mixer.png"},
    {"name": "Vitamix Blender", "price": "RM2100", "image": "assets/blender.png"},
    {"name": "Whiskey Glass", "price": "RM96", "image": "assets/glass.png"},
  ];

  int _selectedIndex = 0;
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;

    // Minta izin notifikasi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 Izin notifikasi diberikan');
    } else {
      print('🚫 Izin notifikasi ditolak');
    }

    // Dapatkan token FCM
    _firebaseMessaging.getToken().then((token) {
      print("🎯 Token FCM: $token");
    });

    // Menangani notifikasi saat aplikasi sedang berjalan (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("📩 Notifikasi Diterima: ${message.notification!.title}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? "Notifikasi Baru"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        debugPrint("Navigasi ke halaman Search");
        break;
      case 2:
        debugPrint("Navigasi ke halaman Profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFFD84040),
              ),
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                  opacity: const AlwaysStoppedAnimation(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Cari Apa ?",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onTap: () {
                              debugPrint("Navigasi ke halaman pencarian");
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.chat, color: Colors.white),
                          onPressed: () {
                            // Navigasi ke halaman Live Chat
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LiveChatScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          onPressed: () {
                            debugPrint("Navigasi ke halaman Keranjang");
                          },
                        ),
                        // Tambahkan ikon settings di pojok kanan atas
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Category", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Lainnya", style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hot Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    image: DecorationImage(
                                      image: AssetImage(products[index]["image"]!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(products[index]["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(products[index]["price"]!, style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
