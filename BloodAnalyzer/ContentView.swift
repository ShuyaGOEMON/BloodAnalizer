//
//  ContentView.swift
//  RGBPicker
//
//  Created by Shuya Ishikawa on 2024/07/08.
//

import SwiftUI
import AVFoundation
import Charts

// ContentView構造体
struct ContentView: View {
    // ファイル名の変数
    @State private var fileName: String = ""
    // 配列の変数
    @State private var capturedData = [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]()
    // リアルタイム波形の表示配列
    @State private var displayedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)] = []
    // 測定秒数
    @State private var MeasureTime:Int = 62
    // 計測中かどうかの状態を管理する変数
    @State private var isMeasuring = false
    // 準備時間の終了判定
    @State private var isStart = false
    // カウントダウンタイマーの変数
    @State private var ct = 0
    // タイマーを保持する変数
    @State private var timer: Timer?
    // 準備時間の変数
    @State private var countdown = 3
    // 画面遷移の状態を管理する変数
    @State private var navigateToNextView = false
    // 保存されているファイルの一覧
    @State private var savedFiles = [String]()
    // 保存データ表示フラグ
    @State private var showSavedFiles = false
    // 結果表示フラグ
    @State private var isResult = false
    @State private var TIME: [Double] = []
    @State private var Rvalue: [Double] = []
    @State private var Gvalue: [Double] = []
    @State private var Bvalue: [Double] = []
    
    var body: some View {
        VStack {
            // navigateToNextViewがtrueの場合、次のビューに遷移する
            if navigateToNextView {
                NextView(caputuredData: $capturedData, fileName: $fileName, isStart: $isStart, isMeasuring: $isMeasuring, navigateToNextView: $navigateToNextView, ct: $ct, countdown: $countdown,isResult: $isResult)
            } else if showSavedFiles {
                SavedFilesView(files: $savedFiles, showSavedFiles: $showSavedFiles, deleteAction: deleteFile)
                    .onAppear(perform: fetchSavedFiles)
            } else {
                // isMeasuringがtrueの場合、計測中のUIを表示する
                if isMeasuring {
                    if isStart {
                        GeometryReader { geometry in
                            ZStack {
                                CameraView(onFinish: {
                                    self.navigateToNextView = true
                                }, MeasureTime: $MeasureTime, ct: $ct,capturedData: $capturedData, fileName: $fileName)
                                .edgesIgnoringSafeArea(.all)
                                
                                Image(.images)
                                    .resizable()
                                    .ignoresSafeArea()
                                    .frame(maxWidth: geometry.size.width)
                                    .scaledToFill()
                                
                                VStack {
                                    Text("計測中: \(MeasureTime - ct)秒")
                                        .font(.largeTitle)
                                        .padding()
                                        .foregroundColor(.white)
                                    
                                    RealTimeChartR(displayedData: $displayedData,data: $capturedData)
                                        .frame(height: 200)
                                        .padding()
                                        .background(Color.black)
                                    
                                    RealTimeChartG(displayedData: $displayedData,data: $capturedData)
                                        .frame(height: 200)
                                        .padding()
                                        .background(Color.black)
                                    
                                    RealTimeChartB(displayedData: $displayedData,data: $capturedData)
                                        .frame(height: 200)
                                        .padding()
                                        .background(Color.black)
                                }
                            }
                            .frame(maxWidth: geometry.size.width)
                        }
                        
                        if (MeasureTime - ct) == 0 {
                            Button(action: {
                                navigateToNextView = true
                            }) {
                                Text("計測終了")
                                    .font(.title)
                                    .padding()
                            }
                        }
                    } else {
                        Text("準備時間: 残り\(countdown)秒")
                            .font(.title)
                            .padding()
                            .onAppear {
                                startCountdown()
                            }
                    }
                } else {
                ZStack{
                    Image("background")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    VStack{
                        Text("ホーム")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                        
                        Spacer()
                            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        HStack{
                            // 計測開始ボタンを表示する
                            Button(action: {isMeasuring = true}) {
                                Text("計測開始")
                                    .font(.title)
                                    .padding(.all)
                                    .background(Color.blue)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(30)
                            }
                            
                            
                            // ファイル参照ボタンを表示する
                            Button(action: {showSavedFiles = true}) {
                                Text("保存データ")
                                    .font(.title)
                                    .padding(.all)
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(30)
                            }
                        }
                    }
                }
            }
        }
    }
}
    
    // カウントダウンを開始する関数
    func startCountdown() {
        
        timer?.invalidate()  // 既存のタイマーを無効化する
        // 1秒ごとにカウントダウンを更新するタイマーをセットする
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.timer?.invalidate()  // カウントダウンが0になったらタイマーを無効化する
                self.isStart = true       // カウントダウンが終了したら本測定を開始する
            }
        }
    }
    
    // ディレクトリ内の保存されたファイルを取得する関数
    func fetchSavedFiles() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
            // ファイル名を日時順にソート(バブルソート)
            let sortedFiles = files.sorted { file1, file2 in
                let file1URL = documentsURL.appendingPathComponent(file1)
                let file2URL = documentsURL.appendingPathComponent(file2)
                
                do {
                    let file1Attributes = try fileManager.attributesOfItem(atPath: file1URL.path)
                    let file2Attributes = try fileManager.attributesOfItem(atPath: file2URL.path)
                    
                    if let file1Date = file1Attributes[.creationDate] as? Date,
                       let file2Date = file2Attributes[.creationDate] as? Date {
                        return file1Date > file2Date
                    }
                } catch {
                    print("Error fetching file attributes: \(error)")
                }
                return file1 < file2
            }
            self.savedFiles = sortedFiles
        } catch {
            print("Error fetching files: \(error)")
        }
    }
    
    // ファイルを削除する関数
    func deleteFile(fileName: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(fileName)
        do {
            try fileManager.removeItem(at: fileURL)
            fetchSavedFiles() // 削除後にファイルリストを更新する
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
}

// 計測終了後に表示するビュー
struct NextView: View {
    @Binding var caputuredData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    @Binding var fileName: String
    @Binding var isStart: Bool
    @Binding var isMeasuring: Bool
    @Binding var navigateToNextView: Bool
    @Binding var ct: Int
    @Binding var countdown:Int
    @Binding var isResult: Bool
    
    var body: some View {
        VStack{
            Text("計測終了")
                .font(.largeTitle)
                .padding()
            Text("  以下の名前で保存しました\n\(fileName)")
                .font(.headline)
                .padding()
            
            Button(action: {
                caputuredData.removeAll()
                reset()
                
                print("再計測")
            }, label: {
                Text("ホームに戻る")
                    .font(.title)
                    .padding()
            })
            .padding()
        }
    }
    
    func reset() {
        isStart = false
        isMeasuring = false
        ct = 0
        navigateToNextView = false
        countdown = 3
    }
}

// Chart（グラフ）を表示するビュー
struct RealTimeChartR: View {
    @State private var MAX: Double = 255
    @State private var MIN: Double = 0
    @Binding var displayedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    @Binding var data: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    
    let maxDisplayedPoints = 300 // 表示するデータの最大数を設定
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            Chart {
                ForEach(Array(displayedData.enumerated()), id: \.offset) { index, item in
                    let clampedValue = min(max(Double(item.avgR), MIN), MAX)
                    LineMark(
                        x: .value("Time", Double(index)),
                        y: .value("R Value", clampedValue)
                    )
                    .interpolationMethod(.linear)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: true), range: .plotDimension(padding: 10))
            .chartPlotStyle { content in
                content
                    .background(.gray.opacity(0.2))
            }
            .chartXAxisLabel(position: .leading, alignment: .top, spacing: 20) {
                Text("        R脈波")
                    .font(.title)
            }
            .frame(width: width)
            .onAppear {
                updateDisplayedData()
            }
            .onChange(of: data.map { $0.avgR }) { oldData, newData in
                updateDisplayedData()
            }
            .animation(.linear(duration: 0.1), value: displayedData.count)
        }
    }
    private func updateDisplayedData() {
        DispatchQueue.main.async {
            // 最大データ数を超えた場合、古いデータを削除
            if data.count > maxDisplayedPoints {
                displayedData = Array(data.suffix(maxDisplayedPoints))
            } else {
                displayedData = data
            }
        }
    }
}

