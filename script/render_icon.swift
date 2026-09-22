import AppKit

// EchoAtlas: a field of echo rings and a single returning signal.
let args = CommandLine.arguments
guard args.count == 3 else { exit(1) }
let pixels = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:pixels,pixelsHigh:pixels,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:bitmap)
let tile = NSRect(x:72,y:72,width:880,height:880)
let outline = NSBezierPath(roundedRect:tile,xRadius:200,yRadius:200)
NSColor(calibratedRed:0.035,green:0.07,blue:0.085,alpha:1).setFill(); outline.fill()
outline.addClip()
let mint = NSColor(calibratedRed:0.48,green:0.90,blue:0.78,alpha:1)
for radius in [150.0,265.0,380.0] {
    let ring = NSBezierPath(ovalIn:NSRect(x:512-radius,y:512-radius,width:radius*2,height:radius*2))
    ring.lineWidth = 9
    mint.withAlphaComponent(radius == 265 ? 0.70 : 0.22).setStroke(); ring.stroke()
}
let ray = NSBezierPath(); ray.move(to:NSPoint(x:512,y:512)); ray.line(to:NSPoint(x:745,y:745)); ray.lineWidth = 17; ray.lineCapStyle = .round
mint.setStroke(); ray.stroke()
let origin = NSBezierPath(ovalIn:NSRect(x:480,y:480,width:64,height:64)); mint.setFill(); origin.fill()
NSColor.white.setFill(); NSBezierPath(ovalIn:NSRect(x:695,y:695,width:44,height:44)).fill()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:args[2]))
