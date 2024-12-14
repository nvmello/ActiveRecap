//
//  ContentView.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isPulsing = false
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                NavigationLink(destination: DataPlayground()) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                            .frame(width: 200, height: 100)
                        Text("Data Playground")
                            .foregroundColor(.white)
                    }
                    
                    
                }
                
                .transition(.slide) // Add a slide transition
                
            }
            
            .navigationTitle("Home")
            
        }
    }
    
    
}
