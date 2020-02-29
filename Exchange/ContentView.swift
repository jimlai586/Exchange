//
//  ContentView.swift
//  Exchange
//
//  Created by JimLai on 2020/2/27.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var selected = 0
    @EnvironmentObject var shared: SharedState
    @EnvironmentObject var ws: Websocket
    var titles = ["Order Book", "Market History"]
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.top)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0 ..< titles.count) { index in
                        Spacer()
                        if index == self.selected {
                            Button(self.titles[index]) {
                                self.selected = index
                            }.background(Color.black).foregroundColor(.yellow).padding().overlay(Rectangle().fill(Color.yellow).frame(width: 40, height: 2).offset(x: 0, y: 20))
                        } else {
                            Button(self.titles[index]) {
                                self.selected = index
                            }.background(Color.black).foregroundColor(.gray).padding()
                        }
                        Spacer()
                    }
                }
                if selected == 0 {
                    OrderList().transition(.slide)
                }
                else {
                    MarketList().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                
                
            }.frame(maxWidth: .infinity).background(Color.black).alert(isPresented: $ws.showNetworkAlert) {
                Alert(title: Text("The Internet connection appears to be offline"), dismissButton: nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
