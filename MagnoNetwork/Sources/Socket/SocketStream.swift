//This code was inspirided by this Article https://www.donnywals.com/iterating-over-web-socket-messages-with-async-await-in-swift/

import Foundation

//MARK: - SocketStream

/**
 An AsyncSequence that brings the results of a WebSocket
 
  - Author: This code was inspirided by this [Donny Wals article]( https://www.donnywals.com/iterating-over-web-socket-messages-with-async-await-in-swift/)
 
 
 # Example
 Use the code below as example of getting the results of a SocketStream
 ````swift
let url = URL(string: "wss://your-socket-address")!
let session = URLSession.shared
let webSocketTask = session.webSocketTask(with: url)
let socketStram = SocketStram(task: webSocketTask)
 
for await messageSocket in socketStream {
     switch message {
     case .data(let data):
         debugPrint(String(data: data, encoding: .utf8))
     case .string(let string):
         debugPrint(string)
     @unknown default:
         debugPrint("In Default")
     }
}
 ````
 */
public class SocketStream {
    private var streamContinuation: WebSocketStream.Continuation?
    private let task: URLSessionWebSocketTask
    
    private lazy var stream: WebSocketStream = {
        return WebSocketStream { streamContinuation in
            self.streamContinuation = streamContinuation
            waitNextValue()
        }
    }()
    
    public init(task: URLSessionWebSocketTask) {
        self.task = task
        task.resume()
    }
    
    deinit {
        streamContinuation?.finish()
    }
}

//MARK: - Private functions
private extension SocketStream {
    func waitNextValue() {
        guard task.closeCode == .invalid else {
            streamContinuation?.finish()
            return
        }

        task.receive(completionHandler: { [weak self] result in
            guard let continuation = self?.streamContinuation else {
                return
            }

            do {
                let message = try result.get()
                continuation.yield(message)
                self?.waitNextValue()
            } catch {
                continuation.finish(throwing: error)
            }
        })
    }
}

//MARK: - AsyncSequence Protocol
extension SocketStream: AsyncSequence {
    public typealias AsyncIterator = WebSocketStream.Iterator
    public typealias Element = URLSessionWebSocketTask.Message
    
    public func makeAsyncIterator() -> AsyncIterator {
        return stream.makeAsyncIterator()
    }

    public func cancel() async throws {
        task.cancel(with: .goingAway, reason: nil)
        streamContinuation?.finish()
    }
}
