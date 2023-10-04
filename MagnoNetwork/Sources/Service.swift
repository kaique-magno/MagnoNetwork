import Foundation

protocol ServiceInterface {
    func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error>
}

class Service {
    private var task: URLSessionTask?
    
    private let requestPerformer: RequestPerformer
    
    public init(requestPerformer: RequestPerformer = URLSessionRequestPerformer()) {
        self.requestPerformer = requestPerformer
    }
}

private extension Service {
    func handle<T: Decodable>(data: Data?) throws -> T? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        var decodedObject: T?
        do {
            decodedObject = try decoder.decode(T.self, from: data)
        } catch {
            debugPrint(error)
            throw error
        }
        return decodedObject
    }
}

extension Service: ServiceInterface {
    public func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error> {
        let requestFactory = RequestFactory(endpoint: endpoint)
        var request: URLRequest
        
        do {
            request = try requestFactory.generateURLRequest()
        } catch {
            return .failure(error)
        }
        
        var fetchResult: Result<EndpointType.Response, Error>?
        let task = requestPerformer.perform(request: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let response = response {
                debugPrint(response)
            }
            
            if let error = error {
                fetchResult = .failure(error)
            }
            do {
                guard let object: EndpointType.Response = try self.handle(data: data) else {
                    return
                }
                fetchResult = .success(object)
            } catch {
                fetchResult = .failure(error)
            }
        }
        
        task.resume()
        
        guard let fetchResult = fetchResult else {
            return .failure(Errors.nilResponse)
        }
        
        return fetchResult
    }
    
    public func cancel() {
        task?.cancel()
    }
}


