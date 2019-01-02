//
//  ViewController.swift
//  mlexp
//
//  Created by Yamin Wei on 12/25/18.
//  Copyright © 2018 Yamin Wei. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let model = try? VNCoreMLModel(for: Inceptionv3().model)
    
    // IBOutlets
    @IBOutlet weak var classLabel: UILabel! {
        didSet {
            classLabel.isExclusiveTouch = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(captureOutput)
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        captureSession.startRunning()
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print("haha", Date())
        //guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { return }
        
        guard let model = self.model else { return }
        
        let request = VNCoreMLRequest(model: model){ (finishedReq, err) in
            //perhaps check the err
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            //print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                self.classLabel.text = firstObservation.identifier
            }
        }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @IBAction func actionClassLabelTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel, let classString = label.text else {
            return
        }
        
        guard let url = URL(string: "https://en.wikipedia.org/wiki/\(classString)") else {
            return
        }
        
        UIApplication.shared.openURL(url)
    }
}

