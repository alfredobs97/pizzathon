import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/profile/profile_cubit.dart';
import 'package:pizzathon/ui/blocs/profile/profile_state.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/pages/profile/widgets/profile_header.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';
import 'package:pizzathon/ui/pages/profile/widgets/user_pizzas_list.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatelessWidget {
  final String? publicIdentifier;

  const ProfilePage({super.key, this.publicIdentifier});

  @override
  Widget build(BuildContext context) {
    final bool isPublic = publicIdentifier != null;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (!isPublic && state is AuthUnauthenticated) {
              context.go(AppRouter.landingRoute);
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.loaded && state.user != null) {
              context.read<UserPizzasCubit>().fetchInitialPizzas(state.user!.uid);
            }
            if (state.shareUrl != null) {
              _shareProfile(context, state.shareUrl!);
              context.read<ProfileCubit>().clearShareUrl();
            }
          },
        ),
      ],
      child: Column(
        children: [
          const CountdownTopBanner(),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                if (profileState.status == ProfileStatus.loading ||
                    profileState.status == ProfileStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profileState.status == ProfileStatus.error) {
                  return Center(child: Text(profileState.errorMessage ?? 'Error'));
                }

                return _buildProfileContent(context, profileState, isPublic);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state, bool isPublic) {
    final user = state.user;
    final pizzaCount = state.pizzaCount;

    if (user == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Theme.of(context).colorScheme.onSurface,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: SponsorBanner(),
                ),
                ProfileHeader(
                  user: user,
                  pizzaCount: pizzaCount,
                  isPublic: isPublic,
                  onShare: () => context.read<ProfileCubit>().generateShareLink(user),
                ),
                const SizedBox(height: 16),
                if (!isPublic)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SizedBox(
                        width: 320,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRouter.newPizzaRoute),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            'Nueva Pizza',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        UserPizzasList(user: user),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Future<void> _shareProfile(BuildContext context, String url) async {
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 12),
                const Text('¡Enlace de perfil copiado al portapapeles! 🍕'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.share(
        '¡Mira mi perfil en la Pizzathon! 🍕\n$url',
        subject: 'Perfil Pizzathon',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    }
  }
}
