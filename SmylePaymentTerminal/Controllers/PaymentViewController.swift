//
//  PaymentViewController.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-13.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import UIKit
import AVKit
import FirebaseMLVision
import AVFoundation

// cvCollectionView
class PaymentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, MessagingProtocol {
    
    var jsonData: String = ""
    
    var player: AVAudioPlayer?
    var selectedIndexPath = 0
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "payment_success", withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            player?.volume = 1.0
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private lazy var vision = Vision.vision()
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    func readMessage(message: String) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addCameraInput()
        self.getCameraFrames()
        self.captureSession.startRunning()
        
        
        jsonData = jsonData.replacingOccurrences(of: "payment", with: "")
        
        let decoder = JSONDecoder()
        let modded = jsonData//.replacingOccurrences(of: "\"", with: "")
        let data = modded.data(using: .utf8)!
        
        do {
            let items = try decoder.decode([Item].self, from: data)
            self.items = items
            for item in items {
                totalCost += item.cost
            }
        } catch {
            print(error)
        }
        
        self.invoiceCollectionView.reloadData()
        
        self.cvCollectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .centeredVertically)
          self.cvCollectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
    }
    
    @IBOutlet var cvCollectionView: UICollectionView!
    
    @IBOutlet var invoiceCollectionView: UICollectionView!
    
    var cards: [Card]?
    var items: [Item] = []
    var totalCost = 0.0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == invoiceCollectionView {
            return items.count + 1
        }
        
        guard let cards = cards else {
            return 0
        }
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == invoiceCollectionView {
            if indexPath.row == 0 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "total", for: indexPath) as! InvoiceTotalCollectionViewCell
                cell.configure(total: totalCost)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! InvoiceCollectionViewCell
                cell.configure(price: items[indexPath.row - 1].cost, name: items[indexPath.row - 1].name)
                return cell
            }
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! CardCollectionViewCell
        cell.setDetails(card: cards?[indexPath.row] ?? Card(number: "Yee", cvv: 011, from: "Yote"))
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.snapToNearestCell(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.snapToNearestCell(scrollView: scrollView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cvCollectionView.dataSource = self
        cvCollectionView.delegate = self
       
        
       invoiceCollectionView.dataSource = self
        
        invoiceCollectionView.delegate = self
        cvCollectionView.alwaysBounceVertical = false
        cvCollectionView.isDirectionalLockEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    func snapToNearestCell(scrollView: UIScrollView) {
        let middlePoint = Int(scrollView.contentOffset.x + UIScreen.main.bounds.width / 2)
        if let indexPath = self.cvCollectionView.indexPathForItem(at: CGPoint(x: middlePoint, y: 0)) {
            self.cvCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.selectedIndexPath = indexPath.row
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PaymentViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .landscapeRight
    }
    
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
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
            let options = VisionFaceDetectorOptions()
            options.performanceMode = .fast
            options.landmarkMode = .all
            options.classificationMode = .all
            
            let faceDetector = vision.faceDetector(options: options)
          
            let visionImage = VisionImage(buffer: sampleBuffer)
            faceDetector.process(visionImage) { (faces, error) in
                guard error == nil, let faces = faces, !faces.isEmpty else {
                    return
                }
                
                for face in faces {
                    if face.hasSmilingProbability {
                        let smileProb = face.smilingProbability
                        if (smileProb > 0.7) {
                            
                        DispatchQueue.main.async {
                                self.playSound()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                self.captureSession.stopRunning()
                                self.pay()
                            })
                        }
                    }
                }
            }
            
            
        
    }
    
    func pay() {
        DispatchQueue.main.async {
            guard let cards = self.cards else {
                return
            }
            manager.sendMessage(message: "\(cards[self.selectedIndexPath].number)")
            self.performSegue(withIdentifier: "paid", sender: self)
        }
    }
    
}
