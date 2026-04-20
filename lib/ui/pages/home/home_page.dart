import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/ui/pages/home/widgets/enroll_section_widget.dart';
import 'package:pizzathon/ui/widgets/footer.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../blocs/enrollment_cubit.dart';
import '../../blocs/user_list/users_list_cubit.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'widgets/user_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UsersListCubit(context.read<FirestoreService>(), context.read<ErrorTrackerService>())
                ..loadInitialUsers(),
        ),
        BlocProvider(
          create: (context) => EnrollmentCubit(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
            context.read<LocalStorageService>(),
            context.read<RemoteConfigService>(),
            context.read<ErrorTrackerService>(),
          )..checkEnrollmentStatus(),
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            const TopBanner(),
            const EnrollSectionWidget(),
            const Expanded(child: UserListWidget()),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
