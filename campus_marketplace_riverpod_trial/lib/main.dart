import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'item.dart';
import 'favorites_notifier.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
}

// เปลี่ยนจาก ConsumerWidget เป็น ConsumerStatefulWidget เพื่อให้เก็บ state ของ Search Box ได้
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final savedItems = ref.watch(favoritesProvider);
    
    // กรอง catalog ตามคำค้นหา
    final filteredCatalog = catalog.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('❤️ ${savedItems.length}'),
        actions: [
          // ปุ่มโชว์เฉพาะเวลามีของในตะกร้า
          if (savedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ยืนยันการล้างข้อมูล'),
                    content: const Text('ล้างรายการโปรดทั้งหมดหรือไม่?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          // ใช้ ref.read เพื่อเรียก Action ล้างข้อมูล
                          ref.read(favoritesProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'ค้นหาสินค้า...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredCatalog.map((item) => ListTile(
                title: Text(item.title),
                trailing: ElevatedButton(
                  onPressed: () => ref.read(favoritesProvider.notifier).add(item),
                  child: const Text('บันทึก'),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
