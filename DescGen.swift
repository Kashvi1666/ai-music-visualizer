import Foundation

func generateDescription(from features: [String: [Double]], songTitle: String) -> String {
    var description = "A realistic cosmic image of a planet inspired by a scene with "

    // Debugging: Print MFCC values
    if let mfccs = features["mfccs"] {
        let avgMFCC = mfccs.reduce(0, +) / Double(mfccs.count)
        print("MFCCs: \(mfccs), Average MFCC: \(avgMFCC)")
        if avgMFCC <= 0 {
            description += "calm tones and simplistic visuals, with subtle shades of mostly "
        } else {
            description += "vibrant energy and complex visuals, with bright shades of mostly "
        }
    }

    // Debugging: Print Chroma values
    if let chroma = features["chroma"] {
        print("Chroma: \(chroma)")
        let dominantChroma = chroma.enumerated().max(by: { $0.element < $1.element })?.offset ?? -1
        print("Dominant Chroma Index: \(dominantChroma)")
        switch dominantChroma {
        case 0: description += "reds, "
        case 1: description += "oranges, "
        case 2: description += "yellows, "
        case 3: description += "greens, "
        case 4: description += "blues, "
        case 5: description += "indigos, "
        case 6: description += "violets, "
        case 7: description += "pinks, "
        case 8: description += "purples, "
        default: description += "a spectrum of colors, " // Fallback in case something goes wrong
        }
    }

    // Debugging: Print Spectral Contrast values
    if let spectralContrast = features["spectral_contrast"] {
        let avgContrast = spectralContrast.reduce(0, +) / Double(spectralContrast.count)
        print("Spectral Contrast: \(spectralContrast), Average Contrast: \(avgContrast)")
        if avgContrast > 0 {
            description += "sharp/high contrast and "
        } else {
            description += "smooth/soft transitions and "
        }
    }

    description += "mysterious patterns. "
    description += "This image represents a planet inspired by the song '\(songTitle)'."

    return description
}
