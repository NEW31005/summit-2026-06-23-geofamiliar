# GeoFamiliar

GeoFamiliar は、歩いた場所から相棒が見つかる位置情報ゲームです。

北極星はこれです。

> 地図を歩く → 行った場所が勝手にあなただけの相棒を選ぶ → 動いてる相棒が増える

## 現在の体験

- 起動すると最初に地図が開きます。
- 地図上には現在地、近くのスポット、取得済みの相棒だけが出ます。
- スポットの範囲に入ると、ボタン操作なしで相棒を自動取得します。
- 取得済み相棒は地図上で常時コマ送りアニメします。
- 相棒をタップすると詳細ページに入り、戻ると地図へ戻ります。
- Webプレビューでは、GPSの代わりに地図クリックで疑似移動できます。

公開プレビュー:

https://new31005.github.io/summit-2026-06-23-geofamiliar/

## 実装済みフェーズ

### Phase 1: コアループ

- ホームカード構成と手動拠点登録を廃止しました。
- `MapScreen` をアプリの起動画面にしました。
- メッシュ状のスポットを現在地周辺に先に配置します。
- `SpotGridService.enteredSpot` が現在地とスポット距離を判定します。
- `AppState.collectSpot` が重複取得を防ぎつつ、相棒と記憶を保存します。

### Phase 3: 地物リンクのハイブリッド設置

- ランダムなメッシュスポットに加え、確定スポット層を追加しました。
- 東京駅周辺の駅、公園、水辺、オフィス、コンビニ系スポットを `PlaceMeaningCategory` にリンクしています。
- `MapSpot` は `source`、`category`、`brandId` を持ちます。
- `brandId` により、将来のブランド限定スポットを後付けできます。
- マイナー地物は全解決せず、メッシュ側のランダム性に任せます。

### Phase 2: 動く相棒

- 取得済み相棒を静止画ではなく、常時コマ送りアニメにしました。
- 既存の `normal`、`happy`、`rest` PNGをフレームとして使います。
- タイマー駆動で上下移動、拡縮、傾きを加えています。
- 詳細情報は別ページへ分離し、地図ホームに戻していません。

## 主なファイル

- `lib/app.dart`
- `lib/screens/map_screen.dart`
- `lib/screens/familiar_detail_screen.dart`
- `lib/models/map_spot.dart`
- `lib/models/map_familiar.dart`
- `lib/services/spot_grid_service.dart`
- `lib/services/spot_placement_service.dart`
- `lib/services/confirmed_spot_catalog.dart`
- `lib/services/place_resolver.dart`
- `lib/widgets/animated_familiar_sprite.dart`

## 検証

```bash
dart format lib test
flutter analyze
flutter test
flutter build web --release --base-href "/summit-2026-06-23-geofamiliar/"
```

直近の確認:

- `flutter analyze`: No issues
- `flutter test`: 50 tests passed
- `flutter build web --release`: succeeded
- GitHub Pages公開済み
- 旧 `review_evidence` / `place_evidence` / `art_acceptance` は公開元の `web/` から削除済み

## 現在の制限

- Flutter Webは検証用プレビューです。
- 実歩行での最終評価は Android / iOS ネイティブ版で行う必要があります。
- Webでは位置情報権限が使えない場合、地図クリックで疑似移動します。
- 確定スポットカタログは現在、東京駅周辺の初期検証用です。
- ブランドコラボは構造のみ実装済みで、実際のコラボ配信は未実装です。
