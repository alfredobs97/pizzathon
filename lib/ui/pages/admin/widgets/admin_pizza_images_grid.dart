import 'package:flutter/material.dart';
import 'package:pizzathon/ui/widgets/fullscreen_image_dialog.dart';

class AdminPizzaImagesGrid extends StatelessWidget {
  final Map<String, String> imageUrls;

  const AdminPizzaImagesGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final images = imageUrls.values.toList();
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 600),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => FullscreenImageDialog(
                  imageUrl: images[index],
                  heroTag: images[index],
                ),
              );
            },
            child: Hero(
              tag: images[index],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
