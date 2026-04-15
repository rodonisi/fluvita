import 'package:html/dom.dart';
import 'package:kover/utils/logging.dart';

/// Iterates through the children of the given node, filling a clone of the root every time the iterator is moved
/// forward
class NodeCursor {
  static final _leafTags = {'p', 'img', 'svg'};

  /// Shallow of the root provided during initialization
  final Element root;

  /// Iterator over the children of the root provided during initialization
  final Iterator<Node> iterator;

  /// Recursive child cursor if a child requires splitting
  NodeCursor? childCursor;

  bool get exhausted => _exhausted;

  bool _exhausted = false;

  bool get _isLeaf =>
      root.localName != null && _leafTags.contains(root.localName);

  NodeCursor({
    required Element root,
  }) : root = root.clone(false),
       iterator = root.nodes.iterator;

  /// Moves the iterator forward and adds the element to the root node. Returns the root node as filled so far.
  Node? next() {
    if (_exhausted || _isLeaf) {
      return null;
    }

    final childNode = childCursor?.next();
    if (childNode != null) {
      if (root.children.isEmpty) {
        root.append(childNode);
      } else {
        root.children.last.replaceWith(childNode);
      }
      return root;
    }

    childCursor = null;

    if (!iterator.moveNext()) {
      _exhausted = true;
      log.d(
        'iterator exhausted, hasNext=false, current root has ${root.children.length}',
      );
      return null;
    }

    root.append(iterator.current.clone(true));
    return root;
  }

  /// Return the root node up to and not including the current iterator position. The root children are cleared and the
  /// next page is started.
  ///
  /// When a [childCursor] is active and its split yields an empty node (nothing
  /// fit inside the child), we back out: discard the child cursor, treat the
  /// entire child as the overflow element, and move it to the next subpage.
  Node commitSplit() {
    Element? removed;

    final childSplit = childCursor?.commitSplit();

    if (childSplit != null && root.children.isNotEmpty) {
      // Partial content fit inside the child — keep it in this subpage.
      root.children.last.replaceWith(childSplit);
    } else if (root.children.length > 1) {
      removed = root.children.removeLast();
    }

    // if (childCursor != null && root.children.isNotEmpty) {
    //   final childSplit = childCursor!.commitSplit();
    //
    //   if (childSplit.hasChildNodes()) {
    //     // Partial content fit inside the child — keep it in this subpage.
    //     root.children.last.replaceWith(childSplit);
    //   } else {
    //     // Nothing fit inside the child — back out to parent level.
    //     // The whole child becomes the overflow element for the next subpage.
    //     removed = root.children.removeLast();
    //     childCursor = null;
    //   }
    // } else if (root.children.isNotEmpty) {
    //   removed = root.children.removeLast();
    // }

    final committed = root.clone(true);
    root.children.clear();

    if (removed != null) {
      root.append(removed);
    }

    return committed;
  }

  /// Tries to split the current cursor position. If a split happened already for this page, false is returned.
  bool splitChild() {
    if (_isLeaf || _exhausted) {
      return false;
    }

    if (childCursor != null) {
      return childCursor!.splitChild();
    }

    final current = iterator.current;
    if (current is Element) {
      childCursor = NodeCursor(root: current);

      return true;
    }

    return false;
  }
}
