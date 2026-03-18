import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Column(
                    children: [
                      const Text(
                        'Los participantes',
                        style: TextStyle(
                          color: Color(0xFF420B0B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'PIZZATHON',
                        style: TextStyle(
                          color: Color(0xFFFF6B00),
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // User List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                          width: 260,
                          child: UserListItemWidget(user: state.users[index]),
                        ),
                      ),
                    );
                  },
                  childCount: state.users.length + (state.hasReachedMax ? 0 : 1),
                ),
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
