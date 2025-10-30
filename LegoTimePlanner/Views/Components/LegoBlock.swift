//
//  LegoBlock.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import SwiftUI

struct LegoBlock: View {
    let number: Int
    let color: LegoColor
    let size: CGFloat

    var body: some View {
        ZStack {
            // Main block with gradient
            RoundedRectangle(cornerRadius: Constants.blockCornerRadius)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.lightColor,
                            color.mainColor,
                            color.darkColor
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Border
            RoundedRectangle(cornerRadius: Constants.blockCornerRadius)
                .stroke(color.darkColor, lineWidth: 2)
                .frame(width: size, height: size)

            // Number text
            Text("\(number)")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
        }
        .shadow(color: color.glowColor.opacity(0.3), radius: 4, x: 2, y: 2)
    }
}

struct LegoBlock_Previews: PreviewProvider {
    static var previews: some View {
        LegoBlock(number: 1, color: LegoColor.allColors[0], size: 60)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
