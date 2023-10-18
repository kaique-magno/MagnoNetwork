import Foundation

public typealias WebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>

extension URLSessionWebSocketTask {
    
    /**
     Return an asynchronous sequence closure that calls a continuation to produce new elements from an error-throwing closure. 
     The element of this closure is a WebSocketTask with the result of the socket.
     */
    var stream: WebSocketStream {
        WebSocketStream { continuation in
            Task {
                var isAlive = true

                while isAlive && closeCode == .invalid {
                    do {
                        let value = try await receive()
                        continuation.yield(value)
                    } catch {
                        continuation.finish(throwing: error)
                        isAlive = false
                    }
                }
            }
        }
    }
}
