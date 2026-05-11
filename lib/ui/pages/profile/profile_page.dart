import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/profile/profile_cubit.dart';
import 'package:pizzathon/ui/blocs/profile/profile_state.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';
import 'package:pizzathon/ui/blocs/user_pizzas/user_pizzas_cubit.dart';
import 'package:pizzathon/ui/pages/profile/widgets/profile_header.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';
import 'package:pizzathon/ui/pages/profile/widgets/user_pizzas_list.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  final String? publicIdentifier;

  const ProfilePage({super.key, this.publicIdentifier});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UploadLimitCubit>().checkLimit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPublic = widget.publicIdentifier != null;

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
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent - 200)) {
          context.read<UserPizzasCubit>().fetchMorePizzas(user.uid);
        }
        return false;
      },
      child: CustomScrollView(
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
                    BlocBuilder<UploadLimitCubit, UploadLimitState>(
                      builder: (context, limitState) {
                        final bool isReached = limitState is UploadLimitReached;
                        final bool isChecking = limitState is UploadLimitChecking;
                        final bool isError = limitState is UploadLimitError;
                        final bool isDisabled = limitState is UploadDisabledGlobally;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 500),
                                child: SizedBox(
                                  width: 320,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: (isReached || isChecking || isError)
                                        ? null
                                        : () async {
                                            await context.push(AppRouter.newPizzaRoute);
                                            if (context.mounted) {
                                              context.read<UploadLimitCubit>().checkLimit();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      disabledForegroundColor: Colors.grey.shade600,
                                      textStyle: theme.textTheme.bodyLarge,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: isChecking
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            isDisabled
                                                ? 'Subidas deshabilitadas'
                                                : (isReached ? 'Listo por hoy' : 'Nueva Pizza'),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            if (isReached)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  'Has alcanzado el límite de 3 pizzas por hoy.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isError)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  limitState.message,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          UserPizzasList(user: user),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
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
