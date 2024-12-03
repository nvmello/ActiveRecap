//
//  ContentView.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "dumbbell")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Active Recap")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
