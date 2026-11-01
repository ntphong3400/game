// Render contact sheets from original PNGs, preserving the generated anatomy.
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let output = root.appendingPathComponent("output/meeting-generation")
let data = try Data(contentsOf: output.appendingPathComponent("prompts.json"))
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
let specs = json["specs"] as! [[String: Any]]

func source(_ spec: [String: Any]) -> URL {
    let id = spec["id"] as! String
    if id == "harem-001" { return root.appendingPathComponent("assets/images/meetings/ngoc-lan-fullbody-v1.png") }
    if id == "harem-002" { return root.appendingPathComponent("output/meeting-review/thanh-mai-fullbody-v2-preview.png") }
    let version = spec["version"] as? Int ?? 2
    return output.appendingPathComponent("source/\(id)-v\(version).png")
}

func render(_ entries: [[String: Any]], name: String) throws {
    let cols = 5, cellWidth = 250, cellHeight = 410
    let rows = (entries.count + cols - 1) / cols
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cols * cellWidth,
        pixelsHigh: rows * cellHeight, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor(calibratedRed: 0.88, green: 0.87, blue: 0.81, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: cols * cellWidth, height: rows * cellHeight).fill()
    for (index, spec) in entries.enumerated() {
        let id = spec["id"] as! String
        let x = index % cols * cellWidth, y = (rows - 1 - index / cols) * cellHeight
        NSColor(calibratedRed: 0.95, green: 0.93, blue: 0.88, alpha: 1).setFill()
        NSRect(x: x + 3, y: y + 3, width: cellWidth - 6, height: cellHeight - 6).fill()
        if let image = NSImage(contentsOf: source(spec)) {
            image.draw(in: NSRect(x: x + 7, y: y + 45, width: 236, height: 354), from: .zero, operation: .sourceOver, fraction: 1)
        }
        let label = (spec["name"] as? String) ?? id
        (label as NSString).draw(at: NSPoint(x: x + 9, y: y + 25), withAttributes: [
            .font: NSFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: NSColor.darkGray])
        (id as NSString).draw(at: NSPoint(x: x + 9, y: y + 8), withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: NSColor.darkGray])
    }
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(name))
}

try render(specs.filter { ($0["female"] as? Bool) == true }, name: "review-harem.png")
let men = specs.filter { ($0["female"] as? Bool) == false }
try render(Array(men.prefix(30)), name: "review-officials-1.png")
try render(Array(men.suffix(30)), name: "review-officials-2.png")
print("Rendered three meeting-art contact sheets.")
