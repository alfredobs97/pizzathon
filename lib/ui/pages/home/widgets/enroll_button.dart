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

        return ElevatedButton(
          onPressed: isEnrolled
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<EnrollmentCubit>(),
                      child: BlocProvider.value(
                        value: context.read<UsersListCubit>(),
                        child: const EnrollModal(),
                      ),
                    ),
                  );
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
          child: Text(
            isEnrolled ? 'Inscrito' : 'Inscribirme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
    );
  }
}
