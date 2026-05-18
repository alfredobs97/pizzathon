import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/data/services/rtdb_service.dart';
import 'package:pizzathon/data/services/admin_selection_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/domain/models/scoreboard_entry.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';
import 'package:pizzathon/domain/models/user_model.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_cubit.dart';
import 'package:pizzathon/ui/blocs/scoreboard/scoreboard_state.dart';
import 'package:pizzathon/ui/blocs/admin_selected_pizzas/admin_selected_pizzas_cubit.dart';
import 'package:pizzathon/ui/blocs/admin_selected_pizzas/admin_selected_pizzas_state.dart';
import 'package:pizzathon/ui/pages/profile/widgets/sponsor_banner.dart';
import 'package:pizzathon/ui/pages/scoreboard/widgets/prizes_modal.dart';
import 'package:pizzathon/ui/pages/scoreboard/widgets/ranking_countdown.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'package:pizzathon/ui/widgets/fullscreen_image_dialog.dart';

class ScoreboardPage extends StatelessWidget {
  const ScoreboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.uid : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ScoreboardCubit(rtdbService: context.read<RtdbService>())..init(currentUserId),
        ),
        BlocProvider(
          create: (context) =>
              AdminSelectedPizzasCubit(context.read<AdminSelectionService>())..init(),
        ),
      ],
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
      backgroundColor: Colors.white,
      bottomNavigationBar: Material(
        color: theme.colorScheme.primary,
        child: InkWell(
          onTap: () => PrizesModal.show(context),
          child: Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onPrimary, size: 32),
                Text(
                  'PREMIOS',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              const SliverToBoxAdapter(child: CountdownTopBanner()),
              const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.only(top: 8.0), child: SponsorBanner()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  Center(
                    child: Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        labelColor: theme.colorScheme.onPrimary,
                        unselectedLabelColor: theme.colorScheme.primary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.colorScheme.primary,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        tabs: const [
                          Tab(text: 'RANKING'),
                          Tab(text: 'BEST PIZZA'),
                        ],
                      ),
                    ),
                  ),
                  Colors.white,
                ),
              ),
            ];
          },
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [_RankingTabView(), _BestPizzaTabView()],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.child, this.backgroundColor);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, alignment: Alignment.center, child: child);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return child != oldDelegate.child || backgroundColor != oldDelegate.backgroundColor;
  }
}

class _RankingTabView extends StatelessWidget {
  const _RankingTabView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreboardCubit, ScoreboardState>(
      builder: (context, state) {
        if (state is ScoreboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ScoreboardError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ScoreboardLoaded) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<ScoreboardCubit>().loadMore();
              }
              return true;
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemCount: state.hasMore ? state.topEntries.length + 1 : state.topEntries.length,
              itemBuilder: (context, index) {
                if (index >= state.topEntries.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final entry = state.topEntries[index];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _RankingCard(rank: entry.rank, entry: entry),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BestPizzaTabView extends StatelessWidget {
  const _BestPizzaTabView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminSelectedPizzasCubit, AdminSelectedPizzasState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.selectedPizzas.isEmpty) {
          final theme = Theme.of(context);
          return Center(
            child: Text(
              'Aún no hay candidatas.',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: state.selectedPizzas.length,
          itemBuilder: (context, index) {
            final pizza = state.selectedPizzas[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _BestPizzaCard(pizza: pizza),
              ),
            );
          },
        );
      },
    );
  }
}

class _BestPizzaCard extends StatelessWidget {
  final PizzaModel pizza;

  const _BestPizzaCard({required this.pizza});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = pizza.imageUrls.values.toList();
    final darkBrown = theme.colorScheme.secondary;

    return Material(
      color: theme.colorScheme.onSecondaryContainer,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _PizzaDetailsModal.show(context, pizza),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: CarouselView(
                    itemExtent: 280,
                    shrinkExtent: 150,
                    children: images.map((url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pizza.pizzaStyle?.displayName ?? 'Pizza Candidata',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: darkBrown,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: darkBrown),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PizzaDetailsModal extends StatelessWidget {
  final PizzaModel pizza;

  const _PizzaDetailsModal({required this.pizza});

  static Future<void> show(BuildContext context, PizzaModel pizza) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PizzaDetailsModal(pizza: pizza),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = pizza.imageUrls.values.toList();
    final darkBrown = theme.colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button at top right
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: darkBrown, size: 32),
              ),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: CarouselView(
                        itemExtent: MediaQuery.of(context).size.width - 120,
                        shrinkExtent: 150,
                        onTap: (index) {
                          showDialog(
                            context: context,
                            builder: (_) => FullscreenImageDialog(
                              imageUrl: images[index],
                              heroTag: images[index],
                            ),
                          );
                        },
                        children: images.map((url) {
                          return Hero(
                            tag: url,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    pizza.pizzaStyle?.displayName ?? 'Pizza Candidata',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.85,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  FutureBuilder<UserModel?>(
                    future: context.read<FirestoreService>().getUser(pizza.userId),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      return Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: CachedNetworkImage(
                                      imageUrl: user.photoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.person, color: darkBrown),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Cocinero',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: darkBrown,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                '${user?.score ?? 0} PUNTOS',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: darkBrown,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Detail Rows
                  _DetailItem(label: 'HARINAS', value: pizza.flours ?? 'N/A'),
                  _DetailItem(label: 'PREFERMENTO', value: pizza.preferment ?? 'N/A'),
                  _DetailItem(
                    label: '% PREFERMENTO',
                    value: pizza.prefermentPercentage?.toString() ?? 'N/A',
                  ),
                  _DetailItem(
                    label: 'HIDRATACIÓN FINAL',
                    value: pizza.hydration != null ? '${pizza.hydration}' : 'N/A',
                  ),
                  _DetailItem(
                    label: 'PESO BOLA',
                    value: pizza.doughBallWeight?.toString() ?? 'N/A',
                  ),
                  _DetailItem(label: 'HORNO', value: pizza.oven ?? 'N/A'),
                  _DetailItem(
                    label: 'TEMPERATURAS DE COCCIÓN',
                    value: pizza.cookingTemperature?.toString() ?? 'N/A',
                  ),
                  _DetailItem(label: 'INGREDIENTE BASE', value: pizza.baseIngredient ?? 'N/A'),
                  _DetailItem(label: 'INGREDIENTES', value: pizza.otherIngredients ?? 'N/A'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkBrown = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: darkBrown,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: darkBrown,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
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
    final darkBrown = theme.colorScheme.secondary;

    return Material(
      color: theme.colorScheme.onSecondaryContainer,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/p/${entry.uid}');
        },
        child: Container(
          height: 80,
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Rank Number
              SizedBox(
                width: 60,
                child: Text(
                  '#$rank',
                  textAlign: TextAlign.left,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: darkBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              // Avatar
              Container(
                width: 36,
                height: 32,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: entry.photoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CachedNetworkImage(
                          imageUrl: entry.photoUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 100,
                          memCacheHeight: 100,
                          placeholder: (context, url) => Container(color: Colors.white),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person, color: darkBrown),
                        ),
                      )
                    : Icon(Icons.person, color: darkBrown),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: darkBrown,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${entry.score} PUNTOS',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
