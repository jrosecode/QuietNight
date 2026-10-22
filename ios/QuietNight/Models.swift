import Foundation

struct SnoreEvent: Codable, Identifiable {
    var id = UUID()
    var offset: TimeInterval
    var duration: TimeInterval
    var severity: Int
    var confidence: Double
}

struct NightSession: Codable, Identifiable {
    var id = UUID()
    var started = Date()
    var ended: Date?
    var audioFile: String
    var events: [SnoreEvent] = []
    var factors: [String] = []
    var notes = ""
    var interrupted = false

    var score: Int {
        guard !events.isEmpty else { return 0 }
        let weightedEvents = events.map { event in
            Double(event.severity) * event.confidence
        }
        let average = weightedEvents.reduce(0.0, +) / Double(events.count)
        return min(100, Int(average * 33.3))
    }
}
