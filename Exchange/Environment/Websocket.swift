//
//  Websocket.swift
//  Exchange
//
//  Created by JimLai on 2020/2/29.
//  Copyright © 2020 stargate. All rights reserved.
//

import SwiftUI
import Starscream
import Combine
import Network


final class Websocket: ObservableObject, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        dp("connected")
        socket.write(string: subscribe)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        dp("disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) else {
            return
        }
        let j = JSON(json)
        dp(j)
        let e = j[P.e].stringValue
        switch e {
        case "aggTrade":
            aggTrade(j)
        case "depthUpdate":
            depthUpdate(j)
        default:
            dp(e)
            return
        }
    }

    func depthUpdate(_ j: JSON) {
        let uid = UID(U: j[P.U].intValue, u: j[P.u].intValue)
        guard let _ = lastUpdateId else {
            buffer[uid] = j
            return
        }
        for a in j[P.a].arrayValue {
            let v = a[1].doubleValue
            askBook[a[0].doubleValue] = v == 0 ? nil : v
        }
        for b in j[P.b].arrayValue {
            let v = b[1].doubleValue
            bidBook[b[0].doubleValue] = v == 0 ? nil : v
        }
    }

    func aggTrade(_ j: JSON) {

    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        dp("data")
    }

    func onReceive(_ s: inout String) {

    }
    
    static var baseUrl = "wss://stream.binance.com:9443"
    static var ethusdt = "/ws/ethusdt"

    var snapshot = Json("https://www.binance.com/api/v1/depth?symbol=ETHUSDT&limit=100")

    @Published var decimalPlaces: Int?

    var multiplier: Double {
        decimalPlaces == nil ? 1 : pow(Double(10), Double(decimalPlaces!))
    }

    var cancellable: AnyCancellable?
    
    var subscribe: String {
        let sub: [String: Any] = ["method": "SUBSCRIBE", "params": ["ethusdt@aggTrade", "ethusdt@depth"], "id": 8159]
        guard let data = try? JSONSerialization.data(withJSONObject: sub, options: .prettyPrinted), let s = String(bytes: data, encoding: .utf8) else {
            dp("subscribe failed")
            return ""
        }
        return s
    }
    var askBook = [Double: Double]()
    var asks: [DepthItem] {
        let newBook = askBook.reduce(into: [Double: Double]()) { (r, kv) in
            let roundedKey = Double(Int(kv.key * multiplier)) / multiplier
            r[roundedKey, default: 0.0] += kv.value
        }.mapValues { v in Double(Int(v * multiplier)) / multiplier }
        return newBook.keys.sorted().map {DepthItem($0, newBook[$0, default: 0])}
    }
    var bidBook = [Double: Double]()
    var bids: [DepthItem] {
        let newBook = bidBook.reduce(into: [Double: Double]()) { (r, kv) in
            let roundedKey = Double(Int(kv.key * multiplier)) / multiplier
            r[roundedKey, default: 0.0] += kv.value
        }.mapValues { v in Double(Int(v * multiplier)) / multiplier }

        return newBook.keys.sorted(by: >).map {DepthItem($0, newBook[$0, default: 0])}
    }
    var buffer = [UID: JSON]()
    @Published var orderRows = [OrderRow]()
    var socket = WebSocket(url: URL(string: Websocket.baseUrl + Websocket.ethusdt)!)
    var refreshInProgress = false
    var lastUpdateId: Int?
    let monitor = NWPathMonitor()
    @Published var showNetworkAlert = false
    init() {
        socket.delegate = self
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                dp("has network connection")
                self.open()
            } else {
                dp("no connection")
                self.noNetworkHandler()
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }

    func noNetworkHandler() {
        showNetworkAlert = true
    }

    func reset() {
        buffer = [:]
        askBook = [:]
        bidBook = [:]
        lastUpdateId = nil
    }

    func open() {
        reset()
        //socket.connect()
        cancellable = snapshot.onSuccess { json in
            dp(json)
            self.update(json)
        }.get()
    }
    func onDecimalPlaceChange(_ newDecimalPlace: Int) {
        decimalPlaces = newDecimalPlace
        orderRows = newOrderRows
    }

    func update(_ json: JSON) {
        askBook = [:]
        bidBook = [:]
        decimalPlaces = 4
        for j in json[P.asks].arrayValue {
            askBook[j[0].doubleValue] = j[1].doubleValue
        }
        for j in json[P.bids].arrayValue {
            bidBook[j[0].doubleValue] = j[1].doubleValue
        }
        let lid = json[P.lastUpdateId].intValue
        lastUpdateId = lid
        for k in buffer.keys {
            guard k.isLater(than: lid) else {continue}
            for j in buffer[k]![P.asks].arrayValue {
                let price = j[0].doubleValue
                let q = j[1].doubleValue
                if askBook[price] == nil {
                    askBook[price] = q
                }
            }
            for j in buffer[k]![P.bids].arrayValue {
                let price = j[0].doubleValue
                let q = j[1].doubleValue
                if bidBook[price] == nil {
                    bidBook[price] = q
                }
            }
        }
        refresh()
    }

    var newOrderRows: [OrderRow] {
        let a = asks
        let b = bids
        let sumA = a.reduce(into: 0.0) { $0 += $1.q}
        let sumB = b.reduce(into: 0.0) { $0 += $1.q}
        let zs = zip(a, b)
        return zs.map {OrderRow($0.0, $0.1, sumA, sumB)}
    }

    func refresh() {
        if refreshInProgress == false {
            refreshInProgress = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.orderRows = self.newOrderRows
                dp(self.orderRows)
                self.refreshInProgress = false
            }
        }
    }
}
