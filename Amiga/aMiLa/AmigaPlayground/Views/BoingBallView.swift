import SwiftUI

struct BoingBallView: View {
    @State private var rotationAngle: Double = 0.0
    @State private var bouncePhase: Double = 0.0
    
    // Animation constants
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 * 0.8
                
                // Draw shadow
                var shadowPath = Path()
                shadowPath.addEllipse(in: CGRect(
                    x: center.x - radius * 0.9 + sin(bouncePhase) * 15,
                    y: center.y + radius * 0.7,
                    width: radius * 1.8,
                    height: radius * 0.25
                ))
                context.fill(shadowPath, with: .color(Color.black.opacity(0.25)))
                
                // Keep sphere drawing clean and anti-aliased
                context.drawLayer { sphereContext in
                    // Sphere path clip
                    var sphereClip = Path()
                    sphereClip.addEllipse(in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius - (abs(sin(bouncePhase)) * 20),
                        width: radius * 2,
                        height: radius * 2
                    ))
                    sphereContext.clip(to: sphereClip)
                    
                    // Draw red/white checkered grid
                    let columns = 12
                    let rows = 12
                    let gridRotation = rotationAngle
                    
                    for row in 0..<rows {
                        let yRatioStart = CGFloat(row) / CGFloat(rows)
                        let yRatioEnd = CGFloat(row + 1) / CGFloat(rows)
                        
                        // Map flat Y to spherical latitude
                        let latStart = (yRatioStart - 0.5) * .pi
                        let latEnd = (yRatioEnd - 0.5) * .pi
                        
                        let yStart = center.y + radius * sin(latStart) - (abs(sin(bouncePhase)) * 20)
                        let yEnd = center.y + radius * sin(latEnd) - (abs(sin(bouncePhase)) * 20)
                        
                        let spanStart = radius * cos(latStart)
                        let spanEnd = radius * cos(latEnd)
                        
                        for col in 0..<columns {
                            let angleStart = (CGFloat(col) / CGFloat(columns)) * 2 * .pi + CGFloat(gridRotation)
                            let angleEnd = (CGFloat(col + 1) / CGFloat(columns)) * 2 * .pi + CGFloat(gridRotation)
                            
                            // Checker parity
                            let isRed = (row + col) % 2 == 0
                            let color = isRed ? Color(red: 0.9, green: 0.1, blue: 0.1) : Color.white
                            
                            var patch = Path()
                            
                            // 4 points of spherical checker patch
                            let p1 = CGPoint(x: center.x + spanStart * sin(angleStart), y: yStart)
                            let p2 = CGPoint(x: center.x + spanStart * sin(angleEnd), y: yStart)
                            let p3 = CGPoint(x: center.x + spanEnd * sin(angleEnd), y: yEnd)
                            let p4 = CGPoint(x: center.x + spanEnd * sin(angleStart), y: yEnd)
                            
                            patch.move(to: p1)
                            patch.addLine(to: p2)
                            patch.addLine(to: p3)
                            patch.addLine(to: p4)
                            patch.closeSubpath()
                            
                            sphereContext.fill(patch, with: .color(color))
                        }
                    }
                    
                    // 3D Spherical Shading Overlay (radial gloss and inner shadow)
                    let shadingRect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius - (abs(sin(bouncePhase)) * 20),
                        width: radius * 2,
                        height: radius * 2
                    )
                    
                    // Radial highlight representing top-left light source
                    var highlightPath = Path()
                    highlightPath.addEllipse(in: shadingRect)
                    let radGrad = Gradient(colors: [
                        Color.white.opacity(0.7),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.75)
                    ])
                    sphereContext.fill(
                        highlightPath,
                        with: .radialGradient(
                            radGrad,
                            center: CGPoint(x: shadingRect.midX - radius * 0.4, y: shadingRect.midY - radius * 0.4),
                            startRadius: 0,
                            endRadius: radius * 1.5
                        )
                    )
                }
            }
            .frame(width: 140, height: 160)
            .onReceive(timer) { _ in
                rotationAngle += 0.05
                bouncePhase += 0.04
            }
        }
    }
}

#Preview {
    BoingBallView()
        .background(Color.blue)
}
