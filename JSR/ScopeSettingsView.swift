//
//  ScopeSettingsView.swift
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

struct QuotaView: View {
  var used: Int
  var limit: Int

  var body: some View {
    HStack {
      Gauge(value: Double(used), in: 0...Double(limit)) {}
      Text("\(used) / \(limit)")
    }
  }
}

struct ScopeSettingsView: View {
  @ObservedObject var client: HTTPClient
  @State var scope: Components.Schemas.Scope

  func getFullScope() async {
    do {
      let response = try await client.client.getScope(path: .init(scope: scope.scope))
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          if res.quotas != nil {
            scope = res
          }
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .unauthorized(_):
        print("🙈 Unauthorized")
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
      ScrollView {
        if let quotas = scope.quotas {
          Section(
            header:
              HStack {
                Text("Quotas").font(.title2).fontWeight(.bold)
                Spacer()
              }
          ) {
            VStack {
              HStack {
                Text("Total packages")
                Spacer()
              }
              QuotaView(used: quotas.packageUsage ?? 0, limit: quotas.packageLimit ?? 100)
            }.padding(.top)
            VStack {
              HStack {
                Text("New packages per week")
                Spacer()
              }
              QuotaView(
                used: quotas.newPackagePerWeekUsage ?? 0, limit: quotas.newPackagePerWeekLimit ?? 20
              )
            }.padding(.top)
            VStack {
              HStack {
                Text("Publish attempts per week")
                Spacer()
              }
              QuotaView(
                used: quotas.publishAttemptsPerWeekUsage ?? 0,
                limit: quotas.publishAttemptsPerWeekLimit ?? 1000)
            }.padding(.vertical)
          }
        }

        Section(
          header:
            HStack {
              Text("Github Actions security").font(.title2).fontWeight(.bold)
              Spacer()
            }
        ) {
          VStack {
            HStack {
              Text("Restrict publishing to members")
              Spacer()
              (scope.ghActionsVerifyActor ?? false)
                ? Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                : Image(systemName: "xmark.circle")
                  .foregroundColor(.red)
            }
          }
          .padding(.top)
          VStack {
            HStack {
              Text("Require publishing from CI")
              Spacer()
              (scope.requirePublishingFromCI ?? false)
                ? Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                : Image(systemName: "xmark.circle")
                  .foregroundColor(.red)
            }
          }
          .padding(.top)
        }

        Spacer()
      }
      .padding()
      .navigationTitle("Settings")
    }.task {
      await getFullScope()
    }
  }
}

#Preview {
  ScopeSettingsView(
    client: HTTPClient(),
    scope: Components.Schemas.Scope(
      scope: "divy",
      quotas: Components.Schemas.Scope.quotasPayload(
        packageUsage: 12,
        packageLimit: 100
      ),
      createdAt: Date(),
      updatedAt: Date()
    ))
}
