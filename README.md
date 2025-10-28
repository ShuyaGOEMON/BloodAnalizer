# BloodAnalyzer

## 概要
BloodAnalyzer は iPhone の超広角カメラとトーチを活用して血流由来の RGB 波形を収集し、リアルタイム可視化および CSV 出力を行う SwiftUI アプリケーションです。アプリのエントリポイントは [`BloodAnalyzerApp`](BloodAnalyzer/BloodAnalyzerApp.swift:11) で、メイン画面として [`ContentView`](BloodAnalyzer/ContentView.swift:13) を表示します。

## 主な特徴
- **リアルタイム計測 UI**  
  計測状態、カウントダウン、計測結果ナビゲーション、保存データ一覧、波形描画を一つの画面で制御する中心コンポーネントが [`ContentView`](BloodAnalyzer/ContentView.swift:13) です。
- **60fps カメラキャプチャとトーチ制御**  
  カメラのセットアップ、露光・ISO 調整、フレームごとの画像処理、計測完了時の CSV 保存を担うロジックは [`CameraView`](BloodAnalyzer/RGBGetdemo.swift:5) と [`CameraViewController`](BloodAnalyzer/RGBGetdemo.swift:21) に集約されています。
- **リアルタイム波形描画**  
  計測中の RGB 値をチャート表示する専用ビューとして [`RealTimeChartR`](BloodAnalyzer/ContentView.swift:258)、[`RealTimeChartG`](BloodAnalyzer/ContentView.swift:310)、[`RealTimeChartB`](BloodAnalyzer/ContentView.swift:362) を実装しています。
- **計測後の結果画面とデータ閲覧**  
  計測終了後の案内は [`NextView`](BloodAnalyzer/ContentView.swift:215)、保存済み CSV の参照／削除／共有は [`SavedFilesView`](BloodAnalyzer/ContentView.swift:415)、[`DeleteFilesView`](BloodAnalyzer/ContentView.swift:560)、[`ExportFilesView`](BloodAnalyzer/ContentView.swift:608) が担当します。
- **CSV 出力と共有**  
  計測データは [`saveColorDataToCSV()`](BloodAnalyzer/RGBGetdemo.swift:268) で CSV 化され、ドキュメントディレクトリへ保存後、[`ExportFilesView`](BloodAnalyzer/ContentView.swift:608) からシェアシートを起動できます。

## ファイル構成
- [`BloodAnalyzer/BloodAnalyzerApp.swift`](BloodAnalyzer/BloodAnalyzerApp.swift) ? アプリケーションのエントリポイントおよび `WindowGroup` 構成。
- [`BloodAnalyzer/ContentView.swift`](BloodAnalyzer/ContentView.swift) ? 計測フロー、UI 遷移、チャート表示、保存データ管理を含むメインビュー群。
- [`BloodAnalyzer/RGBGetdemo.swift`](BloodAnalyzer/RGBGetdemo.swift) ? AVFoundation によるカメラ制御、RGB 解析、CSV 書き出しロジック。
- [`BloodAnalyzer/Assets.xcassets`](BloodAnalyzer/Assets.xcassets/Contents.json) ? 背景画像・アイコン・配色に使用するアセットカタログ。
- [`BloodAnalyzer/Preview Content`](BloodAnalyzer/Preview Content/Preview Assets.xcassets/Contents.json) ? SwiftUI プレビュー用アセット。

## ビルドと実行
1. リポジトリを取得後、[`BloodAnalyzer.xcodeproj.zip`](BloodAnalyzer.xcodeproj.zip) を解凍し、生成された `.xcodeproj` または `.xcworkspace` を Xcode で開きます。
2. ターゲットデバイスとしてトーチ搭載の実機 iPhone を選択してください（シミュレータではカメラ・トーチ機能が利用できません）。
3. 必要に応じて `Signing & Capabilities` でチームとバンドル識別子を設定し、ビルド・実行します。
4. 初回起動時はカメラとフォトライブラリ（共有用）のアクセス許可を求められるため許可してください。

## 計測フロー
1. ホーム画面で「計測開始」を押すとカウントダウンが開始され、[`startCountdown()`](BloodAnalyzer/ContentView.swift:155) が計測準備を管理します。
2. カウントダウン完了後、[`CameraView`](BloodAnalyzer/RGBGetdemo.swift:5) が起動し、計測時間 [`MeasureTime`](BloodAnalyzer/ContentView.swift:21) まで連続して RGB データを取得します。
3. フレーム処理中は [`getAverageColorFromUIImage(_:)`](BloodAnalyzer/RGBGetdemo.swift:195) が平均色を算出し、表示用バッファに追加します。
4. 計測終了後に CSV が保存・命名され、[`NextView`](BloodAnalyzer/ContentView.swift:215) がファイル名と再計測導線を提示します。

## 保存データ管理
- 端末のドキュメントディレクトリに生成される CSV は [`fetchSavedFiles()`](BloodAnalyzer/ContentView.swift:170) によって最新順へ並び替えて表示されます。
- 個別ファイルの削除は [`deleteFile(fileName:)`](BloodAnalyzer/ContentView.swift:200)、共有は [`exportFile()`](BloodAnalyzer/ContentView.swift:653) から実行できます。
- 保存済み CSV を再読み込みし、グラフ表示する処理は [`readCSVFile(fileName:)`](BloodAnalyzer/ContentView.swift:488) と [`ArrayChart`](BloodAnalyzer/ContentView.swift:531) が担います。

## ライセンス
本プロジェクトは [`LICENSE`](LICENSE) の条件に従います。