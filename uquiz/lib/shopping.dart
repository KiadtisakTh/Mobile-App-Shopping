import 'package:flutter/material.dart';
import 'package:requests/requests.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // เรียกฟังก์ชันเพื่อดึงข้อมูลสินค้าเมื่อเปิดหน้า
  }

  Future<void> _fetchProducts() async {
    try {
      final url = 'https://api.escuelajs.co/api/v1/products'; // URL สำหรับดึงสินค้าทั้งหมด
      final response = await Requests.get(url);
      if (response.statusCode == 200) {
        setState(() {
          products = response.json(); // เก็บข้อมูลสินค้าทั้งหมดในตัวแปร products
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch products: $e')),
      );
    }
  }

  // ฟังก์ชันสำหรับลบสินค้า
  Future<void> _deleteProduct(int id) async {
    try {
      final url = 'https://api.escuelajs.co/api/v1/products/$id'; // URL สำหรับลบสินค้า
      final response = await Requests.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((product) => product['id'] == id); // ลบสินค้าจากรายการในแอป
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully')),
        );
      } else {
        throw Exception("Failed to delete product");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  // ฟังก์ชันสำหรับแก้ไขสินค้า
  Future<void> _editProduct(int id, String newTitle, double newPrice) async {
    try {
      final url = 'https://api.escuelajs.co/api/v1/products/$id'; // URL สำหรับแก้ไขสินค้า
      final response = await Requests.put(
        url,
        body: {
          'title': newTitle,
          'price': newPrice,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          // อัปเดตรายการสินค้าในแอป
          final index = products.indexWhere((product) => product['id'] == id);
          if (index != -1) {
            products[index]['title'] = newTitle;
            products[index]['price'] = newPrice;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        throw Exception("Failed to edit product");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit product: $e')),
      );
    }
  }

  // Dialog สำหรับแก้ไขสินค้า
  void _showEditProductDialog(int id, String currentTitle, double currentPrice) {
    final titleController = TextEditingController(text: currentTitle);
    final priceController = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newTitle = titleController.text;
                final newPrice = double.tryParse(priceController.text) ?? currentPrice;
                _editProduct(id, newTitle, newPrice); // เรียกฟังก์ชันแก้ไขสินค้า
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UQuiz Shopping"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return ListTile(
                  leading: Image.network(
                    product['images'][0],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                  title: Text(product['title']),
                  subtitle: Text('\$${product['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // เปิด Dialog สำหรับแก้ไขสินค้า
                          _showEditProductDialog(
                            product['id'],
                            product['title'],
                            product['price'].toDouble(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // เรียกฟังก์ชันลบสินค้า
                          _deleteProduct(product['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
    );
  }
}
