import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/domain/entities/user.dart';
import '../../providers/shared_providers.dart';

class UserProfileAvatar extends ConsumerWidget {
  final User user;
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final String fallbackLetter;

  const UserProfileAvatar({
    super.key,
    required this.user,
    required this.size,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    this.fallbackLetter = 'U',
  });

  Map<String, String>? _imageHeaders(String avatarUrl) {
    final uri = Uri.tryParse(avatarUrl);
    final host = uri?.host.toLowerCase() ?? '';
    if (host.contains('cdn.magnaedu.id')) {
      return null;
    }

    final token = user.userToken?.trim() ?? '';
    if (token.isEmpty) {
      return null;
    }

    return <String, String>{'AUTHTOKEN': token};
  }

  Widget _fallback() {
    final name = user.fullName.trim();
    final letter = name.isNotEmpty ? name[0].toUpperCase() : fallbackLetter;

    return Center(
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Uint8List? bytes = ref.watch(currentUserPhotoBytesProvider);
    final avatarUrl = user.avatarUrl?.trim() ?? '';

    Widget image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else if (avatarUrl.isNotEmpty) {
      image = Image.network(
        avatarUrl,
        headers: _imageHeaders(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else {
      image = _fallback();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}
