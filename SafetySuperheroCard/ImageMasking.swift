import UIKit

func applyMaskToPhoto(photo: UIImage, maskImageName: String) -> UIImage? {
    guard let maskImage = UIImage(named: maskImageName)?.cgImage else { return nil }
    guard let inputCGImage = photo.cgImage else { return nil }

    let mask = CGImage(
        maskWidth: maskImage.width,
        height: maskImage.height,
        bitsPerComponent: maskImage.bitsPerComponent,
        bitsPerPixel: maskImage.bitsPerPixel,
        bytesPerRow: maskImage.bytesPerRow,
        provider: maskImage.dataProvider!,
        decode: nil,
        shouldInterpolate: false
    )

    guard let masked = inputCGImage.masking(mask!) else { return nil }

    return UIImage(cgImage: masked, scale: photo.scale, orientation: photo.imageOrientation)
}
