//
//  MoneyFlowAnimation.swift
//  HIG
//
//  Money Flow Animation - Animated money flow visualization
//  Duration: 1.2s | Easing: easeInOutQuint
//

import SwiftUI

struct MoneyFlowAnimation: View {
    @State private var isAnimating = false
    @State private var particles: [MoneyParticle] = []
    
    let duration: Double = 1.2
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Money Flow Animation").font(.headline)
            
            // Animation Container
            ZStack {
                // Flow Path
                MoneyFlowPath()
                    .stroke(Color.green.opacity(0.3), lineWidth: 4)
                
                // Animated Particles
                ForEach(particles) { particle in
                    MoneyParticleView(particle: particle, isAnimating: isAnimating)
                }
            }
            .frame(height: 60)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
            
            // Controls
            HStack {
                Button("Play") { startAnimation() }.buttonStyle(.borderedProminent)
                Button("Reset") { resetAnimation() }.buttonStyle(.bordered)
            }
            
            // Specs
            AnimationSpecView(name: "moneyFlow", duration: "1.2s", easing: "easeInOutQuint", size: "Full width, 60pt height")
        }
        .padding()
        .onAppear { setupParticles() }
    }
    
    func setupParticles() {
        particles = (0..<5).map { i in
            MoneyParticle(id: i, delay: Double(i) * 0.15)
        }
    }
    
    func startAnimation() {
        isAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: duration)) {
                isAnimating = true
            }
        }
    }
    
    func resetAnimation() {
        isAnimating = false
    }
}

struct MoneyParticle: Identifiable {
    let id: Int
    let delay: Double
}

struct MoneyParticleView: View {
    let particle: MoneyParticle
    let isAnimating: Bool
    
    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.title2)
            .foregroundStyle(.green)
            .offset(x: isAnimating ? 150 : -150)
            .opacity(isAnimating ? 0 : 1)
            .animation(.easeInOut(duration: 1.2).delay(particle.delay), value: isAnimating)
    }
}

struct MoneyFlowPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.3, y: rect.minY),
            control2: CGPoint(x: rect.width * 0.7, y: rect.maxY)
        )
        return path
    }
}

struct AnimationSpecView: View {
    let name: String
    let duration: String
    let easing: String
    let size: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Specifications").font(.subheadline.bold())
            HStack { Text("Name:").foregroundStyle(.secondary); Text(name).font(.caption.monospaced()) }
            HStack { Text("Duration:").foregroundStyle(.secondary); Text(duration) }
            HStack { Text("Easing:").foregroundStyle(.secondary); Text(easing) }
            HStack { Text("Size:").foregroundStyle(.secondary); Text(size) }
        }
        .font(.caption)
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
    }
}

#Preview { MoneyFlowAnimation().frame(width: 500, height: 400) }
