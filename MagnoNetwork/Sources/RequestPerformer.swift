import Foundation

public protocol RequestPerformer {
    func perform(request: URLRequest) async throws -> (Data, URLResponse)
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
}
