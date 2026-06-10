import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ReusableImage extends StatelessWidget {
  const ReusableImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.radiusMd,
    this.heroTag,
    this.alignment = Alignment.center,
  });

  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final String? heroTag;
  final Alignment alignment;

  bool _isBase64(String str) {
    if (str.startsWith('data:image')) return true;
    if (str.length < 50) return false;
    // Cek pattern base64 dasar
    final RegExp base64RegExp = RegExp(r'^[a-zA-Z0-9+/=\s\n\r]*$');
    return base64RegExp.hasMatch(str);
  }

  Widget _buildErrorIcon() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isBase64(imagePath)) {
      try {
        String cleanBase64 = imagePath;
        if (imagePath.startsWith('data:image')) {
          final parts = imagePath.split(',');
          if (parts.length > 1) {
            cleanBase64 = parts[1];
          }
        }
        // Bersihkan whitespace/newline yang mungkin terbawa dari encoding
        cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
        final Uint8List decodedBytes = base64Decode(cleanBase64);
        imageWidget = Image.memory(
          decodedBytes,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, error, stackTrace) => _buildErrorIcon(),
        );
      } catch (_) {
        imageWidget = _buildErrorIcon();
      }
    } else if (imagePath.startsWith('http')) {
      imageWidget = Image.network(
        imagePath,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, error, stackTrace) => _buildErrorIcon(),
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, error, stackTrace) => _buildErrorIcon(),
      );
    }

    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: borderRadius == 0 ? Colors.transparent : AppColors.muted,
        height: height,
        width: width,
        child: imageWidget,
      ),
    );

    if (heroTag == null) {
      return content;
    }

    return Hero(tag: heroTag!, child: content);
  }
}
