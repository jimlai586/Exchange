//
//  Header.swift
//  Exchange
//
//  Created by JimLai on 2020/2/28.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct Header: View {
    @EnvironmentObject var shared: SharedState
    var triangle: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 10, y: 0))
            path.addLine(to: CGPoint(x: 5, y: 10))
            }.fill(Color.yellow).frame(width: 10, height: 10)
    }
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Text("Bid").foregroundColor(.gray).padding()
                Spacer()
            }
            HStack {
                Text("Ask").foregroundColor(.gray).padding()
                Spacer()
                VStack(alignment: .trailing) {
                    HStack(spacing: 5) {
                        Button("Test") {
                            self.shared.isPopover.toggle()
                        }
                        triangle
                    }.padding()
                }
            }
        }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
