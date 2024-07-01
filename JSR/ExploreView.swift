//
//  ExploreView.swift
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

struct ExploreView: View {
  @State var search = ""
  @State var packages: [Components.Schemas.Package] = []

  @ObservedObject var client: ClientObj

  func getPackage() {
    Task {
      do {
        let response = try await client.client.listPackages(
          query: .init(query: search.isEmpty ? nil : search)
        )
        switch response {
        case .ok(let okResponse):
          switch okResponse.body {
          case .json(let res):
            packages = res.items ?? []
          }
        case .undocumented(let statusCode, _):
          print("🙉 \(statusCode)")
        case .badRequest:
          print("🙈 Bad request")
        }
      } catch {
        print(error)
      }
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        ForEach(packages) { package in
          NavigationLink(destination: PackageView(client: client, package: package)) {
            PackageCardView(package: package)
          }
        }

        Spacer()
      }
      .navigationTitle("Explore")
      .searchable(text: $search)
      .disableAutocorrection(true)
      .onChange(of: search) { _, _ in
        if search.isEmpty {
          packages = []
        }
      }
      .onSubmit(of: .search) {
        getPackage()
      }.task {
        getPackage()
      }
    }
  }
}
