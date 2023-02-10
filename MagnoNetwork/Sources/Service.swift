import Foundation

public class Service {
    private var task: URLSessionTask?
    
    private let requestPerformer: RequestPerformer
    
    public init(requestPerformer: RequestPerformer = URLSessionRequestPerformer()) {
        self.requestPerformer = requestPerformer
    }
}

private extension Service {
    func handle<T: Decodable>(data: Data?) -> T? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        var decodedObject: T?
        do {
            decodedObject = try decoder.decode(T.self, from: data)
        } catch {
            debugPrint(error)
        }
        return decodedObject
    }
}

extension Service: EndpointRequesterProtocol {
    public func request<S: Endpoint>(endpoint: S, completion: @escaping EndpointResponseCompletion<S.Response>) {
        let requestFactory = RequestFactory(endpoint: endpoint)
        var request: URLRequest
        
        do {
            request = try requestFactory.generateURLRequest()
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = requestPerformer.perform(request: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let response = response {
                debugPrint(response)
            }
            if let error = error {
                completion(.failure(error))
            }
            if let object: S.Response = self.handle(data: data) {
                completion(.success(object))
            }
        }
        
        task.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
}


