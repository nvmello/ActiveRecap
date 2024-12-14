//
//  SlidingPageSlideshowView.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/9/24.
//

import SwiftUI

struct SlidingPageSlideshowView: View {
    var body: some View {
        TimerPageView(pages: [
            AnyView(yearSummaryPage),
            AnyView(progressPage),
            AnyView(idkPage),
            AnyView(somethingPage),
            AnyView(stuffPage)
        ])
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
    
    private var yearSummaryPage: some View {
        VStack {
            Spacer()
            Text("Year Summary")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var progressPage: some View {
        VStack {
            Spacer()
            Text("Progress")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var idkPage: some View {
        VStack {
            Spacer()
            Text("idk what to put here")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var somethingPage: some View {
        VStack {
            Spacer()
            Text("something I guess?")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var stuffPage: some View {
        VStack {
            Spacer()
            Text("Stuff but the end of stuff")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
