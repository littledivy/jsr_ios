//
//  ScopesView.swift
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

import SwiftUI

struct ScopesView: View {
  @ObservedObject var client: HTTPClient
  var scope: Components.Schemas.Scope
  @State var packages: [Components.Schemas.Package]?

  func fetchScopePackages() async {
    print(scope)
    do {
      let response = try await client.client.listScopePackages(path: .init(scope: scope.scope))
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          packages = res.items
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .badRequest(_):
        print("err")
      case .notFound(_):
        print("err")
      }
    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      VStack {
        ScrollView {
          List {
            NavigationLink(destination: ScopeMembersView(client: client, scope: scope.scope)) {
              Text("Members")
            }
            NavigationLink(destination: ScopeSettingsView(client: client, scope: scope)) {
              Text("Settings")
            }
          }
          .scrollDisabled(true)
          .frame(height: 90)
          .listStyle(.inset)

          HStack {
            Text("Packages")
              .font(.title2)
              .fontWeight(.bold)
            Spacer()
          }.padding(.horizontal)

          if let packages = packages {
            ForEach(packages) { package in
              NavigationLink(destination: PackageView(client: client, package: package)) {
                PackageCardView(package: package)
              }
            }
          } else {
            ProgressView()
          }
        }
      }
      .navigationTitle(String("@\(scope.scope)"))
    }.task {
      await fetchScopePackages()
    }
  }
}
