import AppKit
import CoreGraphics

func generateIcon() {
    let size: CGFloat = 1024
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let image = NSImage(size: rect.size)
    
    image.lockFocus()
    let context = NSGraphicsContext.current!.cgContext
    
    // 1. Draw Squircle Background (Tahoe Style)
    let cornerRadius = size * 0.225
    let squirclePath = NSBezierPath(roundedRect: rect.insetBy(dx: size * 0.05, dy: size * 0.05), xRadius: cornerRadius, yRadius: cornerRadius)
    
    let gradient = NSGradient(starting: NSColor(deviceRed: 0.0, green: 0.7, blue: 1.0, alpha: 1.0), 
                              ending: NSColor(deviceRed: 0.0, green: 0.3, blue: 0.8, alpha: 1.0))!
    gradient.draw(in: squirclePath, angle: -45)
    
    // 2. Draw Metallic Key Symbol
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .bold)
    if let keyImage = NSImage(systemSymbolName: "key.horizontal.fill", accessibilityDescription: nil)?.withSymbolConfiguration(symbolConfig) {
        let keySize = keyImage.size
        let drawRect = NSRect(x: (size - keySize.width) / 2, 
                              y: (size - keySize.height) / 2, 
                              width: keySize.width, 
                              height: keySize.height)
        
        // Shadow for the key
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 20
        shadow.shadowOffset = NSSize(width: 0, height: -10)
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.5)
        
        context.saveGState()
        shadow.set()
        
        // Draw key with white color
        NSColor.white.set()
        keyImage.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        context.restoreGState()
    }
    
    image.unlockFocus()
    
    // Save to PNG
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: "AppIcon.png"))
        print("✅ AppIcon.png generated.")
    }
}

generateIcon()
