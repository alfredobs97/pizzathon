import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/rtdb_service.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_cubit.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_state.dart';

class ScoreboardPage extends StatelessWidget {
  const ScoreboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.uid : null;

    return BlocProvider(
      create: (context) => ScoreboardCubit(
        rtdbService: context.read<RtdbService>(),
      )..init(currentUserId),
      child: const ScoreboardView(),
    );
  }
}

class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: BlocBuilder<ScoreboardCubit, ScoreboardState>(
        builder: (context, state) {
          if (state is ScoreboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScoreboardError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ScoreboardLoaded) {
            return Column(
              children: [
                if (state.userRank != null)
                  _UserRankBanner(rank: state.userRank!),
                if (state.lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Última actualización: ${state.lastUpdated}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.topEntries.length,
                    itemBuilder: (context, index) {
                      final entry = state.topEntries[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: entry.photoUrl.isNotEmpty
                              ? NetworkImage(entry.photoUrl)
                              : null,
                          child: entry.photoUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(entry.displayName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entry.score} pts',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            _RankBadge(rank: entry.rank),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _UserRankBanner extends StatelessWidget {
  final int rank;

  const _UserRankBanner({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          const Text('Tu posición actual'),
          Text(
            '#$rank',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (rank == 1) color = Colors.amber;
    if (rank == 2) color = Colors.blueGrey.shade300;
    if (rank == 3) color = Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
