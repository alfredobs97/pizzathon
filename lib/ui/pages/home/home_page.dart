import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/widgets/footer.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import '../../../data/services/firestore_service.dart';
import '../../blocs/user_list/users_list_cubit.dart';
import 'widgets/user_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => UsersListCubit(context.read<FirestoreService>())..loadInitialUsers(),
        child: Column(
          children: [
            TopBanner(),
            const Expanded(child: UserListWidget()),
            Footer(),
          ],
        ),
      ),
    );
  }
}
