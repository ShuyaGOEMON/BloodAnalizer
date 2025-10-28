import SwiftUI
import AVFoundation

// SwiftUIのビューとしてカメラプレビューを表示するための構造体
struct CameraView: UIViewControllerRepresentable {
    // 計測が終了したことを通知するためのコールバックを受け取るプロパティ
    var onFinish: (() -> Void)?
    @Binding var MeasureTime:  Int
    @Binding var ct: Int
    @Binding var capturedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    @Binding var fileName: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraViewController(MeasureTime: $MeasureTime, ct: $ct, capturedData: $capturedData, fileName: $fileName)
        controller.onFinish = onFinish  // コールバックを設定
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// AVCaptureVideoDataOutputSampleBufferDelegateプロトコルに準拠するUIViewController
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var frameCount = 0
    @Binding var MeasureTime : Int
    @Binding var ct: Int
    var lastTimestamp = CMTime()
    @Binding var capturedData: [(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]
    var imageView: UIImageView!
    // 計測が終了したことを通知するためのコールバック
    var onFinish: (() -> Void)?
    var isFinished = false
    @Binding var fileName: String
    
    // イニシャライザの追加
    init(MeasureTime: Binding<Int>,ct: Binding<Int>, capturedData: Binding<[(avgR: CGFloat, avgG: CGFloat, avgB: CGFloat, avgA: CGFloat)]>, fileName: Binding<String>) {
        _MeasureTime = MeasureTime
        _ct = ct
        _capturedData = capturedData
        _fileName = fileName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // キャプチャセッションの初期化
        captureSession = AVCaptureSession()
        // フレーム維持のため中解像度に設定
        captureSession.sessionPreset = .medium
        
        // デバイスの取得
        guard let captureDevice = AVCaptureDevice.default(.builtInUltraWideCamera,for: .video,position:.back) else { return }
        
        // 入力の作成と追加
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        // フレームレートの設定
         do {
             try captureDevice.lockForConfiguration()
             
             // デバイスが60fpsをサポートしているか確認し、設定
             let supportedFrameRateRanges = captureDevice.activeFormat.videoSupportedFrameRateRanges
             var isSupported = false
             for range in supportedFrameRateRanges {
                 if range.maxFrameRate >= 60 {
                     captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 60)
                     captureDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 60)
                     isSupported = true
                     break
                 }
             }
             
             if !isSupported {
                 print("60fps is not supported on this device.")
                 captureDevice.unlockForConfiguration()
                 return
             }
             
             // 露光時間とISO感度の設定
             if captureDevice.isExposureModeSupported(.custom) {
                 let maxISO = captureDevice.activeFormat.maxISO
                 let minDuration = CMTime(value: 1, timescale: 350)
                 captureDevice.setExposureModeCustom(duration: minDuration, iso: 30, completionHandler: nil)
                 print(maxISO)
             }
             
             captureDevice.unlockForConfiguration()
         } catch {
             print("Error: \(error.localizedDescription)")
             return
         }
        
        // ビデオデータ出力の作成と追加
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
        
