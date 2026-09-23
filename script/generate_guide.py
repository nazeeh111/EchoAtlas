"""Regenerate the bundled original practice guide; requires reportlab."""
from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak

ROOT = Path(__file__).resolve().parents[1]
INK = colors.HexColor('#20262a')
COPPER = colors.HexColor('#aa552f')
PAPER = colors.HexColor('#f8f5ee')
title = ParagraphStyle('title', fontName='Helvetica-Bold', fontSize=36, leading=42, textColor=INK, spaceAfter=22)
sub = ParagraphStyle('sub', fontName='Helvetica-Bold', fontSize=17, leading=23, textColor=INK, spaceAfter=8)
body = ParagraphStyle('body', fontName='Helvetica', fontSize=13, leading=20, textColor=INK, spaceAfter=20)
label = ParagraphStyle('label', fontName='Helvetica-Bold', fontSize=10, leading=15, textColor=COPPER, spaceAfter=17)

def page(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(PAPER)
    canvas.rect(0, 0, 612, 792, fill=1, stroke=0)
    canvas.setStrokeColor(COPPER)
    canvas.setLineWidth(1.2)
    canvas.line(52, 731, 560, 731)
    canvas.setFillColor(INK)
    canvas.setFont('Helvetica-Bold', 10)
    canvas.drawString(52, 749, 'ECHOATLAS  /  GESTURE GUIDE')
    canvas.setFont('Helvetica', 9)
    canvas.drawString(52, 37, 'EchoAtlas · Gesture controls and acoustic measurements')
    canvas.drawRightString(560, 37, f'{doc.page:02d} / 03')
    canvas.restoreState()

story = []
def p(text, style=body):
    story.append(Paragraph(text, style))

p('01  /  GET ORIENTED', label)
p('Getting started', title)
p('EchoAtlas turns changes in reflected sound into experimental gesture controls. This guide is also a scrollable practice document: use the manual buttons to explore it before starting a sensing session.')
p('Choose a mode', sub)
p('Scroll moves a page, Swipe browses the image collection, and Zoom changes the scale of a detailed material study. The signal modes let you inspect acoustic measurements separately.')
p('Start sensing', sub)
p('When you choose Start, allow microphone access if prompted. Keep your hand still until the calibration countdown finishes. Use the built-in speakers and microphone; device and room conditions affect the result.')
p('Keep control', sub)
p('Stop turns sensing off. Switching modes stops the current session. Accessibility access is needed for controls sent to other apps; local practice remains a useful way to learn the interface.')
p('The illustrations in the gallery are generated visual studies. They are practice material, not sensor measurements.', body)
story.append(PageBreak())
p('02  /  SCROLL, SWIPE AND ZOOM', label)
p('Gesture controls', title)
p('Scroll', sub)
p('Lift your hand above the keyboard, then return it calmly. Pause between attempts. The direction control changes the scroll direction; the optional air double-tap uses two short downward motions. Manual Scroll up and Scroll down buttons move this page without sensing.')
p('Swipe', sub)
p('Sweep your hand across the sensing area, then return to rest before trying again. Use the visible previous and next controls to compare the manual result. The return motion is suppressed to reduce an unintended second action.')
p('Zoom', sub)
p('Push and pull to explore the image at different scales. Start with a deliberate movement and a clear pause. Zoom in and Reset let you inspect the same image manually while audio is stopped.')
p('Troubleshooting', sub)
p('If results are inconsistent, stop, check the selected audio route, and recalibrate with your hands still. Check the on-screen status for calibration and signal errors.')
story.append(PageBreak())
p('03  /  UNDERSTAND THE LIMITS', label)
p('Acoustic measurements', title)
p('Signal', sub)
p('The spectrum shows how energy changes around the test tone. It helps connect movement with the detector response. Room noise and other motion can also affect the spectrum.')
p('Distance and Position', sub)
p('These modes explore echo-delay and two-speaker geometry estimates. Reflections, room layout, device response, and alignment can affect them. Treat their outputs as experimental estimates rather than calibrated measurements.')
p('When the session stops', sub)
p('Missing or delayed microphone readings stop sensing. So do system sleep and relevant permission changes. After resolving the cause, Start begins a new session and a fresh calibration; audio does not restart silently.')
p('A repeatable practice loop', sub)
p('Choose one mode. Check its manual control. Start and calibrate. Make one deliberate movement. Observe the result. Stop before changing the environment or audio settings. Recalibrate after changing the audio route or speaker volume.')

target = ROOT / 'assets/paper/EchoAtlasGuide.pdf'
SimpleDocTemplate(str(target), pagesize=(612, 792), leftMargin=52, rightMargin=52,
                  topMargin=88, bottomMargin=70, title='EchoAtlas Gesture Guide',
                  author='nazeeh111').build(story, onFirstPage=page, onLaterPages=page)
print(target)
