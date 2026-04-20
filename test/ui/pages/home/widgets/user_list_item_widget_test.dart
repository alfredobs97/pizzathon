import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizzathon/domain/models/user_model.dart';
import 'package:pizzathon/ui/pages/home/widgets/user_list_item_widget.dart';

void main() {
  testWidgets('UserListItemWidget should show banned message and grayscale when isBanned is true', (WidgetTester tester) async {
    final bannedUser = UserModel(
      uid: '1',
      displayName: 'Cheater',
      email: 'cheater@example.com',
      photoUrl: '',
      score: 0,
      createdAt: DateTime.now(),
      isBanned: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserListItemWidget(user: bannedUser),
        ),
      ),
    );

    expect(find.text('Le hemos pillado haciendo trampas, ciao!'), findsOneWidget);
    expect(find.byType(ColorFiltered), findsOneWidget);
    
    final textWidget = tester.widget<Text>(find.text('Cheater'));
    expect(textWidget.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('UserListItemWidget should NOT show banned message or grayscale when isBanned is false', (WidgetTester tester) async {
    final normalUser = UserModel(
      uid: '2',
      displayName: 'Player',
      email: 'player@example.com',
      photoUrl: '',
      score: 10,
      createdAt: DateTime.now(),
      isBanned: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserListItemWidget(user: normalUser),
        ),
      ),
    );

    expect(find.text('Le hemos pillado haciendo trampas, ciao!'), findsNothing);
    expect(find.byType(ColorFiltered), findsNothing);
    
    final textWidget = tester.widget<Text>(find.text('Player'));
    expect(textWidget.style?.decoration == null || textWidget.style?.decoration == TextDecoration.none, isTrue);
  });
}
