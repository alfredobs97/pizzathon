import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/user_list/users_list_cubit.dart';
import '../../../blocs/user_list/users_list_state.dart';

class UsersTabView extends StatefulWidget {
  const UsersTabView({super.key});

  @override
  State<UsersTabView> createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UsersListCubit>().loadMoreUsers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersListCubit, UsersListState>(
      builder: (context, state) {
        if (state is UsersListInitial || (state is UsersListLoading)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UsersListError) {
          return Center(child: Text(state.message));
        }

        if (state is UsersListLoaded) {
          final users = state.users;
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<UsersListCubit>().loadInitialUsers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              controller: _scrollController,
              itemCount: state.hasReachedMax ? users.length : users.length + 1,
              itemBuilder: (context, index) {
                if (index >= users.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = users[index];
                final theme = Theme.of(context);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: theme.colorScheme.onSecondaryContainer,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                      child: user.photoUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF7B4E22)) : null,
                    ),
                    title: Text(
                      user.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${user.score} pts',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
