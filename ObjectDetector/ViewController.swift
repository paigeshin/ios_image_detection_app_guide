//
//  ViewController.swift
//  ObjectDetector
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var objectImageView: UIImageView!
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    private let imagePicker = UIImagePickerController()
    
    lazy var request: VNCoreMLRequest = {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Can't load model")
        }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Error making request")
            } else {
                strongSelf.process(request: request)
            }
        }
        return request
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resultsLabel.textColor = .black
        resultsLabel.text = ""
        
    }
    
    @IBAction func findButtonDidTouch(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func takePhotoButtonDidTouch(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }

}

// MARK: - CoreML Related Functions
extension ViewController {
    
    func process(request: VNRequest) {
        guard
            let results = request.results as? [VNClassificationObservation],
            let dominantResult = results.first
        else {
            fatalError("error getting dominant result")
        }
        DispatchQueue.main.async {
            self.resultsLabel.text = "\(Int(dominantResult.confidence * 100))% \(dominantResult.identifier)"
        }
    }
    
    func detectObject(image: UIImage) {
        resultsLabel.text = ""
        
        guard let ciImage = CIImage(image: image) else {
            print("unable to create CIImage")
            return
        }
        
        resultsLabel.text = "Detecting..."
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            objectImageView.image = pickedImage
            
            detectObject(image: pickedImage)
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

