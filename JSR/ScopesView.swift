import SwiftUI

struct ScopesView: View {
    @ObservedObject var client: ClientObj
    var scope: Components.Schemas.Scope
    @State var packages: [Components.Schemas.Package]?
    
    func fetchScopePackages() async {
        do {
            let response = try await client.client.listScopePackages(path: .init(scope: scope.scope))
            switch response {
                case .ok(let okResponse):
                    switch okResponse.body {
                    case .json(let res):
                        packages = res.items
                    }
                case .undocumented(statusCode: let statusCode, _):
                    print( "🙉 \(statusCode)" )
                case .badRequest(_):
                    print("err")
                case .notFound(_):
                    print("err")
            }
        } catch {
            print(error)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    List {
                        NavigationLink(destination: ScopeMembersView(client: client, scope: scope.scope)) {
                            Text("Members")
                        }
                        
                        NavigationLink(destination: Text("todo: Settings")) {
                            Text("Settings")
                        }
                    }
                    .scrollDisabled(true)
                    .frame(height: 90)
                    .listStyle(.inset)
                    
                    HStack {
                        Text("Packages")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }.padding(.horizontal)
                    
                    if let packages = packages {
                        ForEach(packages) { package in
                            NavigationLink(destination: PackageView(client: client, package: package)) {
                                PackageCardView(package: package)
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle(String("@\(scope.scope)"))
        }.task {
            await fetchScopePackages()
        }
    }
}
