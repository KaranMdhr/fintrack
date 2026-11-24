import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/screens/not_found_screen.dart';

class ExpenseNotFoundScreen extends StatelessWidget {
  const ExpenseNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NotFoundScreen(
      title: 'That expense is gone.',
      message: 'It may have been deleted, or the link is incomplete.',
      buttonLabel: 'Back to activity',
      onPressed: () => context.go('/activity'),
    );
  }
}
