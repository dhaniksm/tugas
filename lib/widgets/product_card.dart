import 'package:flutter/material.dart';
import 'package:tugas/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  String formatRupiah(double harga) {
    final hargaInt = harga.toInt();
    final textHarga = hargaInt.toString();
    String hasil = '';

    for (int i = 0; i < textHarga.length; i++) {
      final posisiDariBelakang = textHarga.length - i;
      hasil += textHarga[i];

      if (posisiDariBelakang > 1 && posisiDariBelakang % 3 == 1) {
        hasil += '.';
      }
    }

    return 'Rp $hasil';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text('Harga: ${formatRupiah(product.price)}'),
            const SizedBox(height: 6),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}
