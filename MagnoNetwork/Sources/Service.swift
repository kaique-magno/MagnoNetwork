//TODO: Testar public func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error> verifciar se o async está funcionando agora que o session ta usando o completionHandler

import Foundation

public protocol ServiceInterface {
    func request<EndpointType: Endpoint>(endpoint: EndpointType) async -> Result<EndpointType.Response, Error>
    func requestSocket<EndpointType: Endpoint>(endpoint: EndpointType) async throws -> AsyncSocketWrapper<EndpointType.Response>
    func cancel(endpoint: some Endpoint)
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
        await withCheckedContinuation { continuation in
            let request: URLRequest
            
            do {
                request = try RequestFactory.generateURLRequest(fromEndpoint: endpoint)
            } catch {
                continuation.resume(returning: .failure(error))
                return
            }
            
            let task = requestPerformer.perform(request: request) { [weak self] (data, response, error) in
                debugPrint(response ?? "Response null")
                let object: EndpointType.Response? = self?.handle(data: data)
                
                if let error {
                    debugPrint(error)
                    continuation.resume(returning: .failure(error))
                }
                
                if let object  {
                    debugPrint(object)
                    continuation.resume(returning: .success(object))
                }
            }
            
            add(task, of: endpoint)
            task.resume()
        }
    }
    
    public func requestSocket<EndpointType: Endpoint>(endpoint: EndpointType) async throws -> AsyncSocketWrapper<EndpointType.Response> {
        let socketRequest = try RequestFactory.generateSocketTask(fromEndpoint: endpoint, session: session)
        add(socketRequest, of: endpoint)
        
        let result = try await requestPerformer.performSocket(task: socketRequest, withResultType: EndpointType.Response.self)
        return result
    }
    
    public func cancel(endpoint: some Endpoint) {
        guard let url = endpoint.url else {
            return
        }
        
        if let task = tasks[url] {
            task.cancel()
            tasks.removeValue(forKey: url)
            
        } else if let socketTask = socketTasks[url] {
            socketTask.cancel()
            socketTasks.removeValue(forKey: url)
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
