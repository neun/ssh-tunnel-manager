import SwiftUI
import ServiceManagement

struct ContentView: View {
    @Environment(TunnelManager.self) private var tunnelManager
    @State private var selectedTunnel: Tunnel?
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        NavigationSplitView {
            TunnelListView(selection: $selectedTunnel)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 350)
        } detail: {
            if let tunnel = selectedTunnel,
               tunnelManager.tunnels.contains(where: { $0.id == tunnel.id }) {
                TunnelDetailView(tunnel: tunnel)
            } else {
                ContentUnavailableView {
                    Label("No Tunnel Selected", systemImage: "network")
                } description: {
                    Text("Select a tunnel from the sidebar or create a new one.")
                } actions: {
                    Button("Add Tunnel") {
                        tunnelManager.addTunnel()
                        if let newTunnel = tunnelManager.tunnels.last {
                            selectedTunnel = newTunnel
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onChange(of: tunnelManager.tunnels) { _, newTunnels in
            // Update selection if current tunnel was modified
            if let selected = selectedTunnel,
               let updated = newTunnels.first(where: { $0.id == selected.id }) {
                selectedTunnel = updated
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                print("Failed to update login item: \(error)")
                                launchAtLogin = !newValue
                            }
                        }
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(TunnelManager())
}
