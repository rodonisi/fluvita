import 'package:html/dom.dart';

sealed class ReflowCursor {
  Node? addNext();
  Node commitSplit();
  bool splitChild();
}

class ElementCursor implements ReflowCursor {
  static const Set<String> _leafTags = {'img', 'svg'};

  final Element _root;
  final Element _buffer;
  final List<Node> _stack = [];
  final List<Element> _targetStack = [];
  late Element _target;

  ElementCursor({required Element root})
    : _root = root.clone(true),
      _buffer = root.clone(false) {
    _stack.addAll(_root.nodes.reversed);
    _targetStack.add(_buffer);
    _target = _buffer;
  }

  @override
  Element? addNext() {
    if (_stack.isEmpty) return null;

    final node = _stack.removeLast();

    if (node is _PopMarker) {
      _targetStack.removeLast();
      _target = _targetStack.last;
      return addNext(); // Get the actual next node
    }

    _target.append(node);
    return _buffer;
  }

  @override
  Element commitSplit() {
    _stack.add(_target.nodes.removeLast());

    final result = _buffer.clone(true);

    // Reconstruct a clear tree up to the current target
    _targetStack.fold(null, (Element? parent, current) {
      current.nodes.clear();
      if (parent != null) parent.append(current);
      return current;
    });

    return result;
  }

  @override
  bool splitChild() {
    final child = _target.nodes.last;

    if (child is Text) {
      return _splitTextNode(child);
    }

    if (child is! Element || _leafTags.contains(child.localName)) return false;

    final newTarget = child.clone(false);
    _target.nodes.last.replaceWith(newTarget);

    // Push a marker so we know when this element's children are done
    _stack.add(_PopMarker());
    _stack.addAll(child.nodes.reversed);

    _target = newTarget;
    _targetStack.add(newTarget);

    return true;
  }

  bool _splitTextNode(Text child) {
    final text = child.text;

    // Split by words, keeping the whitespace (Regex keeps the delimiters)
    // This captures words and the spaces following them.
    final words = text.split(RegExp(r'(?<=\s)'));

    if (words.length <= 1) {
      // If it's only one word and it still doesn't fit,
      // we can't split it further by word.
      return false;
    }

    child.remove();

    for (final word in words.reversed) {
      _stack.add(Text(word));
    }

    return true;
  }
}

class _PopMarker extends Text {
  _PopMarker() : super('');
}
