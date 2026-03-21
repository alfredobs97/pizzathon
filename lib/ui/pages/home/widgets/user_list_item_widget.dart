import 'package:flutter/material.dart';
import 'package:pizzathon/domain/models/user_model.dart';

class UserListItemWidget extends StatelessWidget {
  final UserModel user;

  const UserListItemWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      tileColor: Theme.of(context).colorScheme.onSecondaryContainer,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
        child: user.photoUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF7B4E22)) : null,
      ),
      title: Text(
        user.displayName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
