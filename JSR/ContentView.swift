import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession
import SwiftUI

/// A client middleware that injects a value into the `Authorization` header field of the request.
struct AuthenticationMiddleware {

  /// The value for the `Authorization` header field.
  private let value: String

  /// Creates a new middleware.
  /// - Parameter value: The value for the `Authorization` header field.
  package init(authorizationHeaderFieldValue value: String) { self.value = value }
}

class ClientObj: ObservableObject {
  var client: Client

  init(client: Client) {
    self.client = client
  }
}

extension AuthenticationMiddleware: ClientMiddleware {
  package func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    // Adds the `Authorization` header field with the provided value.
    if !value.isEmpty {
      request.headerFields[.authorization] = "Bearer \(value)"
    }
    return try await next(request, body, baseURL)
  }
}

extension Components.Schemas.Package: Identifiable {
  public var id: String { name }
}

struct ContentView: View {
  @State private var activeTab = 0
  @AppStorage("accessToken") var accessToken = ""
  @StateObject var client: ClientObj = ClientObj(
    client: Client(
      serverURL: try! Servers.server1(),
      configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
      transport: URLSessionTransport()
    ))

  @AppStorage("avatarURL") var avatarURL: String?

  var body: some View {
    TabView(selection: $activeTab) {
      HomeView(client: client)
        .tabItem {
          Image(systemName: "house")
          Text("Home")
        }
        .tag(1)

      ExploreView(client: client)
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Explore")
        }
        .tag(2)

      ProfileView(client: client)
        .tabItem {
          if let url = avatarURL {
            AsyncImage(url: URL(string: url)) { image in
              let size = CGSize(width: 30, height: 30)
              Image(size: size) { gc in
                gc.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                gc.draw(image, in: .init(origin: .zero, size: size))
                if activeTab == 3 {
                  gc.stroke(
                    Path(ellipseIn: .init(origin: .zero, size: size)), with: .color(.blue),
                    lineWidth: 2)
                }
              }
            } placeholder: {
              ProgressView()
            }
            .frame(width: 30, height: 30)
          } else {
            Image(systemName: "person")
              .frame(width: 30, height: 30)
          }

          Text("Profile")
        }
        .tag(3)
    }
    .onChange(of: accessToken) { _, _ in
      client.client = Client(
        serverURL: try! Servers.server1(),
        configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
        transport: URLSessionTransport(),
        middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: accessToken)]
      )
    }
    .onAppear {
      client.client = Client(
        serverURL: try! Servers.server1(),
        configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
        transport: URLSessionTransport(),
        middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: accessToken)]
      )
    }
  }
}

#Preview {
  ContentView()
}
