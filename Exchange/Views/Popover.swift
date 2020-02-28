//
//  Popover.swift
//  Exchange
//
//  Created by JimLai on 2020/2/29.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct Popover: View {
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
        }.fill(Color.red).frame(width: popWidth, height: popHeight)
    }
    var popoverRect: some View {
        Rectangle().fill(Color.clear).background(popoverShape).frame(width: popWidth, height: popHeight)
    }
    var body: some View {
        VStack(spacing: 10) {
            Text("test")
            Text("test2")
        }.background(popoverRect).frame(width: popWidth, height: popHeight)
    }
}

struct Popover_Previews: PreviewProvider {
    static var previews: some View {
        Popover()
    }
}
