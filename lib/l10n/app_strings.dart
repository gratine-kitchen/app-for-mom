/// Bilingual (English + Traditional Chinese) strings for the App for Mom UI.
///
/// Every label is displayed in both languages simultaneously, with
/// Traditional Chinese first (larger/top) and English second (smaller/bottom)
/// to serve bilingual family members.
class AppStrings {
  const AppStrings._();

  // ---------------------------------------------------------------------------
  // Home Screen
  // ---------------------------------------------------------------------------

  /// FAB tooltip
  static const String addEventTooltip = '新增活動\nAdd Event';

  /// Section header below the date display
  static const String upcomingEvents = '即將到來的活動\nUpcoming Events';

  /// Error state when Firestore stream fails
  static const String couldNotLoadEvents = '無法載入活動。\nCould not load events.';

  /// Empty state when there are no upcoming events
  static const String noUpcomingEvents = '沒有即將到來的活動\nNo upcoming events';

  /// Empty state hint text
  static const String tapPlusToAdd = '點擊 + 按鈕新增！\nTap the + button to add one!';

  // ---------------------------------------------------------------------------
  // Add Event Sheet
  // ---------------------------------------------------------------------------

  /// Bottom sheet title
  static const String newEvent = '新增活動\nNew Event';

  /// Text field label
  static const String eventTitleLabel = '活動名稱 / Event Title';

  /// Text field hint / placeholder
  static const String eventTitleHint = '例如：家庭聚餐\ne.g. Family Dinner';

  /// Validation error when title is empty
  static const String pleaseEnterTitle = '請輸入活動名稱。\nPlease enter an event title.';

  /// Date picker field label
  static const String dateLabel = '日期 / Date';

  /// DatePicker dialog help text
  static const String selectEventDate = '選擇活動日期\nSelect event date';

  /// DatePicker dialog field label
  static const String eventDateFieldLabel = '活動日期\nEvent date';

  /// Info message when selected date is today
  static const String eventIsToday = '活動設在今天。\nEvent is set for today.';

  /// Save button — normal state
  static const String saveEvent = '儲存活動\nSave Event';

  /// Save button — loading state
  static const String saving = '儲存中...\nSaving...';

  /// Error when saving fails
  static const String failedToSave = '儲存失敗\nFailed to save event';
}
