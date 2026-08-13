import AppKit
import SwiftUI

@MainActor
final class ClockPanelController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private let panel: NSPanel

    init(model: AppModel) {
        self.model = model
        let size: CGFloat = 130
        panel = NSPanel(
            contentRect: NSRect(origin: model.savedOrigin(size: size), size: NSSize(width: size, height: size)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        super.init()

        panel.delegate = self
        panel.contentView = NSHostingView(rootView: ClockFaceView())
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        model.attach(panel: panel)
        panel.orderFrontRegardless()
    }

    func windowDidMove(_ notification: Notification) {
        model.savePosition()
    }
}
