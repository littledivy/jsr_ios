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
              HStack {
                Text("Versions")
                Spacer()
                Text(version)
                  .foregroundColor(.secondary)
              }
            }

            NavigationLink(
              destination: PackageSymbolsView(client: client, package: package, version: version)
            ) {
              Text("Docs")
            }

            if let score = package.score {
              NavigationLink(destination: PackageScoreView(client: client, package: package)) {
                HStack {
                  Text("Score")
                  Spacer()
                  Text("\(String(score))%")
                    .foregroundColor(.secondary)
                }
              }
            }
          }
          .scrollDisabled(true)
          .frame(height: 130)
          .listStyle(.inset)

          HStack {
            Text("README.md")
            Spacer()
          }.padding()

          PackageDocsView(
            client: client, package: package, parentHeight: reader.size.height, version: version,
            docs: $docs)
        }
        .navigationTitle(package.name)
      }
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
