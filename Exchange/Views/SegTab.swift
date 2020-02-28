//
//  SegTab.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct SegTab: View {
    var selected = true
    var title = "test"
    var color: Color {
        selected ? Color.yellow : Color.gray
    }
    var body: some View {
        VStack {
            Text(title).foregroundColor(color)
        }.background(Color.black)
        
    }
}

struct SegTab_Previews: PreviewProvider {
    static var previews: some View {
        SegTab()
    }
}
