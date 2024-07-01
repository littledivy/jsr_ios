//
//  PackageVersionsView.swift
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

extension Components.Schemas.PackageVersion: Identifiable {
  public var id: String { version }
}

struct PackageVersionsView: View {
  @ObservedObject var client: ClientObj
  var package: Components.Schemas.Package
  @State var versions: [Components.Schemas.PackageVersion]?

  func fetchVersions() async {
    do {
      let response = try await client.client.listPackageVersions(
        path: .init(scope: package.scope, package: package.name))
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          versions = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .badRequest:
        print("🙈 Bad request")
      case .notFound:
        print("🙈 Not found")
      }

    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        if let versions = versions {
          List(versions) { version in
            NavigationLink(
              destination: PackageView(client: client, package: package, version: version.version)
            ) {
              Text(version.version)
            }
          }
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Versions")
      .task {
        await fetchVersions()
      }
      .refreshable {
        await fetchVersions()
      }
    }
  }
}
