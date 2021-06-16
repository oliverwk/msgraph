//
//  CalendarDetailView.swift
//  snap
//
//  Created by Olivier Wittop Koning on 08/06/2021.
//

import SwiftUI

struct CalendarDetailView: View {
    let event: TeamsEvent
    
    var body: some View {
        Text(verbatim: event.bodyPreview)
    }
}

