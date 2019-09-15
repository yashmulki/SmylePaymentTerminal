import UIKit
import Vision
import AVFoundation


enum DetectionStatus {
    case no, yes, multiple
}

class PrepaymentViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, MessagingProtocol {
    
    
    func readMessage(message: String) {
        
    }
    var isReading = true
    
    @IBOutlet var crossmark: UIImageView!
    @IBOutlet var checkmark: UIImageView!
    
    @IBOutlet var promptView: contentView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var faceView: contentView!
    @IBOutlet var progressView: KDCircularProgress!
    
    
    @IBAction func force(_ sender: Any) {
        self.photoDataOutput.capturePhoto(with: .init(), delegate: self)
    }
    
    private let context = CIContext()
    
    private var previousStatus: DetectionStatus = .no
    private var status: DetectionStatus = .no
    
    private var user: User?
    
    var progress = 0.0
    var timer: Timer?
    
    // Photo output stuff
    private let photoDataOutput = AVCapturePhotoOutput()
    
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.faceView.transform = CGAffineTransform(rotationAngle: CGFloat(-1 * Double.pi/2))
        self.previewLayer.frame = self.faceView.bounds
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        self.captureSession.addOutput(self.photoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .landscapeRight
    }
    
    private func detectFace(in image: CVPixelBuffer, sampleBuffer: CMSampleBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results, sampleBuffer)
                } else {
                  
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation], _ sampleBuffer: CMSampleBuffer) {
        
        if observedFaces.count > 0 && observedFaces[0].landmarks == nil {
            return
        }
        
        let numFaces = observedFaces.count
        
        if !isReading {
            return
        }
        
        if numFaces == 1 {
            statusLabel.text = "Perfect!"
            status = .yes
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.isReading = false
                 self.photoDataOutput.capturePhoto(with: .init(), delegate: self)
            }
            
            detectedFace(sampleBuffer)
        } else if numFaces == 0 {
            status = .no
            redisplayPrompt()
            statusLabel.text = "Please Look at the Camera"
        } else {
            status = .multiple
            redisplayPrompt()
            statusLabel.text = "Only One Person Please!"
        }
        
        
        
    }
    
    
    func detectedFace(_ buffer: CMSampleBuffer) {
        
        if status == previousStatus {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.4) {
                self.promptView.alpha = 0
                self.progressView.alpha = 1
                self.faceView.alpha = 1
            }
            
//            self.photoDataOutput.capturePhoto(with: .init(), delegate: self)
        }
        
        previousStatus = status
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let photoMetadata = photo.metadata
        // Returns corresponting NSCFNumber. It seems to specify the origin of the image
        //                print("Metadata orientation: ",photoMetadata["Orientation"])
        
        // Returns corresponting NSCFNumber. It seems to specify the origin of the image
        
        
        
        print("Metadata orientation with key: ",photoMetadata[String(kCGImagePropertyOrientation)] as Any)
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
            
        }
        
        guard let uiImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
            
        }
        
        // generate a corresponding CGImage
        guard let cgImage = uiImage.cgImage else {
            print("Error generating CGImage")
            return
            
        }
  
        
        let lastPhoto = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01
            , repeats: true, block: { (timer) in
                self.progress += 1
                self.progressView.angle = self.progress
        })
        self.uploadAndCheck(image: lastPhoto)
        
       
        captureSession.stopRunning()
    }
    
    func redisplayPrompt() {
        
        if status == previousStatus {
            return
        }
        
        UIView.animate(withDuration: 0.4) {
            self.promptView.alpha = 1
            self.faceView.alpha = 0
            self.progressView.alpha = 0
        }
        
        switch status {
        case .multiple:
            statusLabel.text = "Only One Person Please!"
        case .no:
             statusLabel.text = "Please Look at the Camera"
        default:
            print("This shouldn't happen")
        }
        
        previousStatus = status
        
    }
    
    func uploadAndCheck(image: UIImage) {
       
        // Encode
        let imageData:Data = image.jpegData(compressionQuality: 0.2)!
        let strBase64 = imageData.base64EncodedString(options: .endLineWithCarriageReturn)
        
    
        
        // Upload
        let url = URL(string: "http://34.66.144.105/identify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let json = ["image": strBase64]
        let serializer = JSONEncoder()
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let data = try serializer.encode(json)
            request.httpBody = data
            
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("error: \(error)")
                } else {
                    if let response = response as? HTTPURLResponse {
                        print("statusCode: \(response.statusCode)")
                    }
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print("data: \(dataString)")
                        let serializer = JSONDecoder()
                        do {
                            let decrypted = try serializer.decode(User.self, from: data)
                            
                            DispatchQueue.main.async {
                                self.timer?.invalidate()
                                self.recognized(user: decrypted)
                            }
                            
                        } catch {
                            DispatchQueue.main.async {
                                  self.timer?.invalidate()
                                  self.unrecognized()
                            }
                          
                        }
                    }
                    
                   
                }
            }
            task.resume()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.recognized(user: User(name: "Fred", cards: [Card(number: "1234567891234567", cvv: 123, from: "Visa"), Card(number: "1234567891234567", cvv: 123, from: "Mastercard"), Card(number: "1234567891234567", cvv: 123, from: "American Express")], birthdate: "Yeet"))
//            }
           
            
        } catch {
            
        }
        
        
    }
    
    
    func unrecognized() {
        captureSession.stopRunning()
        UIView.animate(withDuration: 0.4, animations: {
            self.faceView.alpha = 0
            self.progressView.alpha = 0
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                self.crossmark.alpha = 1.0
            }) { (done) in
                self.performSegue(withIdentifier: "notrecog", sender: self)
            }
        }
    }
    
    func recognized(user: User) {
        captureSession.stopRunning()
        UIView.animate(withDuration: 0.4, animations: {
            self.faceView.alpha = 0
            self.progressView.alpha = 0
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                self.checkmark.alpha = 1.0
            }) { (done) in
                self.user = user
                self.performSegue(withIdentifier: "confirm", sender: self)
            }
        }
    }
    
}

extension PrepaymentViewController {
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .front).devices.first else {
                fatalError("No front camera device found")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.cornerRadius = 180
                self.faceView.layer.addSublayer(self.previewLayer)
                self.previewLayer.frame = self.faceView.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame, sampleBuffer: sampleBuffer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? RecognizedViewController {
            des.user = self.user
            des.configure()
        }
    }
    
}
