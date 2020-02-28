//
//  MarketList.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct MarketList: View {
    @State var data = ["market"]
    var body: some View {
        ZStack {
            Color.black
            List {
                ForEach(0 ..< data.count) { index in
                    Text(self.data[index]).foregroundColor(.green)
                }.listRowBackground(Color.black)
            }
        }
    }
}

struct MarketList_Previews: PreviewProvider {
    static var previews: some View {
        MarketList()
    }
}
