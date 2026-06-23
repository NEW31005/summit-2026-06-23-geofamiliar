enum EntitlementStatus { active, inactive }

class EntitlementResult {
  const EntitlementResult({
    required this.status,
    required this.message,
    this.demo = true,
  });

  final EntitlementStatus status;
  final String message;
  final bool demo;

  bool get isActive => status == EntitlementStatus.active;
}

abstract interface class EntitlementService {
  Future<EntitlementResult> purchasePremium();
  Future<EntitlementResult> restorePremium();
  Future<EntitlementResult> cancelPremium();
}

/// A deterministic entitlement adapter for the prototype.
///
/// The app state talks to this boundary rather than directly toggling a flag,
/// so native StoreKit / Google Play Billing calls can replace it later.
class DemoEntitlementService implements EntitlementService {
  const DemoEntitlementService();

  @override
  Future<EntitlementResult> purchasePremium() async {
    return const EntitlementResult(
      status: EntitlementStatus.active,
      message: 'プレミアムデモを有効にしました。実際の請求はありません。',
    );
  }

  @override
  Future<EntitlementResult> restorePremium() async {
    return const EntitlementResult(
      status: EntitlementStatus.active,
      message: '復元デモが完了しました。端末の購入履歴確認は本番IAPで接続します。',
    );
  }

  @override
  Future<EntitlementResult> cancelPremium() async {
    return const EntitlementResult(
      status: EntitlementStatus.inactive,
      message: 'プレミアムデモをオフにしました。',
    );
  }
}
