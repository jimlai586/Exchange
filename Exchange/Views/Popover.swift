//
//  Popover.swift
//  Exchange
//
//  Created by JimLai on 2020/2/29.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct Popover: View {
    @EnvironmentObject var ws: Websocket
    @EnvironmentObject var shared: SharedState
    var popWidth: CGFloat {
        80
    }
    var popHeight: CGFloat {
        160
    }
    var popoverShape: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: popWidth/2 - 10, y: 10))
            path.addLine(to: CGPoint(x: popWidth/2, y: 0))
            path.addLine(to: CGPoint(x: popWidth/2 + 10, y: 10))
            path.addLine(to: CGPoint(x: popWidth, y: 10))
            path.addLine(to: CGPoint(x: popWidth, y: popHeight))
            path.addLine(to: CGPoint(x: 0, y: popHeight))
        }.fill(Color.pickerGray).frame(width: popWidth, height: popHeight)
    }
    func onSelected(_ index: Int) {
        ws.onDecimalPlaceChange(index)
        shared.isPopover.toggle()
    }
    var body: some View {
        VStack(spacing: 10) {
            ForEach(1 ..< 5) { index in
                if self.ws.decimalPlaces ?? 0 == index {
                    Button(String(index)) {
                        self.onSelected(index)
                    }.foregroundColor(.yellow)
                } else {
                    Button(String(index)) {
                        self.onSelected(index)
                    }.foregroundColor(.gray)
                }
            }
        }.background(popoverShape).frame(width: popWidth, height: popHeight).clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct Popover_Previews: PreviewProvider {
    static var previews: some View {
        Popover()
    }
}
