import SwiftUI
import PhotosUI
import UIKit

fileprivate final class IconCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct ExportView: View {
    let name: String
    let level: String
    let position: String
    let qualifications: [String]
    let photo: UIImage?

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var userImage: UIImage? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var baseDrag: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    private let canvasSize = CGSize(width: 3005, height: 4349)
    private let imageWindow = CGRect(x: 119.5, y: 242.5, width: 2766, height: 3247)

    private let sidePadding: CGFloat = 8

    private let futuraPS = "Futura-Medium"
    private let nameSize: CGFloat = 250
    private let positionSize: CGFloat = 105
    private let bulletSize: CGFloat = 113.73

    private var nameFontSwiftUI: Font     { .custom(futuraPS, size: nameSize) }
    private var positionFontSwiftUI: Font { .custom(futuraPS, size: positionSize) }
    private var bulletFontSwiftUI: Font   { .custom(futuraPS, size: bulletSize) }

    private var nameFontUIKit: UIFont     { UIFont(name: futuraPS, size: nameSize) ?? .systemFont(ofSize: nameSize) }
    private var positionFontUIKit: UIFont { UIFont(name: futuraPS, size: positionSize) ?? .systemFont(ofSize: positionSize) }
    private var bulletFontUIKit: UIFont   { UIFont(name: futuraPS, size: bulletSize) ?? .systemFont(ofSize: bulletSize) }

    private let textLeftX: CGFloat = 156.33
    private let nameTopY: CGFloat = 148.98
    private let positionTopY: CGFloat = 423.72

    private let iconsLeftX: CGFloat = 126
    private let iconsTopY: CGFloat = 3114
    private let iconSize: CGFloat = 362
    private let iconGap: CGFloat = 2
    private let rightPadding: CGFloat = 126      // visual padding from right edge of the card
    private let minBulletsTopY: CGFloat = 3552.78
    private let edgeBleed: CGFloat = 1

    private let qualificationIcons: [String: String] = [
        "First Aider": "First Aider",
        "Fire Warden": "Fire Warden",
        "Combi Driver": "Combi Driver",
        "Scissor Lift Operator": "Scissor Lift Operator",
        "Fork Lifter": "Forklift Icon",
        "A Grade Forklifter": "A Grade Forklifter",
        "B Grade Forklifter": "B Grade Forklifter",
        "Return to Work Organiser": "Return To Work Organiser",
        "Walkie Stacker Operator": "Walkie Symbol"
    ]

    private func frameImageName(for level: String) -> String {
        ["Complex Manager": "Complex Manager Playing Card"][level] ?? "Complex Manager Playing Card"
    }

    private var iconDisplayItems: [IconDisplayItem] {
        var items: [IconDisplayItem] = []

        let hasForkliftCoach = qualifications.contains("Forklift Coach")

        for qualification in qualifications {
            switch qualification {
            case "A Grade Forklifter":
                items.append(
                    IconDisplayItem(
                        baseIconName: "A Grade Forklifter",
                        overlayIconName: hasForkliftCoach ? "Gold Star" : nil
                    )
                )

            case "B Grade Forklifter":
                items.append(
                    IconDisplayItem(
                        baseIconName: "B Grade Forklifter",
                        overlayIconName: hasForkliftCoach ? "Gold Star" : nil
                    )
                )

            case "Forklift Coach":
                // Don't add a separate icon for this
                break

            default:
                if let iconName = qualificationIcons[qualification] {
                    items.append(
                        IconDisplayItem(
                            baseIconName: iconName,
                            overlayIconName: nil
                        )
                    )
                }
            }
        }

        return items
    }
    
    private var bulletLines: [String] {
        var lines: [String] = []
        let hasCoach = qualifications.contains("Forklift Coach")

        for q in qualifications {
            switch q {

            case "A Grade Forklifter":
                if hasCoach {
                    lines.append("A GRADE FORKLIFTER - FORKLIFT COACH")
                } else {
                    lines.append("A GRADE FORKLIFTER")
                }

            case "B Grade Forklifter":
                if hasCoach {
                    lines.append("B GRADE FORKLIFTER - FORKLIFT COACH")
                } else {
                    lines.append("B GRADE FORKLIFTER")
                }

            case "Forklift Coach":
                // Skip — handled above
                break

            default:
                lines.append(q.uppercased())
            }
        }

        return lines
    }
    
    private struct IconDisplayItem: Identifiable {
        let id = UUID()
        let baseIconName: String
        let overlayIconName: String?
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            let screenW = UIScreen.main.bounds.width
            let targetW = max(200, screenW - sidePadding * 2)
            let scale = min(1.0, targetW / canvasSize.width)
            let scaledW = canvasSize.width * scale
            let scaledH = canvasSize.height * scale

            HStack(spacing: 0) {
                Spacer(minLength: sidePadding)

                ZStack(alignment: .topLeading) {
                    Color.clear
                        .frame(width: canvasSize.width, height: canvasSize.height)

                    // USER PHOTO
                    ZStack {
                        if let ui = userImage {
                            let imageAspect = ui.size.width / ui.size.height
                            let windowAspect = imageWindow.width / imageWindow.height
                            let baseW = imageAspect > windowAspect ? imageWindow.height * imageAspect : imageWindow.width
                            let baseH = imageAspect > windowAspect ? imageWindow.height : imageWindow.width / imageAspect

                            let w = baseW * currentScale
                            let h = baseH * currentScale

                            Image(uiImage: ui)
                                .resizable()
                                .frame(width: w, height: h)
                                .position(
                                    x: imageWindow.width / 2 + dragOffset.width,
                                    y: imageWindow.height / 2 + dragOffset.height
                                )
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let proposed = CGSize(
                                                width: baseDrag.width + value.translation.width,
                                                height: baseDrag.height + value.translation.height
                                            )
                                            dragOffset = clampedOffset(
                                                proposed: proposed,
                                                content: CGSize(width: w, height: h),
                                                window: imageWindow.size
                                            )
                                        }
                                        .onEnded { _ in baseDrag = dragOffset }
                                )
                                .simultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let minScale: CGFloat = 1.0
                                            let maxScale: CGFloat = 5.0
                                            currentScale = min(max(minScale, lastScale * value), maxScale)

                                            let newW = baseW * currentScale
                                            let newH = baseH * currentScale
                                            dragOffset = clampedOffset(
                                                proposed: dragOffset,
                                                content: CGSize(width: newW, height: newH),
                                                window: imageWindow.size
                                            )
                                            baseDrag = dragOffset
                                        }
                                        .onEnded { _ in
                                            lastScale = currentScale
                                            baseDrag = dragOffset
                                        }
                                )
                        }
                    }
                    .frame(width: imageWindow.width, height: imageWindow.height)
                    .background(Color.clear)
                    .clipped()
                    .offset(x: imageWindow.minX, y: imageWindow.minY)

                    if let frame = UIImage(named: frameImageName(for: level)) {
                        Image(uiImage: frame)
                            .resizable()
                            .frame(width: canvasSize.width, height: canvasSize.height)
                            .allowsHitTesting(false)
                    }

                    Text(name.uppercased())
                        .font(nameFontSwiftUI)
                        .foregroundColor(.white)
                        .fixedSize()
                        .offset(x: textLeftX, y: nameTopY)

                    Text(position.uppercased())
                        .font(positionFontSwiftUI)
                        .foregroundColor(.white)
                        .fixedSize()
                        .offset(x: textLeftX, y: positionTopY)

                    // Build icon images
                    let iconImages: [UIImage] = iconDisplayItems.compactMap {
                        iconDisplayImage(baseName: $0.baseIconName, overlayName: $0.overlayIconName)
                    }

                    // Keep a small gap up to 4 icons, then begin overlapping if needed to stay within the frame
                    let frameMaxWidth = canvasSize.width - iconsLeftX - rightPadding
                    let rowWidthCap = min(frameMaxWidth, iconSize * 4.8)
                    let n = iconImages.count

                    let normalGap: CGFloat = 16
                    let minSpacing: CGFloat = -iconSize * 0.6

                    let effectiveSpacing: CGFloat = {
                        guard n > 1 else { return 0 }

                        if n <= 4 {
                            return normalGap
                        }

                        let spacingToFit = (rowWidthCap - CGFloat(n) * iconSize) / CGFloat(n - 1)
                        return max(spacingToFit, minSpacing)
                    }()
                    
                    let iconCanvasExtraTop: CGFloat = iconSize * 0.28
                    let iconCanvasHeight = iconSize + iconCanvasExtraTop

                    HStack(spacing: effectiveSpacing) {
                        ForEach(iconImages.indices, id: \.self) { i in
                            Image(uiImage: iconImages[i])
                                .frame(width: iconSize, height: iconCanvasHeight, alignment: .topLeading)
                        }
                    }
                    .offset(x: iconsLeftX, y: iconsTopY - iconCanvasExtraTop)

                    let bulletsTop = max(minBulletsTopY, iconsTopY + iconSize + 48)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(bulletLines, id: \.self) { line in
                            Text("• \(line)")
                                .font(bulletFontSwiftUI)
                                .foregroundColor(.white)
                                .frame(height: 132.98, alignment: .topLeading)
                        }
                    }
                    .offset(x: 149.2, y: bulletsTop)
                }
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: scaledW, height: scaledH, alignment: .topLeading)

                Spacer(minLength: sidePadding)
            }
            .frame(maxWidth: .infinity)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Select Photo", systemImage: "photo")
            }
            .onChange(of: selectedPhoto) { _, newValue in
                if let item = newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            userImage = ui
                            setInitialPhotoState()
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Export as PNG") {
                    if let final = generateFinalImage() { shareImage(final) }
                }
                Button("Reset Image") {
                    setInitialPhotoState()
                }
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 12)
        }
        .onAppear {
            userImage = photo
            setInitialPhotoState()
        }
        .onChange(of: photo) { _, _ in userImage = photo; setInitialPhotoState() }
        .onChange(of: name) { _, _ in setInitialPhotoState() }
        .onChange(of: level) { _, _ in setInitialPhotoState() }
        .onChange(of: position) { _, _ in setInitialPhotoState() }
        .onChange(of: qualifications) { _, _ in setInitialPhotoState() }
    }

    private func normalizedIconTightCached(named name: String, target: CGFloat, edgeBleed: CGFloat) -> UIImage? {
        let key = "tight:\(name)#\(Int(target.rounded()))#\(Int(edgeBleed.rounded()))" as NSString
        if let cached = IconCache.shared.object(forKey: key) { return cached }
        guard let src = UIImage(named: name) else { return nil }
        let img = src.normalizedIconTight(target: target, alphaThreshold: 8, edgeBleed: edgeBleed)
        IconCache.shared.setObject(img, forKey: key)
        return img
    }
    
    private func iconDisplayImage(baseName: String, overlayName: String?) -> UIImage? {
        guard let base = normalizedIconTightCached(named: baseName, target: iconSize, edgeBleed: edgeBleed) else {
            return nil
        }

        let extraTop: CGFloat = iconSize * 0.28
        let canvasWidth = iconSize
        let canvasHeight = iconSize + extraTop
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasWidth, height: canvasHeight))
        return renderer.image { _ in
            guard let ctx = UIGraphicsGetCurrentContext() else { return }

            // Draw every base icon in the same position
            let baseRect = CGRect(x: 0, y: extraTop, width: iconSize, height: iconSize)
            base.draw(in: baseRect)

            // Only add the badge when needed
            if let overlayName,
               let overlay = normalizedIconTightCached(named: overlayName, target: iconSize, edgeBleed: edgeBleed) {

                let starSize: CGFloat = iconSize * 0.48
                let starX = iconSize - starSize * 1.02
                let starY = extraTop - starSize * 0.2
                let starRect = CGRect(x: starX, y: starY, width: starSize, height: starSize)

                ctx.saveGState()
                ctx.setShadow(
                    offset: CGSize(width: 0, height: 6),
                    blur: 10,
                    color: UIColor.black.withAlphaComponent(0.45).cgColor
                )
                overlay.draw(in: starRect)
                ctx.restoreGState()
            }
        }
    }

    private func setInitialPhotoState() {
        currentScale = 1.0
        lastScale = 1.0
        dragOffset = .zero
        baseDrag = .zero
    }

    private func generateFinalImage() -> UIImage? {
        guard let ui = userImage,
              let frame = UIImage(named: frameImageName(for: level)) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { _ in
            let imageAspect = ui.size.width / ui.size.height
            let windowAspect = imageWindow.width / imageWindow.height
            let baseW  = imageAspect > windowAspect ? imageWindow.height * imageAspect : imageWindow.width
            let baseH  = imageAspect > windowAspect ? imageWindow.height : imageWindow.width / imageAspect

            let w = baseW * currentScale
            let h = baseH * currentScale

            let maxX = max(0, (w - imageWindow.width)  / 2)
            let maxY = max(0, (h - imageWindow.height) / 2)
            let dx = min(max(dragOffset.width,  -maxX), maxX)
            let dy = min(max(dragOffset.height, -maxY), maxY)

            let drawRect = CGRect(
                x: imageWindow.midX - w/2 + dx,
                y: imageWindow.midY - h/2 + dy,
                width: w,
                height: h
            )

            ui.draw(in: drawRect)
            frame.draw(in: CGRect(origin: .zero, size: canvasSize))

            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: nameFontUIKit, .foregroundColor: UIColor.white
            ]
            name.uppercased().draw(at: CGPoint(x: textLeftX, y: nameTopY), withAttributes: nameAttrs)

            let posAttrs: [NSAttributedString.Key: Any] = [
                .font: positionFontUIKit, .foregroundColor: UIColor.white
            ]
            position.uppercased().draw(at: CGPoint(x: textLeftX, y: positionTopY), withAttributes: posAttrs)

            let images: [UIImage] = iconDisplayItems.compactMap {
                iconDisplayImage(baseName: $0.baseIconName, overlayName: $0.overlayIconName)
            }
            
            // Match SwiftUI preview spacing logic for export
            let frameMaxWidth = canvasSize.width - iconsLeftX - rightPadding
            let rowWidthCap = min(frameMaxWidth, iconSize * 4.8)
            let n = images.count

            let normalGap: CGFloat = 16
            let minSpacing: CGFloat = -iconSize * 0.6

            let effectiveSpacing: CGFloat = {
                guard n > 1 else { return 0 }

                if n <= 4 {
                    return normalGap
                }

                let spacingToFit = (rowWidthCap - CGFloat(n) * iconSize) / CGFloat(n - 1)
                return max(spacingToFit, minSpacing)
            }()

            let iconCanvasExtraTop: CGFloat = iconSize * 0.28
            let iconCanvasWidth = iconSize
            let iconCanvasHeight = iconSize + iconCanvasExtraTop

            var x = iconsLeftX
            for img in images {
                img.draw(in: CGRect(
                    x: x,
                    y: iconsTopY - iconCanvasExtraTop,
                    width: iconCanvasWidth,
                    height: iconCanvasHeight
                ))
                x += iconSize + effectiveSpacing
            }

            let bulletsTop = max(minBulletsTopY, iconsTopY + iconSize + 48)
            let bulletAttrs: [NSAttributedString.Key: Any] = [
                .font: bulletFontUIKit, .foregroundColor: UIColor.white
            ]
            var bulletY = bulletsTop
            for line in bulletLines {
                ("• " + line).draw(at: CGPoint(x: 149.2, y: bulletY), withAttributes: bulletAttrs)
                bulletY += 132.98
            }
        }
    }

    private func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { ($0 as? UIWindowScene)?.activationState == .foregroundActive }) as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}

