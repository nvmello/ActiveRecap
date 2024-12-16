//
//  SlidingPageSlideshowView.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/9/24.
//

import SwiftUI

struct SlidingPageSlideshowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var timer: Timer?
    @State private var progress: Double = 0
    let pageDuration: TimeInterval = 8.0
    let totalPages = 5
    
    var body: some View {
        VStack(spacing: 0) {
            CustomPageIndicator(
                totalBars: totalPages,
                currentBar: currentPage,
                progress: progress
            )
            .padding(.top, 80)
            
            TabView(selection: $currentPage) {
                yearSummaryPage
                    .tag(0)
                progressPage
                    .tag(1)
                idkPage
                    .tag(2)
                somethingPage
                    .tag(3)
                stuffPage
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    }
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if currentPage == totalPages - 1 {
                            dismiss()
                        } else {
                            currentPage += 1
                        }
                    }
            }
            
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let horizontalAmount = gesture.translation.width
                    let verticalAmount = gesture.translation.height
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount > 50 && currentPage > 0 {
                            withAnimation {
                                currentPage -= 1
                            }
                        } else if horizontalAmount < -50 {
                            if currentPage == totalPages - 1 {
                                dismiss()
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                    }
                }
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: currentPage) { oldValue, newValue in
            resetTimer()
        }
    }
    private func createSwipeGesture() -> some Gesture {
        DragGesture()
            .onEnded { gesture in
                let horizontalAmount = gesture.translation.width
                let verticalAmount = gesture.translation.height
                
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount > 50 && currentPage > 0 {
                        withAnimation {
                            currentPage -= 1
                        }
                    } else if horizontalAmount < -50 {
                        if currentPage == totalPages - 1 {
                            dismiss()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                }
            }
    }
    
    private func startTimer() {
        progress = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                progress += 0.1 / pageDuration
                if progress >= 1.0 {
                    if currentPage < totalPages - 1 {
                        currentPage += 1
                        progress = 0
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetTimer() {
        progress = 0
        startTimer()
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
