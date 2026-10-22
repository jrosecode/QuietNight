import Foundation
struct SnoreEvent: Codable, Identifiable { var id=UUID(); var offset:TimeInterval; var duration:TimeInterval; var severity:Int; var confidence:Double }
struct NightSession: Codable, Identifiable { var id=UUID(); var started=Date(); var ended:Date?; var audioFile:String; var events:[SnoreEvent]=[]; var factors:[String]=[]; var notes=""; var interrupted=false; var score:Int { guard !events.isEmpty else{return 0}; return min(100,Int(events.map{Double($0.severity)*$0.confidence}.reduce(0,+)/Double(events.count)*33.3)) } }
