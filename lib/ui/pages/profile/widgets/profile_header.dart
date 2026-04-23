import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

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
                          '#7', // Placeholder rank
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
                          '24 Puntos', // Placeholder points
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.15,
                                height: 30 / 24,
                              ),
                        ),
                        Text(
                          '5 Pizzas', // Placeholder pizzas
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 55)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // User Name
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName?.toUpperCase() ?? '',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
