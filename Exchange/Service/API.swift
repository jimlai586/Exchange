
import SwiftUI
import Combine

typealias P = Params
typealias PD = [P: Any]
enum Params: String {
    case none, e, E, s, U, u, b, a, p, q, f, l, T, m, M
    case asks, bids, lastUpdateId
}

enum NetError: String, Error {
    case httpError, errorResponse, decodeError, preError
}

typealias Request<T> = AnyPublisher<T, Error>

protocol ResDecodable {
    static func decode(_ data: Data) -> Self?
}

protocol Resource: class {
    associatedtype DataType: ResDecodable
    var url: String { get set }
    var success: ((DataType) -> ())? { get set }
    var fail: ((Error) -> ())? { get set }
    var baseReq: URLRequest? {get}
    func onSuccess(_ cb: @escaping (DataType) -> ()) -> Self
    func onFailure(_ cb: @escaping (Error) -> ()) -> Self
    func preError()
    func post(_ pd: [Params: String]) -> AnyCancellable?
    func get() -> AnyCancellable?
    func request(_ req: URLRequest) -> Request<DataType>
    func sink(_ request: Request<DataType>) -> AnyCancellable
}

extension Resource {
    @discardableResult
    func onSuccess(_ cb: @escaping (DataType) -> ()) -> Self {
        success = cb
        return self
    }

    @discardableResult
    func onFailure(_ cb: @escaping (Error) -> ()) -> Self {
        fail = cb
        return self
    }
    
    var baseReq: URLRequest? {
        guard let url = URL(string: url) else {return nil}
        return URLRequest(url: url)
    }
    
    func request(_ req: URLRequest) -> Request<DataType> {
        URLSession.shared.dataTaskPublisher(for: req).tryMap { result in
            guard let resp = result.response as? HTTPURLResponse, 200 ..< 300 ~= resp.statusCode else {
                throw NetError.errorResponse
            }
            guard let d = DataType.decode(result.data) else {
                throw NetError.decodeError
            }
            return d
        }.eraseToAnyPublisher()
    }

    func preError() {
        DispatchQueue.main.async { [weak self] in
            self?.fail?(NetError.preError)
        }
    }
    func sink(_ request: Request<DataType>) -> AnyCancellable {
        request.receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let e):
                self?.fail?(e)
            }
        }) { [weak self] data in
            self?.success?(data)
        }
    }
}

final class Json: Resource {
    
    typealias DataType = JSON
    
    var fail: ((Error) -> ())?

    var url: String

    var success: ((JSON) -> ())?

    init(_ url: String) {
        self.url = url
    }
    
    func get() -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.httpMethod = "GET"
        return sink(request(req))
    }

    func post(_ urlParams: [Params: String]) -> AnyCancellable? {
        guard var req = baseReq else {
            preError()
            return nil
        }
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        return sink(request(req))
    }

}


public extension Dictionary where Key: RawRepresentable, Key.RawValue == String {
    func toStringKey() -> [String: Any] {
        var d = [String: Any]()
        for k in self.keys {
            let v = self[k]!
            if let x = v as? [Key: Any] {
                d[k.rawValue] = x.toStringKey()
            }
            else {
                d[k.rawValue] = v
            }
        }
        return d
    }
}


