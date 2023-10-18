import Foundation

enum SocketMessageConverter {
    enum Errors: Error {
        case messageGotOnDefaultCase
    }
    
    static func object<T: Decodable>(from socketMessage: URLSessionWebSocketTask.Message) throws -> T {
        return try handle(socketMessage)
    }
}
 
private extension SocketMessageConverter {
    static func handle<T: Decodable>(_ webSocketResponse: URLSessionWebSocketTask.Message) throws -> T {
        var object: T
        
        switch webSocketResponse {
        case .data(let data):
            object = try decode(data)
        case .string(let string):
            object = try decode(string)
        @unknown default:
            throw Errors.messageGotOnDefaultCase
        }
        
        return object
    }
    
    static func decode<T: Decodable>(_ data: Data) throws -> T {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    static func decode<T: Decodable>(_ string: String) throws -> T {
        let data = string.data(using: .utf8)!
        let jsonDecoder = JSONDecoder()
        let object = try jsonDecoder.decode(T.self, from: data)
        return object
    }
}
