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

  // ---------------------------------------------------------------------------
  // Passcode Screen (web-only)
  // ---------------------------------------------------------------------------

  /// Passcode screen title
  static const String enterPasscode = '請輸入密碼\nEnter passcode';

  /// Passcode screen subtitle
  static const String passcodeHint = '輸入家庭密碼以繼續\nEnter the family passcode to continue';

  /// Passcode text field label
  static const String passcodeLabel = '密碼 / Passcode';

  /// Passcode field hint
  static const String passcodeFieldHint = '請輸入密碼';

  /// Unlock button
  static const String unlock = '解鎖 / Unlock';

  /// Wrong passcode error
  static const String wrongPasscode = '密碼錯誤，請重試。\nWrong passcode, please try again.';

  // ---------------------------------------------------------------------------
  // Games
  // ---------------------------------------------------------------------------

  /// Games button tooltip (AppBar)
  static const String gamesTooltip = '小遊戲 / Games';

  /// Games button label (command bar)
  static const String gamesLabel = '小遊戲\nGames';

  /// Game selector sheet title
  static const String selectGame = '選擇遊戲\nSelect a Game';

  // -- Math Quiz --

  /// Math quiz game name
  static const String mathQuizName = '數學算術 / Math Quiz';

  /// Math quiz game description
  static const String mathQuizDesc = '簡單加減法練習\nSimple addition & subtraction';

  /// Quiz progress indicator (e.g. 第3/6題)
  static String quizProgress(int current, int total) => '第$current/$total題';

  /// Score display (e.g. ⭐ 4)
  static String score(int correct) => '⭐ $correct';

  /// Correct answer feedback
  static const String correctAnswer = '正確！\nCorrect!';

  /// Wrong answer feedback
  static const String wrongAnswer = '不對哦\nNot quite';

  /// Quiz result title
  static const String quizComplete = '完成了！\nAll Done!';

  /// Quiz result subtitle
  static String quizScore(int correct, int total) =>
      '你答對了$correct題！\nYou got $correct out of $total right!';

  /// Play again button
  static const String playAgain = '再玩一次 / Play Again';

  /// Back navigation
  static const String back = '返回 / Back';

  /// Operator display for addition
  static const String operatorAdd = '+';

  /// Operator display for subtraction
  static const String operatorSub = '−';

  // ---------------------------------------------------------------------------
  // Videos
  // ---------------------------------------------------------------------------

  /// Videos command bar button label
  static const String videosLabel = '影片\nVideos';

  /// Videos screen title
  static const String videosTitle = '影片列表\nVideos';

  /// FAB tooltip for adding a video
  static const String addVideoTooltip = '新增影片\nAdd Video';

  /// Add video sheet title
  static const String addVideo = '新增影片\nAdd Video';

  /// Add video button label
  static const String addVideoLabel = '新增影片\nAdd Video';

  /// Edit video sheet title
  static const String editVideo = '編輯影片\nEdit Video';

  /// Update video button label
  static const String updateVideo = '更新影片\nUpdate Video';

  /// Empty state: no videos yet
  static const String noVideos = '沒有影片\nNo videos yet';

  /// Error state when video stream fails
  static const String couldNotLoadVideos = '無法載入影片。\nCould not load videos.';

  /// Video title field label
  static const String videoTitleLabel = '影片標題 / Video Title';

  /// Video title field hint
  static const String videoTitleHint = '例如：太極拳教學\ne.g. Tai Chi Tutorial';

  /// YouTube URL field label
  static const String youtubeUrlLabel = 'YouTube 網址 / YouTube URL';

  /// YouTube URL field hint
  static const String youtubeUrlHint =
      '貼上 YouTube 連結或影片 ID\nPaste YouTube link or video ID';

  /// Validation: empty URL
  static const String pleaseEnterUrl =
      '請輸入 YouTube 網址。\nPlease enter a YouTube URL.';

  /// Validation: invalid YouTube URL
  static const String invalidYoutubeUrl =
      '無效的 YouTube 網址。\nInvalid YouTube URL.';

  /// Delete confirmation dialog title
  static const String deleteVideoTitle = '刪除影片\nDelete Video';

  /// Delete confirmation dialog body
  static const String deleteVideoConfirm =
      '確定要刪除此影片嗎？\nAre you sure you want to delete this video?';

  /// Delete button label
  static const String deleteLabel = '刪除\nDelete';
}
