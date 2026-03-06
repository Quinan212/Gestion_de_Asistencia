import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_storage/shared_storage.dart';

import '../theme/spacing.dart';
import 'disabled_text_style.dart';
import 'mime_types.dart';

extension ShowText on BuildContext {
  void showToast(String text, {Duration duration = const Duration(seconds: 5)}) {
    if (!mounted) return;

    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: duration,
      ),
    );
  }
}

extension OpenUriWithExternalApp on Uri {
  Future<void> openWithExternalApp() async {
    final uri = this;

    try {
      final launched = await openDocumentFile(uri);

      if (launched) {
        print('Successfully opened $uri');
      } else {
        print('Failed to launch $uri');
      }
    } on PlatformException {
      print("There's no activity associated with the file type of this Uri: $uri");
    }
  }
}

extension ShowDocumentFileContents on DocumentFile {
  Future<void> showContents(BuildContext context) async {
    final mimeTypeOrEmpty = type ?? '';
    final sizeInBytes = size ?? 0;

    const k10mb = 1024 * 1024 * 10;

    if (!mimeTypeOrEmpty.startsWith(kTextMime) &&
        !mimeTypeOrEmpty.startsWith(kImageMime)) {
      if (mimeTypeOrEmpty == kApkMime) {
        context.showToast(
          'Requesting to install a package (.apk) is not currently supported, to request this feature open an issue at github.com/alexrintt/shared-storage/issues',
        );
        return;
      }

      await uri.openWithExternalApp();
      return;
    }

    if (sizeInBytes > k10mb) {
      context.showToast('File too long to open');
      return;
    }

    final content = await getDocumentContent(uri);

    if (content == null) return;

    final isImage = mimeTypeOrEmpty.startsWith(kImageMime);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        if (isImage) {
          return Image.memory(content);
        }

        final contentAsString = String.fromCharCodes(content);
        final fileIsEmpty = contentAsString.isEmpty;

        return Container(
          padding: k8dp.all,
          child: Text(
            fileIsEmpty ? 'This file is empty' : contentAsString,
            style: fileIsEmpty ? disabledTextStyle() : null,
          ),
        );
      },
    );
  }
}