//
//  MaterialContainerView.swift
//  Koodos
//
//  Created by Dimas on 25/03/23.
//

import SwiftUI

//
//  MaterialContainerView.swift
//  Board SwiftUI
//
//  Created by Dimas on 25/03/23.
//

import SwiftUI

/// The view that will be rendered on the board
struct MaterialContainerView: View {
    let cards: [Image]
    
    let columns = [
        GridItem(.adaptive(minimum: 240))
    ]
    
    var body: some View {
        ZStack {
            Color.white

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<cards.count) { index in
                    cards[index]
                        .resizable()
                        .position(x: 0, y: 0)
                        .frame(width: 240, height: 240 * 16 / 9)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding(240)
            .frame(width: 2048, height: 2048)
        }
    }
}

