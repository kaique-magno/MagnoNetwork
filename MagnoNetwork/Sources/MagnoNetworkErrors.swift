import Foundation

public enum MagnoNetworkErrors: Error {
    case invalidResponse
    case invalidData
    case failedRequest(Int)
    case nilURL
    case emptyResult
}
