//
//  CalendarDetailView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 08/06/2021.
//

import SwiftUI

struct CalendarDetailView: View {
    let event: Event
    
    var body: some View {
        Text(verbatim: event.description)
    }
}

struct CalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(event: Event(name: "O&O", description: "Naar de les", start: Date(), location: "HUB"))
    }
}
