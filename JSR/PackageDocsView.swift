//
//  PackageDocsView.swift
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

struct PackageDocsView: View {
  @ObservedObject var client: HTTPClient
  var package: Components.Schemas.Package

  var parentHeight: CGFloat
  var version: String = "latest"
  var allSymbols: Bool = false

  @Binding var docs: Components.Schemas.PackageDocs?
  @State var webViewHeight: CGFloat = 0
  @State var notFound: Bool = false

  func getDocs() async {
    do {
      let response = try await client.client.getPackageVersionDocs(
        path: .init(scope: package.scope, package: package.name, version: version),
        query: allSymbols ? .init(all_symbols: allSymbols) : .init()
      )
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          docs = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .badRequest(_):
        print("🙈 Bad request")
      case .notFound(_):
        notFound = true
      }
    } catch {
      print(error)
    }
  }

  var body: some View {
    VStack {
      if let bind = docs {
        let binding = Binding {
          bind
        } set: {
          docs = $0
        }
        WebView(text: binding.main, css: binding.css, contentHeight: $webViewHeight)
          .padding(.horizontal)
          .frame(height: max(parentHeight, self.webViewHeight))
          .edgesIgnoringSafeArea(.bottom)
      } else if notFound {
        Text("No version found")
          .padding()
      } else {
        ProgressView()
          .padding()
      }
    }.task {
      await getDocs()
    }
  }
}
