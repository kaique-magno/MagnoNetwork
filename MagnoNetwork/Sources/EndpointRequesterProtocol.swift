import Foundation


public typealias EndpointResponseCompletion<T: Decodable> = (Result<T, Error>) -> Void

public protocol EndpointRequesterProtocol {
    func request<S: Endpoint>(endpoint: S, completion: @escaping EndpointResponseCompletion<S.Response>)
    func cancel()
}
