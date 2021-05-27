//
//  EventView.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 27/05/2021.
//

import SwiftUI

struct EventView: View {
    var event: String
    
    var body: some View {
        HStack {
            Text("Hello, world!")
                .padding()
            Text(event)
                .padding()
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
    }
}
