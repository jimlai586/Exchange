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
    @EnvironmentObject var ws: Websocket
    var askList: some View {
        List {
            ForEach(ws.asks, id: \.price) { order in
                HStack(alignment: .center) {
                    Text(order.price).foregroundColor(.red)
                    Spacer()
                    Text(order.quantity).foregroundColor(.white).frame(alignment: .trailing)
                }
            }.listRowBackground(Color.black)
        }
    }
    var bidList: some View {
        List {
            ForEach(ws.bids, id: \.price) { order in
                HStack {
                    Text(order.quantity).foregroundColor(.white)
                    Spacer()
                Text(order.price).foregroundColor(.green).frame(alignment: .trailing)
                }
            }.listRowBackground(Color.black)
        }
    }
    var orderList: some View {
        List {
            ForEach(ws.orderRows) { order in
                HStack(spacing: 5) {
                    HStack {
                        Text(order.b.quantity).foregroundColor(.white)
                        Spacer()
                        Text(order.b.price).foregroundColor(.green).frame(alignment: .trailing)
                    }
                    HStack {
                        Text(order.a.price).foregroundColor(.red)
                        Spacer()
                        Text(order.a.quantity).foregroundColor(.white).frame(alignment: .trailing)
                    }
                }.listRowBackground(self.rowBG(CGFloat(order.bqRatio), CGFloat(order.aqRatio)))
            }
        }
    }
    func rowBG(_ lratio: CGFloat, _ rratio: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    Rectangle().fill(Color.black).frame(width: geo.size.width * (1-lratio) * 0.5)
                    Rectangle().fill(Color.ratioDarkGreen).frame(width: geo.size.width * lratio * 0.5)
                    Rectangle().fill(Color.ratioDarkRed).frame(width: geo.size.width * rratio * 0.5)
                    Rectangle().fill(Color.black).frame(width: geo.size.width * (1-rratio) * 0.5)
                }
            }
        }
    }
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 0) {
                Header()
                /*
                HStack(spacing: 0) {
                    bidList

                    if shared.isPopover {
                        askList.overlay(Popover().offset(x: 5, y: -20).padding(), alignment: .topTrailing)
                    }
                    else {
                        askList
                    }
                }
                */
                if shared.isPopover {
                    orderList.overlay(Popover().offset(x: 5, y: -20).padding(), alignment: .topTrailing)
                } else {
                    orderList
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
