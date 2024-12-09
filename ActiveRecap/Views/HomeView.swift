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
    @State private var currentPage = 0
    
    // Calculate if current day is Dec 5th
    var isLateYear: Bool {
        return dayOfYear > 340
    }
    
    var dayOfYear: Int {
        let calendar = Calendar.current
        let today = Date()
        return calendar.ordinality(of: .day, in: .year, for: today) ?? 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Day indicator header
                    HStack {
                        Button(action: { showMenu.toggle() }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        // should this be centered???
                        Text("\(dayOfYear)/365")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    if isLateYear {
                        // Sliding page template, only visible if day is > 340
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.primary : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top)
                    }
                    
                    // Wrapped component, only visible if day is > 340
                    if isLateYear {
                        Text("Year End Review Component")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    // Data "year so far" visulations
                    // Just a placeholder but we can work in this area
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("Progress So Far")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                        .padding()
                    
                    Spacer()
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
                            .background(Color(.systemBackground))
                            .offset(x: showMenu ? 0 : -250)
                            .animation(.default, value: showMenu)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
