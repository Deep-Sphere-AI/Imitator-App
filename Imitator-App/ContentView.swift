//
//  ContentView.swift
//  Imitator-App
//
//  Created by Giorgio Mancusi on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    
    var body: some View {
        Group {
                VStack(spacing: 0) {
                    CameraView()
                    //ChatView()
                }
            }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ChatWithKeypointsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            ContentView()
               .previewDevice("iPhone 14 Pro")
        }
    }
}
