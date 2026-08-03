import SwiftUI

final class DrawerManager: ObservableObject {
    @Published var isOpen = false
    @AppStorage("signature") var signature = "亲爱的树洞听众"

    func toggle() {
        withAnimation(.easeOut(duration: 0.35)) {
            isOpen.toggle()
        }
    }

    func close() {
        withAnimation(.easeOut(duration: 0.25)) {
            isOpen = false
        }
    }
}
