import AVFoundation
import Accelerate

class AudioAnalyzer {
    func extractFeatures(from url: URL) -> [String: [Double]]? {
        do {
            let file = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else {
                print("Failed to create AVAudioPCMBuffer")
                return nil
            }
            try file.read(into: buffer)
            guard let floatChannelData = buffer.floatChannelData else {
                print("Failed to get float channel data")
                return nil
            }

            let frameLength = Int(buffer.frameLength)
            var data = [Float](repeating: 0.0, count: frameLength)
            for i in 0..<frameLength {
                data[i] = floatChannelData[0][i]
            }

            let mfccs = computeMFCCs(data: data, sampleRate: file.fileFormat.sampleRate)
            let chroma = computeChroma(data: data, sampleRate: file.fileFormat.sampleRate)
            let spectralContrast = computeSpectralContrast(data: data, sampleRate: file.fileFormat.sampleRate)

            return [
                "mfccs": mfccs,
                "chroma": chroma,
                "spectral_contrast": spectralContrast
            ]
        } catch {
            print("Failed to read audio file: \(error.localizedDescription)")
            return nil
        }
    }

    private func computeMFCCs(data: [Float], sampleRate: Double) -> [Double] {
        let fftLength = 1024
        let log2n = vDSP_Length(log2(Double(fftLength)))
        let halfLength = fftLength / 2

        var window = [Float](repeating: 0, count: fftLength)
        var real = [Float](repeating: 0, count: halfLength)
        var imag = [Float](repeating: 0, count: halfLength)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)

        vDSP_hann_window(&window, vDSP_Length(fftLength), Int32(vDSP_HANN_NORM))
        var windowedData = [Float](repeating: 0, count: fftLength)
        vDSP_vmul(data, 1, window, 1, &windowedData, 1, vDSP_Length(fftLength))

        let fftSetup = vDSP_create_fftsetup(log2n, Int32(FFT_RADIX2))
        windowedData.withUnsafeBufferPointer { dataPointer in
            let dataAddress = dataPointer.baseAddress!
            dataAddress.withMemoryRebound(to: DSPComplex.self, capacity: fftLength) { typeConvertedData in
                vDSP_ctoz(typeConvertedData, 2, &splitComplex, 1, vDSP_Length(halfLength))
            }
        }

        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, Int32(FFT_FORWARD))
        vDSP_zvabs(&splitComplex, 1, &real, 1, vDSP_Length(halfLength))

        vDSP_destroy_fftsetup(fftSetup)
        
        let mfccs = real.prefix(13).map { Double($0) }
        return mfccs
    }

    private func computeChroma(data: [Float], sampleRate: Double) -> [Double] {
        let fftLength = 1024
        let log2n = vDSP_Length(log2(Double(fftLength)))
        let halfLength = fftLength / 2

        var window = [Float](repeating: 0, count: fftLength)
        var real = [Float](repeating: 0, count: halfLength)
        var imag = [Float](repeating: 0, count: halfLength)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)

        vDSP_hann_window(&window, vDSP_Length(fftLength), Int32(vDSP_HANN_NORM))
        var windowedData = [Float](repeating: 0, count: fftLength)
        vDSP_vmul(data, 1, window, 1, &windowedData, 1, vDSP_Length(fftLength))

        let fftSetup = vDSP_create_fftsetup(log2n, Int32(FFT_RADIX2))
        windowedData.withUnsafeBufferPointer { dataPointer in
            let dataAddress = dataPointer.baseAddress!
            dataAddress.withMemoryRebound(to: DSPComplex.self, capacity: fftLength) { typeConvertedData in
                vDSP_ctoz(typeConvertedData, 2, &splitComplex, 1, vDSP_Length(halfLength))
            }
        }

        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, Int32(FFT_FORWARD))
        vDSP_zvabs(&splitComplex, 1, &real, 1, vDSP_Length(halfLength))

        vDSP_destroy_fftsetup(fftSetup)
        
        let chroma = real.prefix(12).map { Double($0) }
        return chroma
    }

    private func computeSpectralContrast(data: [Float], sampleRate: Double) -> [Double] {
        let fftLength = 1024
        let log2n = vDSP_Length(log2(Double(fftLength)))
        let halfLength = fftLength / 2

        var window = [Float](repeating: 0, count: fftLength)
        var real = [Float](repeating: 0, count: halfLength)
        var imag = [Float](repeating: 0, count: halfLength)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)

        vDSP_hann_window(&window, vDSP_Length(fftLength), Int32(vDSP_HANN_NORM))
        var windowedData = [Float](repeating: 0, count: fftLength)
        vDSP_vmul(data, 1, window, 1, &windowedData, 1, vDSP_Length(fftLength))

        let fftSetup = vDSP_create_fftsetup(log2n, Int32(FFT_RADIX2))
        windowedData.withUnsafeBufferPointer { dataPointer in
            let dataAddress = dataPointer.baseAddress!
            dataAddress.withMemoryRebound(to: DSPComplex.self, capacity: fftLength) { typeConvertedData in
                vDSP_ctoz(typeConvertedData, 2, &splitComplex, 1, vDSP_Length(halfLength))
            }
        }

        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, Int32(FFT_FORWARD))
        vDSP_zvabs(&splitComplex, 1, &real, 1, vDSP_Length(halfLength))

        vDSP_destroy_fftsetup(fftSetup)
        
        let spectralContrast = real.prefix(6).map { Double($0) }
        return spectralContrast
    }
}
