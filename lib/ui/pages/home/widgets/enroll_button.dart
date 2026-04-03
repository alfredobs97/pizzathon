import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/enrollment_state.dart';
import 'package:pizzathon/ui/blocs/user_list/users_list_cubit.dart';
import 'package:pizzathon/ui/pages/home/widgets/enroll_modal.dart';

class EnrollButton extends StatelessWidget {
  const EnrollButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnrollmentCubit, EnrollmentState>(
      builder: (context, state) {
        final isEnrolled = state is EnrollmentStatusChecked && state.isEnrolled;
        final isActive = state is EnrollmentStatusChecked && state.isEnrollmentActive;

        return ElevatedButton(
          onPressed: switch ((isEnrolled, isActive)) {
            (true, _) => null,
            (false, true) => () => _showEnrollModal(context),
            (false, false) => null,
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnrolled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            disabledBackgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size(180, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: switch (state) {
            EnrollmentLoading() => Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
            ),
            _ => Text(switch ((isEnrolled, isActive)) {
              (true, _) => 'Inscrito',
              (false, true) => 'Inscribirme',
              (false, false) => '¡Plazas cerradas!',
            }, style: Theme.of(context).textTheme.titleMedium),
          },
        );
      },
    );
  }

  Future<void> _showEnrollModal(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<EnrollmentCubit>()),
          BlocProvider.value(value: context.read<UsersListCubit>()),
        ],
        child: const EnrollModal(),
      ),
    );
  }
}
