import Foundation

actor ConfigStore {
    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("SSHTunnelManager", isDirectory: true)

        // Create directory if needed
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        self.fileURL = appFolder.appendingPathComponent("tunnels.json")
    }

    func load() -> [Tunnel] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let tunnels = try JSONDecoder().decode([Tunnel].self, from: data)
            return tunnels
        } catch {
            print("Failed to load tunnels: \(error)")
            return []
        }
    }

    func save(_ tunnels: [Tunnel]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(tunnels)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save tunnels: \(error)")
        }
    }
}
