import Foundation

enum Errors: Error {
    case invalidResponse
    case invalidData
    case failedRequest(Int)
    case nilURL
}
