import SwiftUI

@main
struct HeartLeafApp: App {
    let persistenceController = DataService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}
