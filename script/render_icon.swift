import AppKit

// Original EchoAtlas icon: pale acoustic paths and a teal return signal
// on a graphite instrument tile. The paths form the EchoAtlas initial.
let args = CommandLine.arguments
guard args.count == 2 else { exit(1) }
let pixels = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:pixels,pixelsHigh:pixels,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:bitmap)
let outline = NSBezierPath(roundedRect:NSRect(x:72,y:72,width:880,height:880),xRadius:200,yRadius:200)
NSColor(calibratedRed:0.082,green:0.153,blue:0.176,alpha:1).setFill(); outline.fill()
outline.addClip()
let signal = NSColor(calibratedRed:0.31,green:0.82,blue:0.80,alpha:1)
let path = NSColor(calibratedRed:0.929,green:0.949,blue:0.953,alpha:1)
for (index, width) in [460.0,320.0,460.0].enumerated() {
    let y = 300.0 + Double(index)*172
    let bar = NSBezierPath(roundedRect:NSRect(x:270,y:y,width:width,height:75),xRadius:37.5,yRadius:37.5)
    (index == 1 ? signal : path).setFill(); bar.fill()
}
let spine = NSBezierPath(roundedRect:NSRect(x:270,y:300,width:75,height:419),xRadius:37.5,yRadius:37.5)
path.setFill(); spine.fill()
signal.setFill(); NSBezierPath(ovalIn:NSRect(x:690,y:472,width:75,height:75)).fill()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:args[1]))
