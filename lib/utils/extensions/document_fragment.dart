import 'package:html/dom.dart';

extension DocumentFragmentExtensions on DocumentFragment {
  String? paragraphScrollId() {
    final p = querySelector('p');

    return p?.attributes['scroll-id'];
  }
}

extension NodeExtensions on Node {
  bool get hasVisibleNodes {
    return isTextOrImage || nodes.any((node) => node.hasVisibleNodes);
  }

  bool get isTextOrImage {
    return this is Text ||
        (this is Element &&
            _imageTags.contains(
              (this as Element).localName,
            ));
  }

  static const _imageTags = {'img', 'svg'};
}
