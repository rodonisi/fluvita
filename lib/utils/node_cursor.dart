import 'package:html/dom.dart';

sealed class ReflowCursor {
  Node? addNext();
  Node commitSplit();
  bool splitChild();
}

class ElementCursor implements ReflowCursor {
  static final _leafTags = {'img', 'svg'};
  final Element _root;
  int _lastSplit = 0;
  int _index = -1; // Current child index
  ReflowCursor? _childCursor;
  bool _childYieldedResult = false;

  ElementCursor({required Element root}) : _root = root.clone(true);

  bool get _exhausted => _root.nodes.isEmpty || _index >= _root.nodes.length;

  @override
  Element? addNext() {
    if (_exhausted) return null;

    // If we are splitting a child, return the next partial child until it is exhausted
    if (_childCursor != null) {
      final partialChild = _childCursor!.addNext();
      if (partialChild != null) {
        _childYieldedResult = true;
        return _assembleCurrent(partialChild);
      }
      // Child exhausted — if it never yielded, return current node as-is before advancing
      _childCursor = null;
      if (!_childYieldedResult) {
        _childYieldedResult = false;
        return _assembleCurrent();
      }
      _childYieldedResult = false;
    }

    // Move to the next child
    _index++;

    if (_exhausted) return null;

    final current = _assembleCurrent();

    return current;
  }

  @override
  bool splitChild() {
    // Just passthrough if we are processing a child cursor
    if (_childCursor != null) {
      return _childCursor!.splitChild();
    }

    // Can't split if we are exhausted
    if (_exhausted) return false;

    // Split the current child if possible
    final current = _root.nodes[_index];
    if (current is Text) {
      _childCursor = TextCursor(textNode: current);
      return true;
    }
    if (current is Element &&
        current.localName != null &&
        !_leafTags.contains(current.localName)) {
      _childCursor = switch (current.localName) {
        // 'p' => ParagraphCursor(root: current),
        _ => ElementCursor(root: current),
      };
      return true;
    }

    return false;
  }

  @override
  Element commitSplit() {
    final Element result;

    if (_childCursor != null) {
      final childSplit = _childCursor!.commitSplit();
      result = _assembleCurrent(childSplit);
    } else {
      if (_index > 0) _index--;
      result = _assembleCurrent();
    }

    _lastSplit = _index + 1;

    return result;
  }

  Element _assembleCurrent([Node? partialChild]) {
    final clone = _root.clone(false);

    for (int i = _lastSplit; i < _index; i++) {
      clone.append(_root.nodes[i].clone(true));
    }

    if (partialChild != null) {
      clone.append(partialChild);
    } else if (!_exhausted) {
      clone.append(_root.nodes[_index].clone(true));
    }

    return clone;
  }
}

class TextCursor implements ReflowCursor {
  final List<String> _words;
  int _index = -1;
  int _lastSplit = 0;

  TextCursor({required Text textNode})
    : _words = textNode.data.split(RegExp(r'\s+'));

  @override
  Node? addNext() {
    _index++;

    if (_index >= _words.length) return null;

    return _build();
  }

  @override
  bool splitChild() => false;

  @override
  Node commitSplit() {
    // Backtrack overflowing word
    if (_index > 0) _index--;
    final res = _build();

    _lastSplit = _index + 1;

    return res;
  }

  Text _build() {
    return Text(_words.sublist(_lastSplit, _index + 1).join(' '));
  }
}
