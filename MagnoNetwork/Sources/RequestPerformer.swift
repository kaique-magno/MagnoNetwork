import Foundation

public protocol RequestPerformer {
    func perform(request: URLRequest) async throws -> (Data, URLResponse)
    func performSocket<T: Decodable>(task: URLSessionWebSocketTask, withResultType: T.Type) async throws -> AsyncThrowingMapSequence<SocketStream, T>
}

public struct URLSessionRequestPerformer {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

extension URLSessionRequestPerformer: RequestPerformer {
    public func perform(request: URLRequest) async throws -> (Data, URLResponse) {
        let taskResult = try await session.data(for: request)
        return taskResult
    }
    
    public func performSocket<T: Decodable>(task: URLSessionWebSocketTask, withResultType: T.Type) async throws -> AsyncThrowingMapSequence<SocketStream, T> {
        let socketStream = SocketStream(task: task)
       
        let socketMap: AsyncThrowingMapSequence<SocketStream, T> = socketStream.map { message in
            let object: T = try SocketMessageConverter.object(from: message)
            return object
        }
        
        return socketMap
    }
}
