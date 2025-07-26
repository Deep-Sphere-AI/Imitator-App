//
//  onnxruntime_swift.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import Foundation
import onnxruntime_objc

class KeypointsInference {
    private let env: ORTEnv
    private var keypointSession: ORTSession?
    private var poseSession: ORTSession?
    
    init?() {
        do {
            env = try ORTEnv(loggingLevel: .warning)
            
            let sessionOptions = try ORTSessionOptions()
            try sessionOptions.setGraphOptimizationLevel(.all)
            
            func loadKeypointModelURL() -> URL? {
                // 1. Locate the Documents directory
                guard let docsURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first
                else {
                    print("Could not find Documents directory")
                    return nil
                }
                
                // 2. Build the full file URL
                let keypointURL = docsURL.appendingPathComponent("keypoints.onnx")
                
                // 3. Check that the file actually exists there
                guard FileManager.default.fileExists(atPath: keypointURL.path) else {
                    print("Keypoint model not found at \(keypointURL.path)")
                    return nil
                }
                
                return keypointURL
            }
            guard let keypointURL = loadKeypointModelURL() else { return nil }
            
            keypointSession = try ORTSession(env:env, modelPath: keypointURL.path, sessionOptions: sessionOptions)
            
            func loadPoseModelURL() -> URL? {
                // 1. Locate the Documents directory
                guard let docsURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)
                    .first
                else {
                    print("Could not find Documents directory")
                    return nil
                }
                
                // 2. Build the full file URL
                let poseURL = docsURL.appendingPathComponent("pose.onnx")
                
                // 3. Check that the file actually exists there
                guard FileManager.default.fileExists(atPath: poseURL.path) else {
                    print("Pose model not found at \(poseURL.path)")
                    return nil
                }
                
                return poseURL
            }
            guard let poseURL = loadPoseModelURL() else { return nil }
                        
            poseSession = try ORTSession(env:env, modelPath: poseURL.path, sessionOptions: sessionOptions)

        } catch {
            print("Failed to initialize ORTEnv: \(error)")
            return nil
        }
    }
    
    private func runInference(session: ORTSession, input: [Float], shape: [NSNumber]) -> [Float]? {
        do {
            let inputCount = input.count * MemoryLayout<Float>.stride
            let inputData = NSMutableData(bytes: input, length: inputCount)
            let inputTensor = try ORTValue(tensorData: inputData, elementType: .float, shape: shape)
            
            guard let inputName = (try session.inputNames().first),
                  let outputName = (try session.outputNames().first) else {
                print("Could not get input/output")
                return nil
            }
            
            let outputs = try session.run(withInputs: [inputName: inputTensor], outputNames: [outputName], runOptions: nil)
            guard let outputValue = outputs[outputName] else {
                print("Could not read output")
                return nil
            }
            
            let outputData  = try outputValue.tensorData()
            let data = outputData as Data
            
            let outputArray = data.withUnsafeBytes {
                Array($0.bindMemory(to: Float.self))
            }
         
            return outputArray
            
        } catch let error {
            print("Inference Failed: \(error)")
            return nil
        }
    }
    
    func runKeypoint(inputImage: [Float], shape: [NSNumber]) -> [Float]? {
        guard let session = keypointSession else {
            print("Keypoint Session not loaded")
            return nil
        }
        return runInference(session: session, input: inputImage, shape: shape)
    }

    func runPose(inputImage: [Float], shape: [NSNumber]) -> [Float]? {
        guard let session = poseSession else {
            print("Keypoint Session not loaded")
            return nil
        }
        return runInference(session: session, input: inputImage, shape: shape)
    }
}
