import Foundation

public class AsyncSocketWrapper<T: Decodable>: AsyncSequence, AsyncIteratorProtocol {
    public typealias AsyncIterator = AsyncSocketWrapper
    public typealias Element = T
    
    private let socketStream: SocketStream
    
    public init(socketStream: SocketStream, resultType: T.Type) {
        self.socketStream = socketStream
    }
    
    deinit {
        debugPrint("☠️ AsyncSocketWrapper: \(self)")
    }
    
    public func makeAsyncIterator() -> AsyncSocketWrapper<T> {
        self
    }
    
    public func next() async throws -> T? {
        var itetaror = socketStream.makeAsyncIterator()
        guard let result = try await itetaror.next() else {
            return nil
        }
        let object = try SocketMessageConverter.object(from: result, objectType: T.self)
        return object
    }
}