struct RealTimeChartG: View {
    @State private var MAX: Double = 255
    @State private var MIN: Double = 0
    @Binding var displayedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    @Binding var data: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    
    let maxDisplayedPoints = 300 // 表示するデータの最大数を設定
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            Chart {
                ForEach(Array(displayedData.enumerated()), id: \.offset) { index, item in
                    let clampedValue = min(max(Double(item.avgG), MIN), MAX)
                    LineMark(
                        x: .value("Time", Double(index)),
                        y: .value("G Value", clampedValue)
                    )
                    .interpolationMethod(.linear)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: true), range: .plotDimension(padding: 10))
            .chartPlotStyle { content in
                content
                    .background(.gray.opacity(0.2))
            }
            .chartXAxisLabel(position: .leading, alignment: .top, spacing: 20) {
                Text("        G脈波")
                    .font(.title)
            }
            .frame(width: width)
            .onAppear {
                updateDisplayedData()
            }
            .onChange(of: data.map { $0.avgG }) { oldData, newData in
                updateDisplayedData()
            }
            .animation(.linear(duration: 0.1), value: displayedData.count)
        }
    }
    private func updateDisplayedData() {
        DispatchQueue.main.async {
            // 最大データ数を超えた場合、古いデータを削除
            if data.count > maxDisplayedPoints {
                displayedData = Array(data.suffix(maxDisplayedPoints))
            } else {
                displayedData = data
            }
        }
    }
}

