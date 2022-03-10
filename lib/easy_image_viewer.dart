/// A library to easily display images in a full-screen dialog.
/// It supports pinch & zoom, and paging through multiple images.
library easy_image_viewer;

import 'package:flutter/material.dart';

import 'src/easy_image_provider.dart';
import 'src/easy_image_view_pager.dart';
import 'src/single_image_provider.dart';

export 'src/easy_image_provider.dart' show EasyImageProvider;
export 'src/easy_image_view.dart' show EasyImageView;
export 'src/easy_image_view_pager.dart' show EasyImageViewPager;
export 'src/multi_image_provider.dart' show MultiImageProvider;
export 'src/single_image_provider.dart' show SingleImageProvider;

/// Shows the given [imageProvider] in a full-screen [Dialog].
/// Setting [immersive] to false will prevent the top and bottom bars from being hidden.
/// The optional [onViewerDismissed] callback function is called when the dialog is closed.
/// The optional [useSafeArea] boolean defaults to false and is passed to [showDialog].
Future<Dialog?> showImageViewer(
    BuildContext context, ImageProvider imageProvider,
    {bool immersive = true,
    void Function()? onViewerDismissed,
    bool useSafeArea = false}) {
  return showImageViewerPager(context, SingleImageProvider(imageProvider),
      immersive: immersive,
      onViewerDismissed:
          onViewerDismissed != null ? (_) => onViewerDismissed() : null,
      useSafeArea: useSafeArea);
}

/// Shows the images provided by the [imageProvider] in a full-screen PageView [Dialog].
/// Setting [immersive] to false will prevent the top and bottom bars from being hidden.
/// The optional [onPageChanged] callback function is called with the index of
/// the image when the user has swiped to another image.
/// The optional [onViewerDismissed] callback function is called with the index of
/// the image that is displayed when the dialog is closed.
/// The optional [useSafeArea] boolean defaults to false and is passed to [showDialog].
/// The [closeButtonTooltip] text is displayed when the user long-presses on the
/// close button and is used for accessibility.
Future<Dialog?> showImageViewerPager(
    BuildContext context, EasyImageProvider imageProvider,
    {bool immersive = true,
    void Function(int)? onPageChanged,
    void Function(int)? onViewerDismissed,
    bool useSafeArea = false,
    String closeButtonTooltip = 'Close'}) {
  // if (immersive) {
  //   // Hide top and bottom bars
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  // }

  void Function()? internalPageChangeListener;
  final pageController =
      PageController(initialPage: imageProvider.initialIndex);

  if (onPageChanged != null) {
    internalPageChangeListener = () {
      onPageChanged(pageController.page?.round() ?? 0);
    };
    pageController.addListener(internalPageChangeListener);
  }

  return showDialog<Dialog>(
      context: context,
      useSafeArea: useSafeArea,
      builder: (context) {
        return Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(0),
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  EasyImageViewPager(
                      easyImageProvider: imageProvider,
                      pageController: pageController),
                  Positioned(
                      top: 25,
                      right: 25,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        tooltip: closeButtonTooltip,
                        onPressed: () {
                          Navigator.of(context).pop();

                          if (onViewerDismissed != null) {
                            onViewerDismissed(
                                pageController.page?.round() ?? 0);
                          }

                          // if (immersive) {
                          //   SystemChrome.setEnabledSystemUIMode(
                          //       SystemUiMode.edgeToEdge);
                          // }
                          if (internalPageChangeListener != null) {
                            pageController
                                .removeListener(internalPageChangeListener);
                          }
                          pageController.dispose();
                        },
                      ))
                ]));
      });
}
