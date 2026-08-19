import 'iamyansi_capability_policy.dart';
import 'iamyansi_lifeos_bridge.dart';

/// Converts an understood request into a safe, inspectable action plan.
/// Execution is deliberately separate so future tools can be plugged in
/// without allowing the model to bypass the capability policy.
class IamyansiActionPlanner {
  const IamyansiActionPlanner();

  IamyansiActionPlan plan(IamyansiBridgeResult result) {
    if (!result.allowed) {
      return IamyansiActionPlan(
        steps: const ['Ask the user to enable the required capability.'],
        requiresConfirmation: false,
      );
    }

    if (result.requiresConfirmation) {
      return IamyansiActionPlan(
        steps: const ['Explain the intended action.', 'Ask for explicit confirmation.', 'Execute only after confirmation.'],
        requiresConfirmation: true,
      );
    }

    final steps = switch (result.capability) {
      IamyansiCapability.expenseWrite => const ['Validate amount and category.', 'Record the expense.', 'Update the relevant summary.'],
      IamyansiCapability.taskWrite => const ['Create or update the task.', 'Preserve incomplete tasks for carry-forward.', 'Refresh completion progress.'],
      IamyansiCapability.shoppingWrite => const ['Extract requested items.', 'Normalize quantities/categories.', 'Add them to the household list.'],
      IamyansiCapability.calendarWrite => const ['Extract date and event.', 'Validate recurrence or due date.', 'Create the calendar record.'],
      IamyansiCapability.diaryWrite => const ['Transcribe the approved voice input.', 'Save it with its date/time.', 'Make it searchable.'],
      IamyansiCapability.webResearch => const ['Form the research query.', 'Retrieve current permitted sources.', 'Summarize findings and uncertainty.'],
      _ => const ['Understand the request.', 'Prepare the appropriate next action.'],
    };

    return IamyansiActionPlan(steps: steps, requiresConfirmation: false);
  }
}

class IamyansiActionPlan {
  final List<String> steps;
  final bool requiresConfirmation;

  const IamyansiActionPlan({
    required this.steps,
    required this.requiresConfirmation,
  });
}
