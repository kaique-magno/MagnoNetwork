import Foundation

// MARK: - BaseEndpoint

/// A protocol to be used as a Base to other Endpoint
///  - Description: It is possible to use the BaseEndpoint to set the main variables
///  and use in an <code>Endpoint</code> so It has not need to set again a <b>Header</b> or a initial <b>Path</b>
public protocol BaseEndpoint {
    var baseEndpoint: BaseEndpoint? { get }
    var basePath: String { get }
    var headers: HTTPHeaders? { get }
}

public extension BaseEndpoint {
    var baseEndpoint: BaseEndpoint? { nil }
}

// MARK: - Endpoint

/// A protocol to set the main properties of an Endpoint 
public protocol Endpoint {
    associatedtype Response: Decodable
    var path: String { get }
    var baseEndpoint: BaseEndpoint? { get }
    var httpMethod: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var body: Encodable? { get }
}

public extension Endpoint {
    var baseEndpoint: BaseEndpoint? { nil }
    var httpMethod: HTTPMethod { .get }
    var parameters: Parameters? { nil }
    var headers: HTTPHeaders? { nil }
    var body: Encodable? { nil }
}

extension Endpoint {
    //MARK: Modifying URLs
    var url: URL? {
        let urlPath = urlPath(from: self)
        
        guard var url = URL(string: urlPath) else {
            return nil
        }
        
        if let parameters = parameters {
            url = add(parameters: parameters, in: url)
        }
        
        return url
    }
    
    func urlPath(from endpoint: any Endpoint) -> String {
        var urlPath = String()
        
        if let baseEndpoint = endpoint.baseEndpoint {
            urlPath = baseEndpoint.basePath
        }
        
        urlPath = "\(urlPath)\(endpoint.path)"
        
        return urlPath
    }
    
    func add(parameters: Parameters, in url: URL) -> URL {
        var multableURL = url
        
        let queryItems = parameters.map(queryItem(from:))
        multableURL.append(queryItems: queryItems)
        
        return multableURL
    }
    
    func queryItem(from parameter: (key: String, value: Any)) -> URLQueryItem {
        URLQueryItem(name: parameter.key,
                     value: "\(parameter.value)")
    }
}
