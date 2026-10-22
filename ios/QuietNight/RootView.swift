import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TonightView().tabItem { Label("Tonight", systemImage: "moon.stars") }
            HistoryView().tabItem { Label("History", systemImage: "chart.xyaxis.line") }
            PrivacyView().tabItem { Label("Privacy", systemImage: "lock.shield") }
        }
        .tint(.indigo)
    }
}

struct TonightView: View {
    @EnvironmentObject var store: SessionStore
    @StateObject var recorder = Recorder()
    @State private var error = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: recorder.recording ? "waveform.circle.fill" : "moon.zzz.fill")
                        .font(.system(size: 72)).foregroundStyle(.indigo)
                    Text(recorder.recording ? "QuietNight is listening" : "Ready for a quieter night")
                        .font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text("Audio stays on this iPhone. Calibrate in your normal room before bed to reduce fan, pet, sheet, and partner false positives.")
                        .foregroundStyle(.secondary)
                    if recorder.recording {
                        ProgressView(value: Double(max(-80, recorder.level) + 80), total: 80)
                            .accessibilityLabel("Sound level")
                        Button("End and save night", role: .destructive) {
                            recorder.stop(); store.finish()
                        }
                    } else {
                        Button("Calibrate and start") { start() }
                            .buttonStyle(.borderedProminent).controlSize(.large)
                    }
                    Label("Free forever • no account • no ads", systemImage: "checkmark.seal.fill")
                    Text("Not a medical device. QuietNight cannot diagnose sleep apnea. Gasping, breathing pauses, or daytime sleepiness should be discussed with a clinician.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("QuietNight")
            .alert("Couldn’t start", isPresented: Binding(get: { !error.isEmpty }, set: { if !$0 { error = "" } })) {
                Button("OK") { error = "" }
            } message: { Text(error) }
        }
    }

    private func start() {
        Task {
            guard await recorder.request() else { error = "Microphone access is required."; return }
            let name = "night-\(UUID().uuidString).m4a"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
            do { try recorder.start(url: url); store.begin(file: name) }
            catch { self.error = error.localizedDescription }
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var store: SessionStore
    var body: some View {
        NavigationStack {
            List {
                if store.sessions.isEmpty {
                    ContentUnavailableView("No nights yet", systemImage: "moon", description: Text("Your first local recording will appear here."))
                }
                ForEach(store.sessions) { session in
                    NavigationLink {
                        SessionDetail(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.started.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                            Text("Score \(session.score) • \(session.events.count) high-confidence events").foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions { Button("Delete", role: .destructive) { store.delete(session) } }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct SessionDetail: View {
    let session: NightSession
    var body: some View {
        List {
            Section("Confidence-aware result") {
                LabeledContent("Night score", value: "\(session.score)")
                Text("Low-confidence noises are retained for review, not counted as certain snoring.")
            }
            Section("Timeline") {
                ForEach(session.events) { event in
                    HStack {
                        Text(Date(timeIntervalSince1970: session.started.timeIntervalSince1970 + event.offset).formatted(date: .omitted, time: .shortened))
                        Spacer()
                        Text("Level \(event.severity) • \(Int(event.confidence * 100))%")
                    }
                }
            }
            Section("Interpretation") {
                Text("Scores help compare nights; they do not identify who made a sound or diagnose a condition.")
            }
        }
        .navigationTitle("Night details")
    }
}

struct PrivacyView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Your data") {
                    Label("On-device by default", systemImage: "iphone")
                    Label("No account or analytics", systemImage: "person.crop.circle.badge.xmark")
                    Label("Export only when you choose", systemImage: "square.and.arrow.up")
                }
                Section("Transparent limits") {
                    Text("A phone microphone can confuse bedding, pets, fans, traffic, and a partner with snoring. Review clips and confidence before drawing conclusions.")
                    Text("QuietNight does not detect apnea and is not a substitute for a sleep study.")
                }
                Section("Pricing") {
                    Text("This open-source edition has no subscription, ads, locked nights, or surprise trial.")
                }
            }
            .navigationTitle("Privacy & limits")
        }
    }
}
