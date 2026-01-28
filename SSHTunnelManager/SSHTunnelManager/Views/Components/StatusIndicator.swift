import SwiftUI

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
}

struct StatusIndicator: View {
    let status: ConnectionStatus
    var size: CGFloat = 10

    private var color: Color {
        switch status {
        case .disconnected: return .red
        case .connecting: return .yellow
        case .connected: return .green
        }
    }

    private var glowColor: Color {
        switch status {
        case .disconnected: return .clear
        case .connecting: return .yellow.opacity(0.5)
        case .connected: return .green.opacity(0.5)
        }
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: glowColor, radius: 3)
    }

    // Convenience initializer for backward compatibility
    init(isConnected: Bool, size: CGFloat = 10) {
        self.status = isConnected ? .connected : .disconnected
        self.size = size
    }

    init(status: ConnectionStatus, size: CGFloat = 10) {
        self.status = status
        self.size = size
    }
}

#Preview {
    HStack(spacing: 20) {
        StatusIndicator(status: .connected)
        StatusIndicator(status: .connecting)
        StatusIndicator(status: .disconnected)
        StatusIndicator(status: .connected, size: 16)
    }
    .padding()
}
