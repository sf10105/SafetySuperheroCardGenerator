import UIKit

func compositeCard_DEBUG(
    photo: UIImage,
    cardFrame: UIImage,
    name: String,
    position: String,
    qualifications: [String],
    qualificationIcons: [String: UIImage]
) -> UIImage {
    let canvasSize = CGSize(width: 3005, height: 4349)
    let imageWindow = CGRect(x: 119.5, y: 242.5, width: 2766, height: 3247)

    let renderer = UIGraphicsImageRenderer(size: canvasSize)

    return renderer.image { _ in
        // 1. Draw the user photo cropped to window with proportional fill
        let imageAspect = photo.size.width / photo.size.height
        let windowAspect = imageWindow.width / imageWindow.height

        var drawRect = CGRect.zero
        if imageAspect > windowAspect {
            let scaledWidth = imageWindow.height * imageAspect
            drawRect = CGRect(
                x: imageWindow.midX - scaledWidth / 2,
                y: imageWindow.minY,
                width: scaledWidth,
                height: imageWindow.height
            )
        } else {
            let scaledHeight = imageWindow.width / imageAspect
            drawRect = CGRect(
                x: imageWindow.minX,
                y: imageWindow.midY - scaledHeight / 2,
                width: imageWindow.width,
                height: scaledHeight
            )
        }
        photo.draw(in: drawRect)

        // 2. Draw name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Futura-Medium", size: 250) ?? UIFont.systemFont(ofSize: 250),
            .foregroundColor: UIColor.white
        ]
        let namePoint = CGPoint(x: 1161.27, y: 148.98)
        name.uppercased().draw(at: namePoint, withAttributes: nameAttributes)

        // 3. Draw position
        let positionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Futura-Medium", size: 105) ?? UIFont.systemFont(ofSize: 105),
            .foregroundColor: UIColor.white
        ]
        let positionPoint = CGPoint(x: 156.33, y: 423.72)
        position.uppercased().draw(at: positionPoint, withAttributes: positionAttributes)

        // 4. Draw qualification icons
        let iconSize = CGSize(width: 362, height: 362)
        var iconX = CGFloat(126)
        let iconY = CGFloat(3114)

        for q in qualifications {
            if let icon = qualificationIcons[q] {
                let iconRect = CGRect(origin: CGPoint(x: iconX, y: iconY), size: iconSize)
                icon.draw(in: iconRect)
                iconX += iconSize.width + 20
            }
        }

        // 5. Draw bullet text list
        let bulletFontSize: CGFloat = 113.73
        let bulletLineHeight: CGFloat = 132.98
        let bulletAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Futura-Medium", size: bulletFontSize) ?? UIFont.systemFont(ofSize: bulletFontSize),
            .foregroundColor: UIColor.white
        ]

        let bulletX = CGFloat(149.2)
        var bulletY = CGFloat(3552.78)

        for q in qualifications {
            let bullet = "• " + q.uppercased()
            let textRect = CGRect(x: bulletX, y: bulletY, width: canvasSize.width - bulletX - 100, height: bulletLineHeight)
            bullet.draw(in: textRect, withAttributes: bulletAttributes)
            bulletY += bulletLineHeight
        }

        // 6. Draw card frame last
        cardFrame.draw(in: CGRect(origin: .zero, size: canvasSize))
    }
}
