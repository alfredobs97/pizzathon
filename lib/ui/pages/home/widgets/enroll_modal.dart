import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/enrollment_cubit.dart';
import '../../../blocs/enrollment_state.dart';
import '../../../blocs/user_list/users_list_cubit.dart';

class EnrollModal extends StatelessWidget {
  const EnrollModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 340,
        height: 550,
        child: BlocConsumer<EnrollmentCubit, EnrollmentState>(
          listener: (context, state) {
            if (state is EnrollmentError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) => AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: switch (state) {
              EnrollmentLoading() => _LoadingView(key: const ValueKey('loading')),
              EnrollmentStatusChecked() when state.isEnrolled => _SuccessView(
                key: const ValueKey('success'),
              ),
              _ => _InitialView(key: const ValueKey('initial')),
            },
          ),
        ),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10),
              child: IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                'LEE ANTES DE\nINSCRIBIRTE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'La inscripción a Pizzathon es gratuita pero debes asumir el COMPROMISO de participar haciendo pizza.\n\nPizzathon no es para mirar es para COMPETIR HACIENDO PIZZA siguiendo las reglas de la competición\n\nPizzathon NO es para profesionales, es para pizzeras y pizzeros caseros ameturs. No se permitirá participar a profesionales de la pizza',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<EnrollmentCubit>().enroll(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  'Acepto y me inscribo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    height: 24 / 10,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Gestionando tu inscripción',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'INSCRIPCIÓN COMPLETADA',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recibirás un email con tu inscripción a Pizzathon',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<UsersListCubit>().loadInitialUsers();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
