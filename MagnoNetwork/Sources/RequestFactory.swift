import Foundation

public struct RequestFactory {
    private let endpoint: any Endpoint
    
    public init(endpoint: any Endpoint) {
        self.endpoint = endpoint
    }
    
    public func generateURLRequest(cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                            timeoutInterval: TimeInterval = 5.0) throws -> URLRequest {
        // Generate URL
        let url = try url(from: endpoint)
        
        // Generate Request
        var request = URLRequest(url: url,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.httpMethod.rawValue
        request = addHeaders(in: request)
        return request
    }
    
    private func url(from endpoint: any Endpoint) throws -> URL {
        let urlPath = urlPath(from: endpoint)
        
        guard var url = URL(string: urlPath) else {
            throw MagnoNetworkErrors.nilURL
        }
        
        if let parameters = endpoint.parameters {
            url = add(parameters: parameters, in: url)
        }
        
        return url
    }
    
    private func urlPath(from endpoint: any Endpoint) -> String {
        var urlPath = String()
        
        if let baseEndpoint = endpoint.baseEndpoint {
            urlPath = baseEndpoint.basePath
        }
        
        urlPath = "\(urlPath)\(endpoint.path)"
        
        return urlPath
    }
    
    private func add(parameters: Parameters, in url: URL) -> URL {
        var multableURL = url
        
        let queryItems = parameters.map(queryItem(from:))
        multableURL.append(queryItems: queryItems)
        
        return multableURL
    }
    
    private func queryItem(from parameter: (key: String, value: Any)) -> URLQueryItem {
        URLQueryItem(name: parameter.key,
                     value: "\(parameter.value)")
    }
    
    private func addHeaders(in request: URLRequest) -> URLRequest {
        var changebleRequest = request
        if let baseEndpoint = endpoint.baseEndpoint,
           let baseHeaders = baseEndpoint.headers {
            changebleRequest = add(headers: baseHeaders, in: request)
        }
        
        if let headers = endpoint.headers {
            changebleRequest = add(headers: headers, in: changebleRequest)
        }
        
        return changebleRequest
    }
    
    private func add(headers: HTTPHeaders, in request: URLRequest) -> URLRequest {
        var multableRequest = request
        for (headerKey, headerValue) in headers {
            multableRequest.setValue(headerValue, forHTTPHeaderField: headerKey)
        }
        return multableRequest
    }
}
