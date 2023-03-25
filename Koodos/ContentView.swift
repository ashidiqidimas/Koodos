//
//  ContentView.swift
//  Koodos
//
//  Created by Dimas on 20/03/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        KudosEditorScreen() // put the logic for uploading the photo on line 738
        
//        ARViewContainer(cards: <#T##[Image]#>) // pass the images to be displayed on the board here
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
