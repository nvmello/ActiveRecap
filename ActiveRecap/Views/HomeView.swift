//
//  HomeView.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/9/24.
//
// Home view, either individual or part of sliding page template.

import SwiftUI

struct HomeView: View {
    @State private var showMenu = false
    @State private var showingYearReview = false
    
    // Calculate if current day is Dec 5th
    // can set to false for testing EoY or not
    var isLateYear: Bool {
        // test if wrapped
        return dayOfYear > 340
        
        // test if not
        // return false;
    }
    
    var dayOfYear: Int {
        let calendar = Calendar.current
        let today = Date()
        return calendar.ordinality(of: .day, in: .year, for: today) ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    // Day indicator header
                    HStack {
                        Button(action: { showMenu.toggle() }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        // should this be centered???
                        Text("\(dayOfYear)/365")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    // Wrapped component, only visible if day is > 340
                    if isLateYear {
                        Button {
                            showingYearReview = true
                        } label: {
                            VStack {
                                Text("Your 2024 Review")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Tap to view your year!")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .fullScreenCover(isPresented: $showingYearReview) {
                            SlidingPageSlideshowView()
                        }
                    }
                    
                    // Data "year so far" visulations
                    // Just a placeholder but we can work in this area
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("Progress So Far")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(value: "playground") {
                        Text("Playground")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
                // for menu only, will likely create seperate component to handle
                if showMenu {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showMenu = false
                        }
                    
                    HStack {
                        MenuView()
                            .frame(width: 250)
                            .background(Color.black)
                            .offset(x: showMenu ? 0 : -250)
                            .animation(.default, value: showMenu)
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "playground" {
                    DataPlayground()
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}
