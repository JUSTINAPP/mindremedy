import SwiftUI

/// Small shapes matching the bottom nav row in design-reference/Main.dc.html
/// (a dotted circle, a circle with a play mark, a magnifying glass, and
/// ascending bars) rather than reaching for unrelated SF Symbols.
struct NavIcon: View {
    enum Kind {
        case home, practice, explore, progress
    }

    let kind: Kind
    let color: Color

    var body: some View {
        switch kind {
        case .home:
            ZStack {
                Circle().stroke(color, lineWidth: 1.6)
                Circle().fill(color).frame(width: 5, height: 5)
            }
            .frame(width: 20, height: 20)
        case .practice:
            ZStack {
                Circle().stroke(color, lineWidth: 1.6)
                PlayTriangle().fill(color).frame(width: 7, height: 7).offset(x: 1)
            }
            .frame(width: 20, height: 20)
        case .explore:
            ZStack {
                Circle().stroke(color, lineWidth: 1.6).frame(width: 15, height: 15)
                    .offset(x: -2.5, y: -2.5)
                Path { p in
                    p.move(to: CGPoint(x: 12, y: 12))
                    p.addLine(to: CGPoint(x: 18, y: 18))
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
            .frame(width: 20, height: 20)
        case .progress:
            HStack(alignment: .bottom, spacing: 3) {
                RoundedRectangle(cornerRadius: 1).frame(width: 3, height: 9)
                RoundedRectangle(cornerRadius: 1).frame(width: 3, height: 15)
                RoundedRectangle(cornerRadius: 1).frame(width: 3, height: 6)
            }
            .foregroundColor(color)
            .frame(width: 20, height: 20, alignment: .bottom)
        }
    }
}

private struct PlayTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
