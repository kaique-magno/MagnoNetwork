import Foundation

public protocol RequestPerformer {
    func perform(request: URLRequest, completion: @escaping RequestPerformerCompletion) -> URLSessionDataTask
}

public typealias RequestPerformerCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

public struct URLSessionRequestPerformer {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

extension URLSessionRequestPerformer: RequestPerformer {
    public func perform(request: URLRequest, completion: @escaping RequestPerformerCompletion) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}
