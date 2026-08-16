import AppKit
import SwiftUI

@MainActor
final class ClockPanelController: NSObject, NSWindowDelegate {
    private let model: AppModel
    private let panel: NSPanel

    init(model: AppModel) {
        self.model = model
        let width: CGFloat = 130
        let height: CGFloat = 172
        panel = NSPanel(
            contentRect: NSRect(origin: model.savedOrigin(width: width, height: height), size: NSSize(width: width, height: height)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        super.init()

        panel.delegate = self
        panel.contentView = NSHostingView(rootView: ClockFaceView().environmentObject(model))
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
