# Magno Network Module

[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)

Magno Network is a powerful Swift module that simplifies the network layer for your iOS and macOS apps. This framework is designed to make working with URLSession and handling network requests a breeze, allowing you to focus on building amazing features for your app.

## Features

- **Simplified Networking**: Magno Network provides a clean and intuitive API for making network requests, reducing boilerplate code and making your codebase more maintainable.

- **Endpoint-based Request Handling**: With Magno Network, you can control URLSessionTasks using Endpoint references, making it easy to manage and cancel specific network requests.

- **Powered by Tuist**: Magno Network is proudly powered by [Tuist](https://tuist.io), ensuring a consistent and maintainable project structure for your Swift apps.

## Installation

You can easily integrate Magno Network into your project using Swift Package Manager. Simply add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/MagnoNetwork.git", from: "1.0.0")
]
```

Then, add `"MagnoNetwork"` as a dependency to your target.

## Usage

```swift
// Create an instance of MagnoNetwork
let service: ServiceInterface = Service()

struct AnEndpoint: Endpoint {
    typealias Response = AnDecodableType
    
    var path: String {
        "https://your-api.com"
    }
}

// Define an endpoint
let endpoint = AnEndpoint()

// Make a network request
service.request(endpoint) { result in
    switch result {
    case .success(let data):
        // Handle the successful response
        print(data)
    case .failure(let error):
        // Handle the error
        print(error)
    }
}
```

## Contributions and Feedback

Magno Network is a work in progress, and we welcome contributions, suggestions, and feedback from the community. If you have ideas for improvement or encounter any issues, please [open an issue](https://github.com/kaique-magno/MagnoNetwork/issues) or submit a pull request.

## License

Magno Network is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

---

*Happy coding!*
