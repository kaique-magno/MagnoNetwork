//
//  ContentView.swift
//  MagnoNetworkSample
//
//  Created by Kaique Magno on 20/12/22.
//

import SwiftUI
import MagnoNetwork

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
