import Foundation
@MainActor final class SessionStore: ObservableObject { @Published var sessions:[NightSession]=[]; @Published var active:NightSession?; private let url:URL
 init(){url=FileManager.default.urls(for:.documentDirectory,in:.userDomainMask)[0].appendingPathComponent("sessions.json"); load(); recover()}
 func begin(file:String){active=NightSession(audioFile:file); save()}
 func finish(){guard var s=active else{return};s.ended=Date();sessions.insert(s,at:0);active=nil;save()}
 func add(event:SnoreEvent){active?.events.append(event);save()}
 func delete(_ s:NightSession){sessions.removeAll{$0.id==s.id};try? FileManager.default.removeItem(at:audioURL(s));save()}
 func audioURL(_ s:NightSession)->URL{url.deletingLastPathComponent().appendingPathComponent(s.audioFile)}
 func exportData()->Data?{try? JSONEncoder().encode(sessions)}
 private func recover(){if active != nil {active?.interrupted=true;save()}}
 private func load(){guard let d=try? Data(contentsOf:url),let x=try? JSONDecoder().decode([NightSession].self,from:d)else{return};sessions=x}
 func save(){try? FileManager.default.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true);try? JSONEncoder().encode(sessions).write(to:url,options:.atomic);if let a=active{try? JSONEncoder().encode(a).write(to:url.deletingLastPathComponent().appendingPathComponent("active.json"),options:.atomic)}} }
