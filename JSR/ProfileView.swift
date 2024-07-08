//
//  ProfileView.swift
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

import OpenAPIURLSession
import SwiftUI

struct ProfileView: View {
  @AppStorage("accessToken") var accessToken: String = ""
  @AppStorage("loggedIn") var loggedIn: Bool?

  @State var user: Components.Schemas.User?
  @State var scopes: [Components.Schemas.Scope]?
  @ObservedObject var client: HTTPClient

  func fetchUser() async {
    do {
      let response = try await client.client.getSelfUser()
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          user = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .unauthorized(_):
        print("🙈 Unauthorized")
      }
    } catch {
      print(error)
    }

    do {
      let response = try await client.client.listSelfUserScopes()
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          scopes = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .unauthorized(_):
        print("🙈 Unauthorized")
      }

    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        if let user = user {
          HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
              image
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } placeholder: {
              ProgressView()
            }

            VStack(alignment: .leading) {
              Text(user.name)
                .fontWeight(.bold)

              Text(user.email ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }
          .padding()
        } else if loggedIn == true {
          ProgressView()
        } else {
          List {
            NavigationLink(destination: SettingsView(client: client)) {
              HStack {
                Image(systemName: "key")
                Text("Set auth token")
              }
            }.buttonStyle(.bordered)
          }
          .refreshable {
            await fetchUser()
          }
        }

        if let user = user {
          let scopes = Double(user.scopeUsage ?? 0)
          let limit = Double(user.scopeLimit ?? 3)
          Section(header: Text("Quotas").font(.title3).fontWeight(.bold).padding(.horizontal)) {
            HStack {
              Gauge(value: scopes, in: 0...limit) {}
              Text("\(Int(scopes)) / \(Int(limit))")
            }.padding()
          }
        }

        if let scopes = scopes {
          Section(header: Text("Scopes").font(.title3).fontWeight(.bold).padding(.horizontal)) {
            List {
              ForEach(scopes) { scope in
                NavigationLink(destination: ScopesView(client: client, scope: scope)) {
                  Text(scope.scope)
                }
              }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
          }
        }

        Spacer()
      }
      .navigationTitle("Profile")
    }
    .onChange(of: accessToken) { _, _ in
      if accessToken.isEmpty {
        user = nil
        scopes = nil
      } else {
        Task { await fetchUser() }
      }
    }
    .task {
      await fetchUser()
    }
    .refreshable {
      await fetchUser()
    }
  }
}
