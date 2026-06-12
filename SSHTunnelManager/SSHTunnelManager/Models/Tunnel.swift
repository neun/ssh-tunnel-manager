import Foundation

struct PortMapping: Identifiable, Codable, Hashable {
    var id: UUID
    var localHost: String
    var localPort: Int
    var remoteHost: String
    var remotePort: Int

    init(
        id: UUID = UUID(),
        localHost: String = "127.0.0.1",
        localPort: Int = 8080,
        remoteHost: String = "127.0.0.1",
        remotePort: Int = 8080
    ) {
        self.id = id
        self.localHost = localHost
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
    }
}

struct Tunnel: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var host: String           // user@server.com or SSH config alias
    var port: Int              // SSH port (default 22)
    var portMappings: [PortMapping]
    var identityFile: String?  // Path to identity file (~/.ssh/id_rsa)
    var autoConnect: Bool      // Connect on app launch
    var useAlias: Bool         // Use host as SSH config alias (no -i, no -p unless non-22)

    init(
        id: UUID = UUID(),
        name: String = "",
        host: String = "",
        port: Int = 22,
        portMappings: [PortMapping] = [PortMapping()],
        identityFile: String? = nil,
        autoConnect: Bool = false,
        useAlias: Bool = false
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.portMappings = portMappings.isEmpty ? [PortMapping()] : portMappings
        self.identityFile = identityFile
        self.autoConnect = autoConnect
        self.useAlias = useAlias
    }

    enum CodingKeys: String, CodingKey {
        case id, name, host, port, portMappings, identityFile, autoConnect, useAlias
        // Legacy single-mapping fields
        case localHost, localPort, remoteHost, remotePort
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(Int.self, forKey: .port)
        identityFile = try container.decodeIfPresent(String.self, forKey: .identityFile)
        autoConnect = try container.decode(Bool.self, forKey: .autoConnect)
        useAlias = try container.decodeIfPresent(Bool.self, forKey: .useAlias) ?? false

        if let mappings = try container.decodeIfPresent([PortMapping].self, forKey: .portMappings),
           !mappings.isEmpty {
            portMappings = mappings
        } else {
            // Migrate old configs with a single port mapping
            let localHost = try container.decode(String.self, forKey: .localHost)
            let localPort = try container.decode(Int.self, forKey: .localPort)
            let remoteHost = try container.decode(String.self, forKey: .remoteHost)
            let remotePort = try container.decode(Int.self, forKey: .remotePort)
            portMappings = [PortMapping(
                localHost: localHost,
                localPort: localPort,
                remoteHost: remoteHost,
                remotePort: remotePort
            )]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        try container.encode(portMappings, forKey: .portMappings)
        try container.encodeIfPresent(identityFile, forKey: .identityFile)
        try container.encode(autoConnect, forKey: .autoConnect)
        try container.encode(useAlias, forKey: .useAlias)
    }

    var mappingsSummary: String {
        portMappings.map { ":\($0.localPort) → :\($0.remotePort)" }.joined(separator: ", ")
    }

    var localPortsSummary: String {
        portMappings.map { ":\($0.localPort)" }.joined(separator: ", ")
    }
}