struct RealTimeChartB: View {
    @State private var MAX: Double = 255 
    @State private var MIN: Double = 0
    @Binding var displayedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    @Binding var data: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    
    let maxDisplayedPoints = 300 // 表示するデータの最大数を設定
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            Chart {
                ForEach(Array(displayedData.enumerated()), id: \.offset) { index, item in
                    let clampedValue = min(max(Double(item.avgB), MIN), MAX)
                    LineMark(
                        x: .value("Time", Double(index)),
                        y: .value("B Value", clampedValue)
                    )
                    .interpolationMethod(.linear)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: true), range: .plotDimension(padding: 10))
            .chartPlotStyle { content in
                content
                    .background(.gray.opacity(0.2))
            }
            .chartXAxisLabel(position: .leading, alignment: .top, spacing: 20) {
                Text("        B脈波")
                    .font(.title)
            }
            .frame(width: width)
            .onAppear {
                updateDisplayedData()
            }
            .onChange(of: data.map { $0.avgB }) { oldData, newData in
                updateDisplayedData()
            }
            .animation(.linear(duration: 0.1), value: displayedData.count)
        }
    }
    private func updateDisplayedData() {
        DispatchQueue.main.async {
            // 最大データ数を超えた場合、古いデータを削除
            if data.count > maxDisplayedPoints {
                displayedData = Array(data.suffix(maxDisplayedPoints))
            } else {
                displayedData = data
            }
        }
    }
}

// 保存されたファイルを表示するビュー
struct SavedFilesView: View {
    @Binding var files: [String]
    @Binding var showSavedFiles: Bool
    var deleteAction: ((String) -> Void)? = nil
    @State private var selectedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat)] = []
    @State private var ChartName: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("保存データ")
                    .font(.largeTitle)
                    .padding()
                List {
                    ForEach(files, id: \.self) { file in
                        HStack {
                            Button(action: {
                                selectedData = readCSVFile(fileName: file)
                                ChartName = file
                                print("ファイルが押されました\(file)")
                            }, label: {
                                Text(file)
                            })
                        }
                    }
                }
                Text(ChartName)
                    .font(.headline)
                    .padding()
                if !selectedData.isEmpty {
                    ArrayChart(data: selectedData)
                        .frame(height: 200)
                        .padding()
                }
                Button(action: {
                    showSavedFiles = false
                    if !selectedData.isEmpty {
                        selectedData.removeAll()
                    }
                }) {
                    Text("閉じる")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .cornerRadius(30.0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // ナビゲーション遷移
                    NavigationLink {
                        DeleteFilesView(files: $files, showSavedFiles: $showSavedFiles, deleteAction: deleteAction)
                    } label: {
                        Text("編集")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // ナビゲーション遷移
                    NavigationLink {
                        ExportFilesView(files: $files, showSavedFiles: $showSavedFiles)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 35.0, height: 35.0)
                    }
                }
            }
        }
    }
    
    // CSVファイルを配列に読み出す
    func readCSVFile(fileName: String) -> [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat)] {
        var csvArray = [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat)]()
        
        
        
        
        
        
            // ファイルパスを取4
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            // ファイルパスとファイル名の確認
            print("ファイルパス: \(fileURL.path)")
            // ファイル内容を読み込む
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            // ファイル内容の確認
            // print("ファイル内容: \(content)")
            // 行ごとに分割
            let rows = content.components(separatedBy: "\n")
            // 行数の確認
            print("行数: \(rows.count)")
            // 各行をカンマで分割して配列に格納
            for row in rows {
                let columns = row.components(separatedBy: ",")
                // カラム数の確認
                print("カラム数: \(columns.count)")
                if columns.count == 5, let avgR = Double(columns[2]), let avgG = Double(columns[3]), let avgB = Double(columns[4]) {
                    csvArray.append((avgR: CGFloat(avgR), avgG: CGFloat(avgG), avgB: CGFloat(avgB)))
                }
            }
            // 変換後の配列の確認
            // print("変換後の配列: \(csvArray)")
        } catch {
            print("ファイル読み込みエラー: \(error.localizedDescription)")
        }
        return csvArray
    }
}

