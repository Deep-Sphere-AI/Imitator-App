//
//  CameraView.swift
//  TestiOS
//
//  Created by Giorgio Mancusi on 7/28/25.
//

import SwiftUI
import SwiftCameraKit
import Combine

struct CameraView: View {
  @State private var cameraViewController: CameraViewController?
  @State private var recordedVideoURL: URL?
  @State private var isRecording = false

  var body: some View {
    VStack {
      CameraViewControllerRepresentable(
        cameraVC: $cameraViewController,
        recordedVideoURL: $recordedVideoURL
      )
      HStack(spacing: 50) {
        // Switch camera
        Button {
            print("➡️ Switch tapped, controller exists? \(cameraViewController != nil)")
            cameraViewController?.changeCamera()
        } label: {
          Image(systemName: "camera.rotate")
            .padding().background(.white.opacity(0.7)).clipShape(Circle())
        }
        // Record toggle
        Button {
            print("➡️ Switch tapped, controller exists? \(cameraViewController != nil)")
            if isRecording {
            cameraViewController?.stopRecording()
          } else {
            cameraViewController?.startRecording()
          }
          isRecording.toggle()
        } label: {
          ZStack {
            Circle().stroke(isRecording ? .red : .white, lineWidth: 3).frame(width: 60, height: 60)
            if isRecording {
              Circle().fill(.red).frame(width: 40, height: 40)
            }
          }
        }
      }
      .padding(.bottom, 30)
    }
    .padding()
  }
}
