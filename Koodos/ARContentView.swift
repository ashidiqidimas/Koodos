//
//  ARContentView.swift
//  Koodos
//
//  Created by Rizki Samudra on 26/03/23.
//

import Foundation
import SwiftUI

struct ARContentView: View {
    let cards: [ImageFirebase]

    var body: some View {
        
        ARViewContainer(cards: cards) // pass the images to be displayed on the board here
    }
}


struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView(cards: [])
    }
}
