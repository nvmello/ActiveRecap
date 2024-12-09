//
//  MenuView.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/9/24.
//
// Is this needed? if so what do we want to see on this screen?
// place holder menu to provide full functionality to landing page


import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedItem: MenuItem? = .home
    
    enum MenuItem: String, CaseIterable {
        case home = "Home"
        case profile = "Profile"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .profile: return "person.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                // Apples system icon set actually goes hard
                // utilize this more for the future
                // more fitness symbols available for use
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 60))
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)
                
                Text("ActiveRecap")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 30)
            .padding(.horizontal)
            
            ForEach(MenuItem.allCases, id: \.self) { item in
                Button(action: {
                    selectedItem = item
                    // need to handle navigation here, a lot of work for mostly optional
                    // logic at this time. Will come back when figured out. 
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: item.icon)
                            .frame(width: 24, height: 24)
                        
                        Text(item.rawValue)
                            .font(.body)
                        
                        Spacer()
                        
                        if selectedItem == item {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(
                        selectedItem == item ?
                        Color.primary.opacity(0.1) :
                        Color.clear
                    )
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colorScheme == .dark ? Color.black : Color.white
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
