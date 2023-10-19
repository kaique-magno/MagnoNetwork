import Foundation

public protocol RequestPerformer {
    func perform(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask
    func performSocket<T: Decodable>(task: URLSessionWebSocketTask, withResultType: T.Type) async throws -> AsyncSocketWrapper<T>
}

public class URLSessionRequestPerformer: NSObject {
    private var socketStream: SocketStream?
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

extension URLSessionRequestPerformer: RequestPerformer {
    public func perform(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        return session.dataTask(with: request, completionHandler: completion)
    }
    
    public func performSocket<T: Decodable>(task: URLSessionWebSocketTask, withResultType: T.Type) async throws -> AsyncSocketWrapper<T> {
        let socketStream = SocketStream(task: task)
        self.socketStream = socketStream
        
        let socketWrapper = AsyncSocketWrapper(socketStream: socketStream, resultType: T.self)
        
        return socketWrapper
    }
}
