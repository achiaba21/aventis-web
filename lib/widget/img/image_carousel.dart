import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/document/fichier.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/img/image_net.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    this.photos,
    this.fallbackUrl,
    this.height = 300,
  });

  final List<Fichier>? photos;
  final String? fallbackUrl;
  final double height;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _imageUrls {
    final List<String> urls = [];

    // Ajouter les photos de la liste
    if (widget.photos?.isNotEmpty == true) {
      for (final photo in widget.photos!) {
        if (photo.path != null && photo.path!.isNotEmpty) {
          String imageUrl;
          if (photo.path!.startsWith('http://') || photo.path!.startsWith('https://')) {
            imageUrl = photo.path!;
          } else if (photo.path!.startsWith('assets/')) {
            imageUrl = photo.path!;
          } else {
            imageUrl = "$domain/${photo.path!}";
          }
          urls.add(imageUrl);
        }
      }
    }

    // Fallback sur imgUrl si pas de photos
    if (urls.isEmpty && widget.fallbackUrl != null && widget.fallbackUrl!.isNotEmpty) {
      String fallbackImageUrl;
      if (widget.fallbackUrl!.startsWith('http://') || widget.fallbackUrl!.startsWith('https://')) {
        fallbackImageUrl = widget.fallbackUrl!;
      } else if (widget.fallbackUrl!.startsWith('assets/')) {
        fallbackImageUrl = widget.fallbackUrl!;
      } else {
        fallbackImageUrl = "$domain/${widget.fallbackUrl!}";
      }
      urls.add(fallbackImageUrl);
    }

    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;

    if (imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.grey[300],
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey[600],
        ),
      );
    }

    if (imageUrls.length == 1) {
      // Une seule image, pas besoin de carousel
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ImageNet(
          imageUrls.first,
          width: double.infinity,
          height: widget.height,
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return ImageNet(
                imageUrls[index],
                width: double.infinity,
                height: widget.height,
              );
            },
          ),

          // Indicateurs de page
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Style.primaryColor
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Boutons de navigation (seulement si plus de 1 image)
          if (imageUrls.length > 1) ...[
            // Bouton précédent
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Bouton suivant
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex < imageUrls.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}