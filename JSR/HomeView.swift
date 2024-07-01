//
//  HomeView.swift
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

struct HomeView: View {
  @State private var searchText = ""
  @ObservedObject var client: ClientObj

  @State var packages: [Components.Schemas.Package] = []

  func fetchPackages() async {
    do {
      let response = try await client.client.getStats()
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
            packages = res.featured
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      }
    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 0) {
          ForEach(packages) { package in
            NavigationLink(destination: PackageView(client: client, package: package)) {
              PackageCardView(package: package)
            }
          }
        }
        Spacer()
      }
      .searchable(text: $searchText)
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          NavigationLink(destination: SettingsView(client: client)) {
            Image(systemName: "gear")
          }
        }
      }
      .navigationBarTitle("Home")

    }.task {
      await fetchPackages()
    }.refreshable {
      await fetchPackages()
    }
  }
}