private func clampedOffset(proposed: CGSize, content: CGSize, window: CGSize) -> CGSize {
    let eps: CGFloat = 0.5
    let maxX = max(0, (content.width  - window.width)  / 2) - eps
    let maxY = max(0, (content.height - window.height) / 2) - eps
    let cx = min(max(proposed.width,  -maxX), maxX)
    let cy = min(max(proposed.height, -maxY), maxY)
    return CGSize(width: cx, height: cy)
}

extension UIImage {
    fileprivate func alphaBoundingBox(threshold: UInt8 = 1) -> CGRect? {
        guard let cg = self.cgImage else { return nil }
        let width = cg.width, height = cg.height
        let bytesPerPixel = 4, bytesPerRow = bytesPerPixel * width

        guard let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let buf = ctx.data else { return nil }
        let data = buf.bindMemory(to: UInt8.self, capacity: bytesPerRow * height)

        var minX = width, minY = height, maxX = 0, maxY = 0
        for y in 0..<height {
            let row = y * bytesPerRow
            for x in 0..<width {
                let a = data[row + x * bytesPerPixel + 3]
                if a > threshold {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        if maxX < minX || maxY < minY { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    fileprivate func normalizedIconTight(target: CGFloat,
                                         alphaThreshold: UInt8 = 8,
                                         edgeBleed: CGFloat = 1) -> UIImage {
        let targetSize = CGSize(width: target, height: target)

        if var box = self.alphaBoundingBox(threshold: alphaThreshold), let cg = self.cgImage {
            box.origin.x = max(0, box.origin.x - edgeBleed)
            box.origin.y = max(0, box.origin.y - edgeBleed)
            box.size.width  = min(CGFloat(cg.width)  - box.origin.x, box.size.width  + 2*edgeBleed)
            box.size.height = min(CGFloat(cg.height) - box.origin.y, box.size.height + 2*edgeBleed)

            if let cropped = cg.cropping(to: box) {
                let croppedImg = UIImage(cgImage: cropped, scale: self.scale, orientation: self.imageOrientation)
                let scaleFactor = min(targetSize.width / box.size.width, targetSize.height / box.size.height)
                let w = box.size.width * scaleFactor
                let h = box.size.height * scaleFactor
                let draw = CGRect(x: (target - w)/2, y: (target - h)/2, width: w, height: h)

                let renderer = UIGraphicsImageRenderer(size: targetSize)
                return renderer.image { _ in
                    croppedImg.draw(in: draw)
                }
            }
        }

        let scaleFactor = min(targetSize.width / size.width, targetSize.height / size.height)
        let w = size.width * scaleFactor
        let h = size.height * scaleFactor
        let draw = CGRect(x: (target - w)/2, y: (target - h)/2, width: w, height: h)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: draw)
        }
    }
}
