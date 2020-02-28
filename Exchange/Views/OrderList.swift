//
//  OrderList.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct OrderList: View {
    @State var data = ["test"]
    @EnvironmentObject var shared: SharedState
    var askList: some View {
        List {
            ForEach(0 ..< data.count) { index in
                Text(self.data[index]).foregroundColor(.green)
            }.listRowBackground(Color.black)
        }
    }
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 0) {
                Header()
                if shared.isPopover {
                    askList.overlay(Popover().offset(x: 5, y: -20).padding(), alignment: .topTrailing)
                }
                else {
                    askList
                }
                    
            }
        }
    }
}

struct OrderList_Previews: PreviewProvider {
    static var previews: some View {
        OrderList()
    }
}
