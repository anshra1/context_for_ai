class AppSettings {
  final int fileSplitSizeInMB;
  final int maxTokenWarningLimit;
  final bool warnOnTokenExceed;
  final bool stripCommentsFromCode;
  final String? defaultExportLocation;
  
  AppSettings({
    required this.fileSplitSizeInMB,
    required this.maxTokenWarningLimit,
    required this.warnOnTokenExceed,
    required this.stripCommentsFromCode,
    this.defaultExportLocation,
  });
  
  AppSettings copyWith({
    int? fileSplitSizeInMB,
    int? maxTokenWarningLimit,
    bool? warnOnTokenExceed,
    bool? stripCommentsFromCode,
    String? defaultExportLocation,
  }) {
    return AppSettings(
      fileSplitSizeInMB: fileSplitSizeInMB ?? this.fileSplitSizeInMB,
      maxTokenWarningLimit: maxTokenWarningLimit ?? this.maxTokenWarningLimit,
      warnOnTokenExceed: warnOnTokenExceed ?? this.warnOnTokenExceed,
      stripCommentsFromCode: stripCommentsFromCode ?? this.stripCommentsFromCode,
      defaultExportLocation: defaultExportLocation ?? this.defaultExportLocation,
    );
  }
}