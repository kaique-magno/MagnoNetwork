import Foundation

enum RequestFactory { }

//MARK: - REST
extension RequestFactory {
    static func generateURLRequest(fromEndpoint endpoint: any Endpoint,
                                   cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                                   timeoutInterval: TimeInterval = 5.0) throws -> URLRequest {
        // Generate URL
        guard let url = endpoint.url else {
            throw MagnoNetworkErrors.nilURL
        }
        
        // Generate Request
        var request = URLRequest(url: url,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.httpMethod.rawValue
        request = addHeaders(from: endpoint, in: request)
        return request
    }
}

//MARK: - Socket
extension RequestFactory {
    static func generateSocketTask(fromEndpoint endpoint: any Endpoint,
                                   session: URLSession,
                                   protocols: [String] = []) throws -> URLSessionWebSocketTask {
        // Generate URL
        guard let url = endpoint.url else {
            throw MagnoNetworkErrors.nilURL
        }
        
        // Generate Request
        let socketTask = session.webSocketTask(with: url, protocols: protocols)
        return socketTask
    }
}

//MARK: - Private function
private extension RequestFactory {
    
    //MARK: Modifying Requests
    static func addHeaders(from endpoint: any Endpoint, in request: URLRequest) -> URLRequest {
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
    
    static func add(headers: HTTPHeaders, in request: URLRequest) -> URLRequest {
        var multableRequest = request
        for (headerKey, headerValue) in headers {
            multableRequest.setValue(headerValue, forHTTPHeaderField: headerKey)
        }
        return multableRequest
    }
}
