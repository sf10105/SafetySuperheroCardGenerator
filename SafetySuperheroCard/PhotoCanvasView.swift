import SwiftUI

struct PhotoCanvasView: View {
    let userImage: UIImage
    let frameImage: UIImage

    // Constants matching your defined window
    let canvasSize = CGSize(width: 3005, height: 4349)
    let imageWindow = CGRect(x: 119.5, y: 242.5, width: 2766, height: 3247)

    // Zoom and drag state
    @State private var offset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Full canvas background (transparent)
            Color.clear
                .frame(width: canvasSize.width, height: canvasSize.height)

            // User image inside crop window
            GeometryReader { geo in
                let window = imageWindow

                ZStack {
                    Image(uiImage: userImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: window.width, height: window.height)
                        .scaleEffect(currentScale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in offset = value.translation }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    currentScale = min(max(1.0, newScale), 5.0)
                                }
                                .onEnded { _ in lastScale = currentScale }
                        )
                        .clipped()
                }
                .frame(width: window.width, height: window.height)
                .position(x: window.midX, y: window.midY)
                .clipped()
            }

            // Overlay frame on top
            Image(uiImage: frameImage)
                .resizable()
                .frame(width: canvasSize.width, height: canvasSize.height)
                .allowsHitTesting(false)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    // Optional: expose the transform data for export if needed
    var renderedPhotoFrame: CGRect {
        imageWindow
    }

    var effectiveScale: CGFloat {
        currentScale
    }

    var effectiveOffset: CGSize {
        offset
    }
}

