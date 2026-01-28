import Foundation

struct Tunnel: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var host: String           // user@server.com
    var port: Int              // SSH port (default 22)
    var localHost: String      // Local bind address (default 127.0.0.1)
    var localPort: Int         // Local port to forward
    var remoteHost: String     // Remote host (usually 127.0.0.1)
    var remotePort: Int        // Remote port
    var identityFile: String?  // Path to identity file (~/.ssh/id_rsa)
    var autoConnect: Bool      // Connect on app launch

    init(
        id: UUID = UUID(),
        name: String = "",
        host: String = "",
        port: Int = 22,
        localHost: String = "127.0.0.1",
        localPort: Int = 8080,
        remoteHost: String = "127.0.0.1",
        remotePort: Int = 8080,
        identityFile: String? = nil,
        autoConnect: Bool = false
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.localHost = localHost
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.identityFile = identityFile
        self.autoConnect = autoConnect
    }

    // Codable conformance - exclude runtime properties
    enum CodingKeys: String, CodingKey {
        case id, name, host, port, localHost, localPort, remoteHost, remotePort, identityFile, autoConnect
    }
}
