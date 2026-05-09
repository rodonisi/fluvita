import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:kover/utils/node_cursor.dart';

void main() {
  group('ElementCursor', () {
    test('when empty nodes, next returns null', () {
      final root = Element.tag('div');
      final cursor = ElementCursor(root: root);

      final res = cursor.addNext();

      expect(res, isNull);
    });

    test('when exhausted, next returns null', () {
      final root = Element.tag('div')..append(Text('Hello'));
      final cursor = ElementCursor(root: root);

      cursor.addNext();
      final res = cursor.addNext();

      expect(res, isNull);
    });

    test('when commit split, then root clone up to split is returned', () {
      final root = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello')))
        ..append(Element.tag('p')..append(Text('there')));
      final expected = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello')));

      final cursor = ElementCursor(root: root);

      cursor.addNext();
      final res = cursor.commitSplit();

      expect(res.outerHtml, equals(expected.outerHtml));
    });

    test('after committed split, next returns the next child', () {
      final root = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello')))
        ..append(Element.tag('p')..append(Text('there')));
      final expected = Element.tag('div')
        ..append(Element.tag('p')..append(Text('there')));

      final cursor = ElementCursor(root: root);

      cursor.addNext();
      cursor.commitSplit();
      final res = cursor.addNext();

      expect(res, isNotNull);
      expect(res!.outerHtml, equals(expected.outerHtml));
    });

    test(
      'when split child on leaf node, then returns false',
      () {
        final root = Element.tag('div')
          ..append(Element.tag('img')..append(Text('Hello')));
        final cursor = ElementCursor(root: root);

        cursor.addNext();
        final res = cursor.splitChild();

        expect(res, isFalse);
      },
    );

    test('when split child on non-leaf node, then returns true', () {
      final root = Element.tag('div')
        ..append(Element.tag('div')..append(Text('Hello')));
      final cursor = ElementCursor(root: root);

      cursor.addNext();
      final res = cursor.splitChild();

      expect(res, isTrue);
    });

    test(
      'when child split, then addNext adds from child',
      () {
        final root = Element.tag('div')
          ..append(
            Element.tag('div')..append(Text('Hello')..append(Text('there'))),
          );
        final expected = Element.tag('div')
          ..append(Element.tag('div')..append(Text('Hello')));

        final cursor = ElementCursor(root: root);

        cursor.addNext();
        cursor.splitChild();
        final res = cursor.addNext();

        expect(res, isNotNull);
        expect(res!.outerHtml, equals(expected.outerHtml));
      },
    );

    test(
      'when child split commit, then backtracks and continues from child',
      () {
        final root = Element.tag('div')
          ..append(Element.tag('div'))
          ..append(Element.tag('p'));
        final expectedCommit = Element.tag('div')..append(Element.tag('div'));
        final expectedNext = Element.tag('div')..append(Element.tag('p'));

        final cursor = ElementCursor(root: root);

        cursor.addNext(); // div
        cursor.splitChild(); // div
        cursor.addNext(); // inner div
        cursor.addNext(); // p
        final commit = cursor.commitSplit();
        final res = cursor.addNext();
        final cont = cursor.addNext();

        expect(commit.outerHtml, equals(expectedCommit.outerHtml));

        expect(res, isNotNull);
        expect(res!.outerHtml, equals(expectedNext.outerHtml));
        expect(cont, isNull);
      },
    );

    test('when splitting text node, addNext adds words', () {
      final root = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello there')));
      final expected = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello')));

      final cursor = ElementCursor(root: root);

      cursor.addNext();
      cursor.splitChild();
      cursor.addNext();
      cursor.splitChild();
      final res = cursor.addNext();

      expect(res, isNotNull);
      expect(res!.outerHtml, equals(expected.outerHtml));
    });

    test('when splitting text node, addNext adds words', () {
      final root = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello there')));
      final expectedCommit = Element.tag('div')
        ..append(Element.tag('p')..append(Text('Hello')));
      final expectedNext = Element.tag('div')
        ..append(Element.tag('p')..append(Text('there')));

      final cursor = ElementCursor(root: root);

      cursor.addNext();
      cursor.splitChild();
      cursor.addNext();
      cursor.splitChild();
      cursor.addNext();
      cursor.addNext();
      final commit = cursor.commitSplit();
      final res = cursor.addNext();

      expect(commit.outerHtml, equals(expectedCommit.outerHtml));
      expect(res, isNotNull);
      expect(res!.outerHtml, equals(expectedNext.outerHtml));
    });

    test('complete split run', () {
      final root = Element.tag('div')
        ..append(Element.tag('p')..append(Text('sit aliqua labore incididunt')))
        ..append(Element.tag('p')..append(Text('est aliqua eu minim')));
      final expectedFirstSplit = Element.tag('div')
        ..append(Element.tag('p')..append(Text('sit aliqua labore incididunt')))
        ..append(Element.tag('p')..append(Text('est')));
      final expectedSecondSplit = Element.tag('div')
        ..append(Element.tag('p')..append(Text('aliqua eu minim')));

      final cursor = ElementCursor(root: root);

      cursor.addNext(); // div
      cursor.splitChild(); // div
      cursor.addNext(); // p0
      cursor.addNext(); // p1
      cursor.splitChild(); // p1
      cursor.addNext(); // text 'est aliqua eu minim'
      cursor.splitChild(); // text 'est aliqua eu minim'
      cursor.addNext(); // text 'est'
      cursor.addNext(); // text 'est aliqua'
      final firstCommit = cursor.commitSplit(); // text 'est'
      cursor.addNext(); // text 'aliqua'
      cursor.addNext(); // text 'aliqua eu'
      final res = cursor.addNext(); // text 'aliqua eu minim'
      final next = cursor.addNext(); // null

      expect(firstCommit.outerHtml, equals(expectedFirstSplit.outerHtml));
      expect(res, isNotNull);
      expect(res!.outerHtml, equals(expectedSecondSplit.outerHtml));
      expect(next, isNull);
    });
  });
}
