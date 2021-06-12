//
//  tmp.swift
//  msgraph
//
//  Created by Olivier Wittop Koning on 12/06/2021.
//

import SwiftUI

struct tmp: View {
    
    private let listItems = [ListItem(), ListItem(), ListItem()]
    @State var selection: Int? = -1
    
    var body: some View {
        NavigationView {
            
            List(listItems.indices) {
                index in
                
                let item = listItems[index]
                let isSelected = (selection ?? -1) == index
                
                NavigationLink(destination: Text("Destination \(index)"),
                               tag: index,
                               selection: $selection) {
                    
                    Text("\(item.name) \(index) \(isSelected ? "selected" : "")")
                    
                }
                
            }
            
        }
        .listStyle(SidebarListStyle())
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                selection = 2
            })
        })
    }
    
}


struct ListItem: Identifiable {
    var id = UUID()
    var name: String = "Some Item"
}

struct tmp_Previews: PreviewProvider {
    static var previews: some View {
        tmp()
    }
}
