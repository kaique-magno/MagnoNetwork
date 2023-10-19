//TODO: Testar public func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error> verifciar se o async está funcionando agora que o session ta usando o completionHandler

import Foundation

public protocol ServiceInterface {
    func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error>
    func requestSocket<EndpointType: Endpoint>(endpoint: EndpointType) async throws -> AsyncThrowingMapSequence<SocketStream, EndpointType.Response>
}

public class Service {
    private var tasks: [URL: URLSessionDataTask] = [:]
    private var socketTasks: [URL: URLSessionWebSocketTask] = [:]
    
    private let requestPerformer: RequestPerformer
    private let session: URLSession
    
    public init(session: URLSession = .shared, requestPerformer: RequestPerformer? = nil) {
        self.session = session
        if let requestPerformer {
            self.requestPerformer = requestPerformer
        } else {
            self.requestPerformer = URLSessionRequestPerformer(session: session)
        }
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

extension Service: ServiceInterface {
    public func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error> {
        do {
            var responseError: Error?
            var object: EndpointType.Response?
            let request: URLRequest = try RequestFactory.generateURLRequest(fromEndpoint: endpoint)
            let task = requestPerformer.perform(request: request) { [weak self] (data, response, error) in
                debugPrint(response ?? "Response null")
                responseError = error
                object = self?.handle(data: data)
            }
            
            add(task, of: endpoint)
            
            task.resume()
            
            if let responseError {
                return .failure(responseError)
            }
            
            if let object  {
                return .success(object)
            }
            
            return .failure(MagnoNetworkErrors.emptyResult)
            
        } catch {
            return .failure(error)
        }
    }
    
    public func requestSocket<EndpointType: Endpoint>(endpoint: EndpointType) async throws -> AsyncThrowingMapSequence<SocketStream, EndpointType.Response> {
        let socketRequest = try RequestFactory.generateSocketTask(fromEndpoint: endpoint, session: session)
        
        let result: AsyncThrowingMapSequence<SocketStream, EndpointType.Response> = try await requestPerformer.performSocket(task: socketRequest,
                                                                                                                             withResultType: EndpointType.Response.self)
        return result
    }
    
    public func cancel(endpoint: some Endpoint) {
        guard let url = endpoint.url else {
            return
        }
        
        if let task = tasks[url] {
            task.cancel()
        } else if let socketTask = socketTasks[url] {
            socketTask.cancel()
        }
    }
}

private extension Service {
    func add(_ task: URLSessionWebSocketTask, of endpoint: any Endpoint) {
        guard let url = endpoint.url else {
            return
        }
        socketTasks[url] = task
    }
    
    func add(_ task: URLSessionDataTask, of endpoint: any Endpoint) {
        guard let url = endpoint.url else {
            return
        }
        tasks[url] = task
    }
}
