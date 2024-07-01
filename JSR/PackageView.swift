//
//  PackageView.swift
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
import WebKit

struct PackageView: View {
  @ObservedObject var client: HTTPClient
  var package: Components.Schemas.Package

  var version: String = "latest"

  @State var docs: Components.Schemas.PackageDocs?
  @State var webViewHeight: CGFloat = 0

  struct WebView: UIViewRepresentable {
    @Binding var text: String
    @Binding var css: String
    @Binding var contentHeight: CGFloat

    func makeUIView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.scrollView.isScrollEnabled = false
      webView.navigationDelegate = context.coordinator
      let html = """
        <html>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://jsr.io/styles.css">
        <style>\(css)</style>
        <div class="ddoc" id="docMain">\(text)</div>
        </html>
        """

      webView
        .loadHTMLString(html, baseURL: nil)
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
      Coordinator(contentHeight: $contentHeight)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
      @Binding var contentHeight: CGFloat
      var resized = false

      init(contentHeight: Binding<CGFloat>) {
        self._contentHeight = contentHeight
      }

      internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !self.resized {
          webView.evaluateJavaScript("document.readyState") { complete, _ in
            guard complete != nil else { return }
            webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
              guard let height = height as? CGFloat else { return }

              self.contentHeight = height
              self.resized = true
            }
          }
        }
      }
    }
  }

  func getDocs() async {
    do {
      let response = try await client.client.getPackageVersionDocs(
        path: .init(scope: package.scope, package: package.name, version: version))
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
        print("🙈 Not found")
      }
    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      GeometryReader { reader in
        ScrollView {
          HStack(spacing: 10) {
            if let docs = docs {
              if docs.version.value1.rekorLogId != nil {
                let rekorLogId = docs.version.value1.rekorLogId
                Button {
                  UIApplication.shared.open(
                    URL(string: "https://search.sigstore.dev/?logIndex=\(rekorLogId!)")!)
                } label: {
                  Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
                }
              }
            }

            Text(version)
              .font(.caption)
              .padding(.horizontal)
              .padding(.vertical, 2)
              .background(Color.yellow)
              .cornerRadius(5)

            if let github = package.githubRepository {
              let path = "\(github.owner ?? "")/\(github.name ?? "")"
              Button {
                UIApplication.shared.open(URL(string: "https://github.com/\(path)")!)
              } label: {
                Text(path)
                  .font(.caption)
              }
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
              .foregroundColor(.white)
              .background(Color(red: 0.3, green: 0.3, blue: 0.3))
              .cornerRadius(5)
            }

            Spacer()
          }.padding(.horizontal)

          HStack {
            Text(package.description)
              .font(.caption)
            Spacer()
          }.padding(.horizontal)

          List {
            NavigationLink(destination: PackageVersionsView(client: client, package: package)) {
              Text("Versions")
              Spacer()
              Text(version)
                .foregroundColor(.secondary)

            }
            NavigationLink(destination: Text("todo: Docs")) {
              Text("Docs")
            }

            NavigationLink(destination: PackageScoreView(client: client, package: package)) {
              Text("Score")
              Spacer()
              Text("\(String(package.score!))%")
                .foregroundColor(.secondary)

            }
          }
          .scrollDisabled(true)
          .frame(height: 130)
          .listStyle(.inset)

          HStack {
            Text("README.md")
            Spacer()
          }.padding()

          if let bind = docs {
            let binding = Binding {
              bind
            } set: {
              docs = $0
            }
            WebView(text: binding.main, css: binding.css, contentHeight: $webViewHeight)
              .padding(.horizontal)
              .frame(height: max(reader.size.height, self.webViewHeight))
              .edgesIgnoringSafeArea(.bottom)

          } else {
            ProgressView()
          }

        }
        .navigationTitle(package.name)
      }
    }.task {
      await getDocs()
    }
  }
}

#Preview {
  PackageView(
    client: HTTPClient(),
    package: Components.Schemas.Package(
      scope: "divy",
      name: "sdl2",
      description: "SDL2 module for Deno",
      runtimeCompat: Components.Schemas.RuntimeCompat(
        deno: true,
        node: true,
        bun: true
      ),
      createdAt: Date.now,
      updatedAt: Date.now,
      score: 100
    ))
}
