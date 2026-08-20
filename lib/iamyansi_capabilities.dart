/// Central registry of capabilities that Iamyansi may request.
///
/// Keeping capability identifiers in one place prevents UI, AI, and executor
/// layers from drifting apart or inventing subtly different action names.
class IamyansiCapabilities {
  IamyansiCapabilities._();

  // Non-destructive actions.
  static const addExpense = 'add_expense';
  static const addTask = 'add_task';
  static const completeTask = 'complete_task';
  static const addShoppingItem = 'add_shopping_item';
  static const addCalendarEvent = 'add_calendar_event';
  static const createDiaryEntry = 'create_diary_entry';

  // Destructive or externally visible actions. These must remain behind
  // explicit confirmation in the executor router.
  static const deleteExpense = 'delete_expense';
  static const deleteTask = 'delete_task';
  static const sendMessage = 'send_message';
  static const makePayment = 'make_payment';
  static const changeSetting = 'change_setting';
  static const shareData = 'share_data';

  static const all = <String>{
    addExpense,
    addTask,
    completeTask,
    addShoppingItem,
    addCalendarEvent,
    createDiaryEntry,
    deleteExpense,
    deleteTask,
    sendMessage,
    makePayment,
    changeSetting,
    shareData,
  };

  static bool isKnown(String capability) =>
      all.contains(capability.trim().toLowerCase());
}
