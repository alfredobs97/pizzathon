import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_model.dart';

class UserListItemWidget extends StatelessWidget {
  final UserModel user;

  const UserListItemWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Widget content = InkWell(
      onTap: () {
        final identifier = user.shortId ?? user.uid;
        context.push('/p/$identifier-${user.slug}');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: user.isBanned
              ? Colors.grey[900]
              : Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(24),
          border: user.isBanned ? Border.all(color: Colors.redAccent, width: 2) : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: user.isBanned ? Colors.grey[700] : Colors.white,
            backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty
                ? Icon(
                    Icons.person,
                    color: user.isBanned ? Colors.black54 : const Color(0xFF7B4E22),
                  )
                : null,
          ),
          title: Text(
            user.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: user.isBanned ? Colors.grey[400] : Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  decoration: user.isBanned ? TextDecoration.lineThrough : null,
                ),
          ),
          subtitle: user.isBanned
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: const Text(
                    'Le hemos pillado haciendo trampas, ciao!',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );

    if (user.isBanned) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: Opacity(opacity: 0.8, child: content),
      );
    }

    return content;
  }
}
