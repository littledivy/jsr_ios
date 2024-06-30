import SwiftUI
import OpenAPIURLSession

extension Components.Schemas.PackageVersion: Identifiable {
    public var id: String { version }
}

struct PackageVersionsView: View {
    @ObservedObject var client: ClientObj
    var package: Components.Schemas.Package
    @State var versions: [Components.Schemas.PackageVersion]?

    func fetchVersions() async {
        do {
            let response = try await client.client.listPackageVersions(path: .init(scope: package.scope, package: package.name))
            switch response {
               case .ok(let okResponse):
                   switch okResponse.body {
                   case .json(let res):
                       versions = res
                   }
               case .undocumented(statusCode: let statusCode, _):
                   print( "🙉 \(statusCode)" )
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
            ZStack {
                if let versions = versions {
                    List(versions) { version in
                        NavigationLink(destination: PackageView(client: client, package: package, version: version.version)) {
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
