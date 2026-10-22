import AVFoundation

@MainActor
final class Recorder: NSObject, ObservableObject {
    @Published var recording = false
    @Published var level: Float = -80

    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    func request() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func start(url: URL) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.allowBluetooth])
        try session.setActive(true)
        recorder = try AVAudioRecorder(
            url: url,
            settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 22_050,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 64_000,
            ]
        )
        recorder?.isMeteringEnabled = true
        guard recorder?.record() == true else { throw CocoaError(.fileWriteUnknown) }
        recording = true
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.recorder?.updateMeters()
            self?.level = self?.recorder?.averagePower(forChannel: 0) ?? -80
        }
    }

    func stop() {
        recorder?.stop()
        timer?.invalidate()
        recording = false
    }
}
