//
//  CustomPageIndicator.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/15/24.
//

import SwiftUI

struct CustomPageIndicator: View {
    let totalBars: Int
    let currentBar: Int
    let progress: Double
    let barHeight: CGFloat = 4
    let spacing: CGFloat = 4
    
    var body: some View {
        GeometryReader { screenGeometry in
            let fullWidth = max(screenGeometry.size.width, 0)
            let totalSpacing = spacing * CGFloat(max(totalBars - 1, 0))
            let barWidth = max((fullWidth - totalSpacing) / CGFloat(max(totalBars, 1)), 0)
            
            HStack(spacing: spacing) {
                ForEach(0..<totalBars, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: barWidth, height: barHeight)
                        .overlay(
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(
                                        width: index == currentBar ?
                                            max(barWidth * progress, 0) :
                                            index < currentBar ? barWidth : 0
                                    )
                                    .animation(.linear, value: progress)
                                    .alignmentGuide(.leading) { _ in 0 }
                            }
                        )
                }
            }
            .position(x: fullWidth / 2, y: barHeight / 2)
        }
        .frame(height: barHeight)
    }
}
