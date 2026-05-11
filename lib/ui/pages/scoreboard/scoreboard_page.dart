import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/data/services/rtdb_service.dart';
import 'package:pizzathon/domain/models/scoreboard_entry.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_cubit.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_state.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';

class ScoreboardPage extends StatelessWidget {
  const ScoreboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.uid : null;

    return BlocProvider(
      create: (context) =>
          ScoreboardCubit(rtdbService: context.read<RtdbService>())..init(currentUserId),
      child: const ScoreboardView(),
    );
  }
}

class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 0, left: 24.0, right: 24.0),
        child: BlocBuilder<ScoreboardCubit, ScoreboardState>(
          builder: (context, state) {
            if (state is ScoreboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ScoreboardError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is ScoreboardLoaded) {
              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(top: 24.0), child: SponsorBanner()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'PIZZATHON',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.climateCrisis(
                          fontSize: 32,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = state.topEntries[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _RankingCard(rank: entry.rank, entry: entry),
                        );
                      }, childCount: state.topEntries.length),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final ScoreboardEntry entry;

  const _RankingCard({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.onSecondaryContainer,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/p/${entry.uid}');
        },
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rank Number
                SizedBox(
                  width: 55,
                  child: Text(
                    '#$rank',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: entry.photoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(entry.photoUrl, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person, color: Colors.grey, size: 32),
                ),

                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          entry.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      Text(
                        '${entry.score} PUNTOS',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
