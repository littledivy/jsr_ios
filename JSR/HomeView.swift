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
