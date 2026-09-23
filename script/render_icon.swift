import AppKit

// Original EchoAtlas icon: three sound paths inside a warm, machined tile.
let args = CommandLine.arguments
guard args.count == 2 else { exit(1) }
let pixels = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:pixels,pixelsHigh:pixels,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:bitmap)
let outline = NSBezierPath(roundedRect:NSRect(x:72,y:72,width:880,height:880),xRadius:200,yRadius:200)
NSColor(calibratedRed:0.96,green:0.94,blue:0.89,alpha:1).setFill(); outline.fill()
outline.addClip()
let copper = NSColor(calibratedRed:0.67,green:0.33,blue:0.18,alpha:1)
let ink = NSColor(calibratedRed:0.12,green:0.15,blue:0.17,alpha:1)
for (index, width) in [460.0,320.0,460.0].enumerated() {
    let y = 300.0 + Double(index)*172
    let bar = NSBezierPath(roundedRect:NSRect(x:270,y:y,width:width,height:75),xRadius:37.5,yRadius:37.5)
    (index == 1 ? copper : ink).setFill(); bar.fill()
}
let spine = NSBezierPath(roundedRect:NSRect(x:270,y:300,width:75,height:419),xRadius:37.5,yRadius:37.5)
ink.setFill(); spine.fill()
copper.setFill(); NSBezierPath(ovalIn:NSRect(x:690,y:472,width:75,height:75)).fill()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:args[1]))
