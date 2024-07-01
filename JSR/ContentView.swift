//
//  ContentView.swift
//
//  Copyright (c) 2024 Divy Srivastava
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

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
    // swiftlint:disable force_try
    init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: URLSessionTransport()
        )
    }

    func withAuth(token: String) {
        self.client = Client(
          serverURL: try! Servers.server1(),
          configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
          transport: URLSessionTransport(),
          middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: token)]
        )
    }
    // swiftlint:enable force_try
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
  @StateObject var client: ClientObj = ClientObj()

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
              Image(size: size) { gfx in
                  gfx.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                  gfx.draw(image, in: .init(origin: .zero, size: size))
                if activeTab == 3 {
                    gfx.stroke(
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
        client.withAuth(token: accessToken)
    }
    .onAppear {
        client.withAuth(token: accessToken)
    }
  }
}

#Preview {
  ContentView()
}
