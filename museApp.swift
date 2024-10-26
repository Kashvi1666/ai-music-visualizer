//
//  museApp.swift
//  muse
//
//  Created by Kashvi Swami on 6/2/24.
//

import SwiftUI

@main
struct museApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
