import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/ui/pages/home/widgets/user_list_item_widget.dart';
import '../../../blocs/user_list/users_list_cubit.dart';
import '../../../blocs/user_list/users_list_state.dart';

class UserListWidget extends StatefulWidget {
  const UserListWidget({super.key});

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
        if (state is UsersListInitial) {
          return const Center(child: Text('Cargando usuarios...'));
        }
        if (state is UsersListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UsersListError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is UsersListLoaded) {
          if (state.users.isEmpty) {
            return const Center(child: Text('No hay usuarios todavía.'));
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Text(
                        'Los participantes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        'PIZZATHON',
                        style: GoogleFonts.climateCrisis(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // User List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= state.users.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
                      child: SizedBox(
                        width: 360,
                        child: UserListItemWidget(user: state.users[index]),
                      ),
                    ),
                  );
                }, childCount: state.users.length + (state.hasReachedMax ? 0 : 1)),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
