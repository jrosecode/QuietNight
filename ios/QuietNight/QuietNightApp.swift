import SwiftUI
@main struct QuietNightApp: App { @StateObject var store = SessionStore(); var body: some Scene { WindowGroup { RootView().environmentObject(store) } } }
