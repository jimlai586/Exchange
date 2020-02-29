//
// Created by JimLai on 2020/2/29.
// Copyright (c) 2020 stargate. All rights reserved.
//

import SwiftUI

struct UID: Hashable {
    let U: Int
    let u: Int
    func isLater(than lastId: Int) -> Bool {
        guard U <= lastId+1, lastId+1 <= u else {return false}
        return true
    }
}

struct DepthItem: CustomStringConvertible {
    var description: String {
        "p: \(p), q: \(q)"
    }

    var price: String {
        String(p)
    }
    var quantity: String {
        String(q)
    }
    let p: Double
    let q: Double
    init(_ p: Double, _ q: Double) {
        self.p = p
        self.q = q
    }
}

struct OrderRow: Identifiable {
    let id: String
    let a: DepthItem
    let b: DepthItem
    let aqRatio: Double
    let bqRatio: Double

    init(_ a: DepthItem, _ b: DepthItem, _ aSum: Double, _ bSum: Double) {
        self.a = a
        self.b = b
        self.id = "\(a.p), \(b.p)"
        // magnify by 10 for visual effect, not accuracy
        aqRatio = Double(Int(a.q * 1000 / aSum)) / 100
        bqRatio = Double(Int(b.q * 1000 / bSum)) / 100
    }
}
