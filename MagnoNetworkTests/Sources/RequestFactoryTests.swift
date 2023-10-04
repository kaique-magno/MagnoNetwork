//
//  RequestFactoryTests.swift
//  MagnoNetworkTests
//
//  Created by Kaique Magno on 21/12/22.
//

import XCTest
@testable import MagnoNetwork

// MARK: - Endpoints
struct GenericBaseEndpoint: BaseEndpoint {
    var basePath: String
    var headers: HTTPHeaders?
}

struct GenericEndpoint: Endpoint {
    typealias Response = String
    
    var path: String
    var baseEndpoint: BaseEndpoint? = nil
    var httpMethod: HTTPMethod
    var parameters: Parameters? = [:]
    var headers: HTTPHeaders? = [:]
}

// MARK: - Tests
final class RequestFactoryTests: XCTestCase {
    func test_urlPath_Matches() throws {
        let pathURL = "https://url.com"
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: nil,
                                       httpMethod: .get,
                                       parameters: [:],
                                       headers: [:])
        let sut = RequestFactory(endpoint: endpoint)
        let request = try sut.generateURLRequest()
        let urlString = try XCTUnwrap(request.url?.formatted())
        XCTAssertEqual(urlString, pathURL)
    }
    
    func test_urlPath_Error() throws {
        let pathURL = ""
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: nil,
                                       httpMethod: .get,
                                       parameters: [:],
                                       headers: [:])
        let sut = RequestFactory(endpoint: endpoint)
        XCTAssertThrowsError(try sut.generateURLRequest())
    }
    
    func test_urlMethod_Matches() throws {
        let pathURL = "https://url.com"
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: nil,
                                       httpMethod: .post,
                                       parameters: [:],
                                       headers: [:])
        let sut = RequestFactory(endpoint: endpoint)
        let request = try sut.generateURLRequest()
        let httpMethod = try XCTUnwrap(request.httpMethod)
        XCTAssertEqual(httpMethod, endpoint.httpMethod.rawValue)
    }
    
    func test_parameters_Matches() throws {
        let pathURL = "https://url.com"
        let parameters: [String: Any] = [
            "StringProperty": "A String",
            "IntProperty": 123,
            "BoolProperty": true
        ]
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: nil,
                                       httpMethod: .post,
                                       parameters: parameters,
                                       headers: [:])
        let sut = RequestFactory(endpoint: endpoint)
        let request = try sut.generateURLRequest()
        let url: URL = try XCTUnwrap(request.url)
        let urlParameters = try XCTUnwrap(url.query())
        let parametersArray = parameters.map { "\($0)=\($1)" }
        let parametersQuery = parametersArray.joined(separator: "&")
        let parametersQueryEncoded = try XCTUnwrap(parametersQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        XCTAssertEqual(urlParameters, parametersQueryEncoded)
    }
    
    func test_headers_Matches() throws {
        let pathURL = "https://url.com"
        let headers: [String: String] = [
            "StringProperty": "A String",
            "SecondProperty": "Another string",
            "BoolProperty":  "true"
        ]
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: nil,
                                       httpMethod: .post,
                                       parameters: [:],
                                       headers: headers)
        let sut = RequestFactory(endpoint: endpoint)
        let request = try sut.generateURLRequest()
        let requestHeaders = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(requestHeaders, headers)
    }
    
    func test_baseEndpoint_Matches() throws {
        let basePathURL = "https://baseurl.com"
        let baseHeaders: [String: String] = [
            "BaseHeaderProperty": "Base String",
            "SecondBaseHeaderProperty": "Base Another string",
        ]
        let baseEndpoint = GenericBaseEndpoint(basePath: basePathURL,
                                               headers: baseHeaders)
        
        let pathURL = "/test"
        let headers: [String: String] = [
            "StringProperty": "A String",
            "SecondProperty": "Another string",
            "BoolProperty":  "true"
        ]
        let endpoint = GenericEndpoint(path: pathURL,
                                       baseEndpoint: baseEndpoint,
                                       httpMethod: .post,
                                       parameters: [:],
                                       headers: headers)
        let sut = RequestFactory(endpoint: endpoint)
        let request = try sut.generateURLRequest()
        
        let urlPaths = basePathURL + pathURL
        let urlString = try XCTUnwrap(request.url?.formatted())
        XCTAssertEqual(urlString, urlPaths)
        
        let allHeaders = baseHeaders.merging(headers) { current, _ in
            current
        }
        let requestHeaders = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(requestHeaders, allHeaders)
    }
}