        // プレビュー用のレイヤーを作成して追加
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // UIImageViewの初期化
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        DispatchQueue.global(qos: .userInitiated).async {
                    // キャプチャセッションの開始
                    self.captureSession.startRunning()
                    // トーチをオンにする
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.toggleTorch(on: true)
                    }
                }
    }
    
    
    
    // フレームごとに呼ばれるデリゲートメソッド
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if frameCount == 1 {
            lastTimestamp = timestamp
        }
        
        let elapsedTime = CMTimeSubtract(timestamp, lastTimestamp).seconds
        if elapsedTime >= 1.0 {
            let fps = Double(frameCount) / elapsedTime
            print("\n↑↑↑ Current FPS: \(fps)\tTime: \(ct)\n")
            ct += 1
            frameCount = 0
            lastTimestamp = timestamp
        }
        
        // 画像バッファの取得
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        connection.videoRotationAngle = 90
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        // CIColorMatrixフィルタを適用して赤色信号を弱める
        let redGainFilter = CIFilter(name: "CIColorMatrix")!
        redGainFilter.setValue(ciImage, forKey: kCIInputImageKey)
        // 赤色を減らすため、RVectorのx成分を減らす（例えば0.5に設定）
        redGainFilter.setValue(CIVector(x: 0.1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        redGainFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        redGainFilter.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
        redGainFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        if let outputImage = redGainFilter.outputImage {
            DispatchQueue.main.async {
                guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return }
                let uiImage = UIImage(cgImage: cgImage)
                
                // ct>2からRGBデータを配列に格納する
                if self.ct >= 2 {
                    // 全ピクセルの平均色を計算（処理を軽減）
                    let (averageColor, totalPixels, width, height) = self.getAverageColorFromUIImage(uiImage)
                    print("Average Color: \(averageColor.debugDescription), Total Pixels: \(totalPixels), Width: \(width), Height: \(height)")
                    
                    self.capturedData.append((avgR: averageColor.components.red, avgG: averageColor.components.green, avgB: averageColor.components.blue, avgA: averageColor.components.alpha))
                }
                
                if self.ct == self.MeasureTime && !self.isFinished {
                    self.isFinished = true
                    self.saveColorDataToCSV {
                        DispatchQueue.main.async {
                            // 計測終了時にコールバックを呼び出す
                            self.onFinish?()
                        }
                    }
                    self.capturedData.removeAll()
                }
                
            }
        }
    }
    
    // UIImageから全ピクセルの平均色を取得するメソッド
    func getAverageColorFromUIImage(_ myUIImage: UIImage) -> (UIColor, Int, Int, Int) {
        guard let cgImage = myUIImage.cgImage else { return (UIColor.clear, 0, 0, 0) }
        guard let data = cgImage.dataProvider?.data else { return (UIColor.clear, 0, 0, 0) }
        let pixelData = CFDataGetBytePtr(data)
        
        let width = Int(myUIImage.size.width)
        let height = Int(myUIImage.size.height)
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var totalA: CGFloat = 0
        
        // 画像サイズが大きい場合、ピクセルを間引いて処理を軽減（多分480 (step数4 Total Pixels: 129600)が30fps維持の限界値,   481だと落ちる(28fpsくらい)）
        // ビデオの真ん中付近129600ピクセルのデータから平均求めることも検討中（時間なかった
        // 全体の 1/36 の値
        //let step = max(width, height) / 480
        
        let newWidth = width - (width*7 / 12)
        let newHeight1 = height - (height*10 / 12)
        let x = width*5 / 12
        let y1 = height*0 / 12
        var y2 = height*0 / 12
        var y3 = height*10 / 120
        
        var pixelCount : Int = 0
        // （1つのピクセルに4つのデータ[順番は赤、緑、青、アルファ]）
        for y1 in y1 ..< newHeight1 {
            for x in x ..< newWidth {
                let pixelInfo1 = ((newWidth * y1) + x) * 4
                let pixelInfo2 = ((newWidth * y2) + x) * 4
                let pixelInfo3 = ((newWidth * y3) + x) * 4
                totalR += CGFloat(pixelData![pixelInfo3])
                totalG += CGFloat(pixelData![pixelInfo2 + 1])
                totalB += CGFloat(pixelData![pixelInfo1 + 2])
                totalA += CGFloat(pixelData![pixelInfo1 + 3])
                pixelCount += 1
            }
            y2 += 1
            y3 += 1
        }
        // RGBAそれぞれ平均を算出する
        let avgR = totalR / CGFloat(pixelCount)
        let avgG = totalG / CGFloat(pixelCount)
        let avgB = totalB / CGFloat(pixelCount)
        let avgA = totalA / CGFloat(pixelCount)
        return (UIColor(red: avgR, green: avgG, blue: avgB, alpha: avgA), pixelCount, newWidth, newHeight1)
    }
    
    // トーチのオン/オフを切り替えるメソッド
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(.builtInUltraWideCamera,for: .video,position:.back), device.hasTorch else {
            print("Torch is not available on this device.")
            return
        }
        
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error.localizedDescription)")
        }
    }
    
    // フレームカウント用変数
    var FRAME: Int = 0
    // 計測時間カウント用変数
    var TIME: Float = 0
    // CSVファイルに変換する
    func saveColorDataToCSV(completion: @escaping () -> Void) {
        var csvString = "time,frame,avgR,avgG,avgB\n"
        for data in capturedData {
            // フラッシュライト点灯の遅延を考慮し、3秒目からデータを保存
            if FRAME > 120 {
                csvString += "\(TIME),\(FRAME),\(data.avgR),\(data.avgG),\(data.avgB)\n"
            }
            FRAME += 1
            TIME  += 1/60
        }
    
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // 現在日時をフォーマットしてファイル名に使用する
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmm"
            let dateString = dateFormatter.string(from: Date())
            self.fileName = "RGBData_\(dateString).csv"
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            DispatchQueue.global(qos: .background).async {
                do {
                    try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("CSV file has been created at \(fileURL.path)")
                    completion()  // 成功時にコールバックを呼び出す
                } catch {
                    print("Failed to create CSV file: \(error)")
                    completion()  // 失敗時にもコールバックを呼び出す
                }
            }
        }else {
            print("Could not find the document directory.")
            completion()
        }
    }
    
    func shareCSVFile(fileURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

// UIColorから値をそれぞれとる
extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue,alpha)
    }
}