// 計測後閲覧用Chart（グラフ）を表示するビュー
struct ArrayChart: View {
    @State private var MAX: Double = 110
    @State private var MIN: Double = 50
    var data: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat)]
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let clampedValue = min(max(Double(item.avgR), 50), 110)
                LineMark(
                    x: .value("Time", Double(index)),
                    y: .value("Red Value", clampedValue)
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYScale(domain: .automatic(includesZero: false, reversed: true), range: .plotDimension(padding: 10))
        .chartPlotStyle { content in
            content
                .background(.gray.opacity(0.2))
        }
        .chartXAxisLabel(position: .leading, alignment: .top, spacing: 20) {
            Text("        脈波")
                .font(.title)
        }
    }
}

// 編集画面を表示するビュー
struct DeleteFilesView: View {
    @Binding var files: [String]
    @Binding var showSavedFiles: Bool
    var deleteAction: ((String) -> Void)? = nil
    @State private var isShowAlert = false
    @State private var fileToDelete: String?
    
    var body: some View {
        VStack {
            Text("編集モード")
                .font(.title)
                .padding()
            List {
                ForEach(files, id: \.self) { file in
                    HStack {
                        Text(file)
                        Spacer()
                        Button(action: {
                            fileToDelete = file
                            isShowAlert.toggle()
                            print("削除\(file )")
                        },label: {
                            Text("削除")
                                .font(.body)
                                .padding(5)
                                .foregroundColor(.red)
                        })
                    }
                    .alert(isPresented: $isShowAlert) {
                        Alert(
                            title: Text("選択したファイルを削除しますか？"),
                            message: Text(fileToDelete ?? ""),
                            primaryButton: .destructive(Text("削除する")) {
                                if let fileToDelete = fileToDelete {
                                    deleteAction?(fileToDelete)
                                    print("削除ボタンが押されました (fileToDelete)")
                                }
                            },
                            secondaryButton: .cancel(Text("キャンセル"))
                        )
                    }
                }
            }
        }
    }
}

// 出力画面を表示するビュー
struct ExportFilesView: View {
    @Binding var files: [String]
    @Binding var showSavedFiles: Bool
    @State private var isShowAlert = false
    @State private var fileToExport: String?
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        VStack {
            Text("出力するファイルを\n  選択してください")
                .font(.title)
                .padding()
            List {
                ForEach(files, id: \.self) { file in
                    HStack {
                        Button(action: {
                            fileToExport = file
                            isShowAlert.toggle()
                            print("エクスポート\(file )")
                            print("ファイルが押されました\(file)")
                        }, label: {
                            Text(file)
                        })
                    }
                }
            }
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("選択したファイルを出力しますか？"),
                message: Text(fileToExport ?? ""),
                primaryButton: .destructive(Text("出力する")) {
                    exportFile()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareURL = shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }
    
    private func exportFile() {
        guard let fileName = fileToExport else { return }
        
        // 仮のファイルパスを作成（ここではドキュメントディレクトリを使用）
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectory = urls.first {
            let filePath = documentDirectory.appendingPathComponent(fileName)
            
            // ここでファイルの存在を確認し、存在する場合は共有用のURLとして設定
            if fileManager.fileExists(atPath: filePath.path) {
                shareURL = filePath
                showShareSheet = true
            } else {
                print("ファイルが見つかりません: \(filePath.path)")
            }
        }
    }
}

// シェアシートのラッパービュー
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// プレビュー用のコンテンツビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

