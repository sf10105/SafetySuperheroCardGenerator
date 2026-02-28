import SwiftUI

struct CardResult: View {
    let name: String
    let level: String
    let position: String
    let qualifications: [String]
    let photo: Image?

    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0

    // Your qualification-to-icon mapping
    let qualificationIcons: [String: String] = [
        "First Aider": "First Aider",
        "Fire Warden": "Fire Warden",
        "Combi Driver": "Combi Driver",
        "Scissor Lift Operator": "Scissor Lift Operator",
        "Fork Lifter": "Forklift Icon",
        "A Grade Forklifter": "A Grade Forklifter",
        "B Grade Forklifter": "B Grade Forklifter",
        "Forklift Coach": "Gold Star"
    ]

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geo in
                let cardSize = geo.size

                ZStack {
                    // Photo layer — draggable, zoomable, and clipped to card shape
                    ZStack {
                        if let photo = photo {
                            photo
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }

                    }
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // ✅ Clipping applied here

                    // Card frame overlay
                    Image("\(level) Playing Card")
                        .resizable()
                        .scaledToFit()
                        .frame(width: cardSize.width, height: cardSize.height)

                    // Text and icons
                    VStack(alignment: .leading, spacing: 8) {
                        Text(name)
                            .font(.custom("Futura-Medium", size: 28))
                            .foregroundColor(.white)
                            .textCase(.uppercase)

                        Text(position)
                            .font(.custom("Futura-Medium", size: 16))
                            .foregroundColor(.white)
                            .textCase(.uppercase)

                        Spacer().frame(height: 12)

                        HStack(spacing: 12) {
                            ForEach(qualifications, id: \.self) { item in
                                if let icon = qualificationIcons[item] {
                                    Image(icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(qualifications, id: \.self) { item in
                                Text("• \(item)")
                                    .font(.custom("Futura-Medium", size: 12))
                                    .foregroundColor(.white)
                                    .textCase(.uppercase)
                            }
                        }

                        Spacer()
                    }
                    .padding()
                    .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
                }
                .frame(width: cardSize.width, height: cardSize.height)
                .cornerRadius(12)
            }
            .aspectRatio(0.66, contentMode: .fit)

            // Reset zoom and drag
            Button("Reset Image") {
                dragOffset = .zero
                currentScale = 1.0
                lastScale = 1.0
            }
            .buttonStyle(.bordered)
            .font(.custom("Futura-Medium", size: 14))
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    CardResult(
        name: "Sarah",
        level: "Complex Manager",
        position: "Complex Manager",
        qualifications: ["First Aider", "Forklift Coach", "Fire Warden"],
        photo: Image("Kyle") // Replace with your asset name
    )
}

