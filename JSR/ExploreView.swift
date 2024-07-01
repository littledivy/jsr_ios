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
        case .badRequest(_):
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
