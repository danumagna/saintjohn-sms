import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/shared_providers.dart';

Future<Uint8List?> preloadCurrentUserPhoto({
  required WidgetRef ref,
  required User user,
  int? cacheBust,
}) async {
  final authRepository = ref.read(authRepositoryProvider);
  final ids = <String>{
    user.id,
    ...?user.childrenStudentId?.map((e) => e.toString()),
  }.where((id) => id.trim().isNotEmpty).toList();

  for (final id in ids) {
    final bytes = await authRepository.getParentProfilePhotoBytes(
      parentId: id,
      cacheBust: cacheBust,
    );
    if (bytes != null) {
      _setCurrentUserPhotoBytesSafely(ref: ref, bytes: bytes);
      return bytes;
    }
  }

  _setCurrentUserPhotoBytesSafely(ref: ref, bytes: null);
  return null;
}

void _setCurrentUserPhotoBytesSafely({
  required WidgetRef ref,
  required Uint8List? bytes,
}) {
  try {
    ref.read(currentUserPhotoBytesProvider.notifier).state = bytes;
  } on StateError {
    // Ignore updates when the provider container/ref is no longer active.
  }
}
