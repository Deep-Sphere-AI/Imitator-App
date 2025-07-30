//
//  CameraViewController.swift
//  TestiOS
//
//  Created by Giorgio Mancusi on 7/28/25.
//

import SwiftUI
import SwiftCameraKit
import AVFoundation
import Combine

final class CameraViewController: UIViewController {
    private var cameraKit: SwiftCameraKit?
    private var cameraConfig: SwiftCameraKitConfig!
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    var onImageCaptured: ((UIImage) -> Void)?
    var onVideoCaptured: ((URL) -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    private func setupCamera() {
        cameraConfig = SwiftCameraKitConfig(
            videoSettings: SwiftCameraKitConfig.VideoSettings(
                videoSessionPreset: .high,
                maxVideoRecordingDuration: 60,
                videoGravity: .resizeAspectFill
            )
        )
        cameraKit = SwiftCameraKit(view: view, configs: cameraConfig)
        
        Task {
            switch await cameraKit?.grantAccessForCameraAndAudio() {
            case .success:
                await MainActor.run {
                    cameraKit?.setupSessionAndCamera()
                    
                    cameraKit?.$state
                      .receive(on: DispatchQueue.main)
                      .sink { [weak self] state in
                        if case .videoOutput(let url) = state {
                          print("▶️ Video URL:", url)
                          self?.onVideoCaptured?(url)
                        }
                      }
                      .store(in: &cancellables)
                }
            default:
                print("Camera Access Failed")
            }
        }
    }
    
    func startRecording() {
      print("🔴 Recording started")
      cameraKit?.startVideoRecording()
    }
    func stopRecording() {
      print("⏹ Recording stopped")
      cameraKit?.stopVideoRecording()
    }
    func changeCamera() {
      print("🔄 Switching camera")
      cameraKit?.switchCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let kit = cameraKit else { return }
        kit.stopCaptureSession()
        cameraKit = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll()
    }
    
    deinit {
        guard let kit = cameraKit else { return }
        kit.stopCaptureSession()
        kit.reset()
        cameraKit = nil
    }
}

#Preview {
    CameraViewController()
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var cameraVC: CameraViewController?
    @Binding var recordedVideoURL: URL?

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        
        // Video callback
        vc.onVideoCaptured = { url in
            DispatchQueue.main.async {
                self.recordedVideoURL = url
                print(url)
            }
        }
        
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController,
                                context: Context) {
        // Now that SwiftUI has laid out the view,
        // safely bind the controller to your @State
        DispatchQueue.main.async {
            self.cameraVC = uiViewController
        }
    }
}
