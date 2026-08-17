enum IamyansiPermission { read, write, sensitiveWrite, webResearch }

/// Central permission boundary for iamyansi actions.
class IamyansiPermissionEngine {
  final Set<IamyansiPermission> granted;
  const IamyansiPermissionEngine({this.granted = const {}});

  bool canRead() => granted.contains(IamyansiPermission.read);
  bool canWrite() => granted.contains(IamyansiPermission.write);
  bool canResearchWeb() => granted.contains(IamyansiPermission.webResearch);

  /// Sensitive writes always require an explicit per-action confirmation,
  /// even when normal write permission has already been granted.
  bool requiresConfirmation(IamyansiPermission permission) =>
      permission == IamyansiPermission.sensitiveWrite;
}
