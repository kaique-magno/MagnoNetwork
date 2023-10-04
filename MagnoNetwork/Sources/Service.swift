import Foundation

public protocol ServiceInterface {
    func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error>
}

public class Service {
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
            let (data, response) = try await requestPerformer.perform(request: request)
            debugPrint(response)
            
            guard let object: EndpointType.Response = try self.handle(data: data) else {
                return .failure(MagnoNetworkErrors.emptyResult)
            }
        
            return .success(object)
            
        } catch {
            return .failure(error)
        }
    }
    
    public func cancel() {
        task?.cancel()
    }
}


