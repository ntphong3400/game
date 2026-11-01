// Render contact sheets from original generated PNGs without altering assets.
// swift tools/portrait_review.swift
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let output = root.appendingPathComponent("output/avatar-generation/review")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let data = try Data(contentsOf: root.appendingPathComponent("output/avatar-generation/prompts.json"))
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
let specs = json["specs"] as! [[String: Any]]

func canvas(_ width: Int, _ height: Int, draw: () -> Void, name: String) throws {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor(calibratedRed: 0.94, green: 0.90, blue: 0.81, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    draw()
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(name))
}

for group in ["emperor", "official", "harem"] {
    let members = specs.filter { ($0["group"] as? String) == group }
    for page in stride(from: 0, to: members.count, by: 10) {
        let subset = Array(members[page..<min(page + 10, members.count)])
        let rows = (subset.count + 1) / 2
        try canvas(1440, rows * 258, draw: {
            for (i, spec) in subset.enumerated() {
                let id = spec["id"] as! String
                let x = (i % 2) * 720 + 12
                let y = (rows - 1 - i / 2) * 258 + 25
                if let image = NSImage(contentsOf: root.appendingPathComponent("output/avatar-generation/source/\(id).png")) {
                    image.draw(in: NSRect(x: x, y: y, width: 696, height: 232),
                        from: .zero, operation: .sourceOver, fraction: 1)
                }
                let title = "\(id)     25 / 45 / 65"
                (title as NSString).draw(at: NSPoint(x: x, y: y - 20), withAttributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: NSColor.darkGray,
                ])
            }
        }, name: "\(group)-\(page / 10 + 1).png")
    }
}

let cols = 10, cell = 140, row = 164
try canvas(cols * cell, ((specs.count + cols - 1) / cols) * row, draw: {
    for (i, spec) in specs.enumerated() {
        let id = spec["id"] as! String
        let x = (i % cols) * cell
        let y = ((specs.count + cols - 1) / cols - 1 - i / cols) * row + 24
        if let image = NSImage(contentsOf: root.appendingPathComponent("output/avatar-generation/source/\(id).png")) {
            image.draw(in: NSRect(x: x + 2, y: y, width: 136, height: 136),
                from: NSRect(x: 0, y: 0, width: image.size.width / 3, height: image.size.height),
                operation: .sourceOver, fraction: 1)
        }
        (id as NSString).draw(at: NSPoint(x: x + 4, y: y - 18), withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.darkGray,
        ])
    }
}, name: "all-identities.png")
let screenshots = ["game-court.jpg", "game-harem.jpg", "game-emperor.jpg"]
    .compactMap { NSImage(contentsOf: output.appendingPathComponent($0)) }
if screenshots.count == 3 {
    try canvas(1755, 873, draw: {
        for (i, image) in screenshots.enumerated() {
            image.draw(in: NSRect(x: i * 585, y: 0, width: 585, height: 873),
                from: .zero, operation: .sourceOver, fraction: 1)
        }
    }, name: "game-preview.png")
}
print("Contact sheets: \(output.path)")
