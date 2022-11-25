import Cocoa
import FlutterMacOS

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        return FLNativeView(
            frame: CGRect.zero,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

public func createLabel() -> NSTextField {
    let nativeLabel = NSTextField()
    nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
    nativeLabel.stringValue = "Native text from macOS"
    nativeLabel.textColor = NSColor.red
    nativeLabel.isBezeled = false
    nativeLabel.isEditable = false
    nativeLabel.sizeToFit()
    return nativeLabel
}

class FLNativeView: NSView {

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        super.init(frame: frame)
        super.wantsLayer = true
        super.layer?.backgroundColor = NSColor.systemBlue.cgColor
        super.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        super.addSubview(createLabel())
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.wantsLayer = true
        super.layer?.backgroundColor = NSColor.systemGreen.cgColor
        super.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        super.addSubview(createLabel())
    }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let factory = FLNativeViewFactory(messenger: flutterViewController.engine.binaryMessenger)
    let registrar = flutterViewController.engine.registrar(forPlugin: "dummy");
    registrar.register(factory, withId: "@views/simple-box-view-type")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
