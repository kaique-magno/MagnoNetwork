import XCTest
@testable import MagnoNetwork

//MARK: - Support Classes and Structs

fileprivate struct JustToTestClass: Decodable, Equatable {
    let name: String
    let value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}

fileprivate let jsonString = """
[
    {
        "name": "First",
        "value": 1
    },
    {
        "name": "Second",
        "value": 2
    },
    {
        "name": "Third",
        "value": 3
    }
]
"""

// MARK: - Tests
final class SocketConverterTests: XCTestCase {
    func testConvert_WhenMessageIsData_ShouldConvertObject() throws {
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        let socketMessage: URLSessionWebSocketTask.Message = .data(jsonData)
        
        let expectedObject: [JustToTestClass] = [
            .init(name: "First", value: 1),
            .init(name: "Second", value: 2),
            .init(name: "Third", value: 3),
        ]
        
        let convertedObject: [JustToTestClass] = try SocketMessageConverter.object(from: socketMessage,
                                                                                   objectType: [JustToTestClass].self)
        
        XCTAssertTrue(expectedObject == convertedObject)
    }
    
    func testConvert_WhenMessageIsString_ShouldConvertObject() throws {
        let socketMessage: URLSessionWebSocketTask.Message = .string(jsonString)
        
        let expectedObject: [JustToTestClass] = [
            .init(name: "First", value: 1),
            .init(name: "Second", value: 2),
            .init(name: "Third", value: 3),
        ]
        
        let convertedObject: [JustToTestClass] = try SocketMessageConverter.object(from: socketMessage,
                                                                                   objectType: [JustToTestClass].self)
        
        XCTAssertTrue(expectedObject == convertedObject)
    }
    
    func testConvert_WhenMessageIsDataButNull_ShouldThrownAnError() throws {
        let socketMessage: URLSessionWebSocketTask.Message = .data(.init())
        
        XCTAssertThrowsError(try SocketMessageConverter.object(from: socketMessage,
                                                               objectType: [JustToTestClass].self))
    }
    
    func testConvert_WhenJsonFormatDataIsIncorrecet_ShouldThrowAnError() throws {
        let nullableJsonFormat = "[{'notAName': 'No Name', 'value': 0}]"
        let jsonData = try XCTUnwrap(nullableJsonFormat.data(using: .utf8))
        let socketMessage: URLSessionWebSocketTask.Message = .data(jsonData)
        
        XCTAssertThrowsError(try SocketMessageConverter.object(from: socketMessage,
                                                               objectType: [JustToTestClass].self))
    }
    
    func testConvert_WhenJsonFormatStringIsIncorrecet_ShouldThrowAnError() throws {
        let nullableJsonFormat = "[{'notAName': 'No Name', 'value': 0}]"
        let socketMessage: URLSessionWebSocketTask.Message = .string(nullableJsonFormat)
        
        XCTAssertThrowsError(try SocketMessageConverter.object(from: socketMessage,
                                                               objectType: [JustToTestClass].self))
    }
}
