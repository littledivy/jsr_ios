//
//  PackageScoreView.swift
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

struct PackageScoreView: View {
  @ObservedObject var client: HTTPClient
  @State var score: Components.Schemas.PackageScore?
  var package: Components.Schemas.Package

  func fetchScore() async {
    do {
      let response = try await client.client.getPackageScore(
        path: .init(scope: package.scope, package: package.name))
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          score = res
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
  let gradient = Gradient(colors: [.red, .orange, .green])
  var body: some View {
    NavigationStack {
      if let score = score {
        HStack {
          let score = Int(package.score ?? 0)
          Text("\(score)%")
            .font(.title)
          Spacer()
          Gauge(value: package.score ?? 0, in: 0...100) {
            if score < 50 {
              Text("\(score)")
                .foregroundColor(.red)
            } else if score < 75 {
              Text("\(score)")
                .foregroundColor(.orange)
            } else {
              Text("\(score)")
                .foregroundColor(.green)
            }
          }.gaugeStyle(.accessoryCircular).tint(gradient)
        }.padding(.horizontal)
        List {
          HStack {
            Text("Has Readme")
            Spacer()
            if score.hasReadme {
              Image(systemName: "checkmark")
                .foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("Has Readme Examples")
            Spacer()
            if score.hasReadmeExamples {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("All Entrypoints Docs")
            Spacer()
            if score.allEntrypointsDocs {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("Documented Symbols")
            Spacer()
            Text(String(format: "%.2f", score.percentageDocumentedSymbols))
          }

          HStack {
            Text("All Fast Check")
            Spacer()
            if score.allFastCheck {
              Image(systemName: "checkmark")
                .foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("Has Provenance")
            Spacer()
            if score.hasProvenance {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("Has Description")
            Spacer()
            if score.hasDescription {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("At Least One Runtime Compatible")
            Spacer()
            if score.atLeastOneRuntimeCompatible {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }

          HStack {
            Text("Multiple Runtimes Compatible")
            Spacer()
            if score.multipleRuntimesCompatible {
              Image(systemName: "checkmark").foregroundColor(.green)
            } else {
              Image(systemName: "xmark").foregroundColor(.red)
            }
          }
        }
      } else {
        ProgressView()
      }
    }
    .navigationTitle("Score")
    .task {
      await fetchScore()
    }
  }
}
