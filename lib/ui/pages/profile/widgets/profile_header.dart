import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final int pizzaCount;
  final int? rank;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.pizzaCount,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#--', // Rank placeholder
                          style: GoogleFonts.climateCrisis(
                            fontSize: 40,
                            wordSpacing: 1,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.score} Puntos',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                            height: 30 / 24,
                          ),
                        ),
                        Text(
                          '$pizzaCount Pizzas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty ? const Icon(Icons.person, size: 55) : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // User Name
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
