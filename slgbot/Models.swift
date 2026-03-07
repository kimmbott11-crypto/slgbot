import Foundation

// MARK: - 임피던스 DB 레코드 (p.u./km, 100MVA 22.9kV 기준)
struct LineImpedance: Identifiable {
    let id = UUID()
    let type: String     // 선종 코드 (ex: "AL", "AS", ...)
    let ln: String       // 전압선명 (ex: "AL-ACSR전선")
    let ls: String       // 전압선 규격 (ex: "160")
    let nn: String       // 중성선명 (ex: "AL-ACSR전선")
    let ns: String       // 중성선 규격 (ex: "95")
    let rs1: Double      // 정상/역상 저항 (p.u./km)
    let xs1: Double      // 정상/역상 리액턴스 (p.u./km)
    let rs0: Double      // 영상 저항 (p.u./km)
    let xs0: Double      // 영상 리액턴스 (p.u./km)
}

// MARK: - 선로 입력 행
struct LineInput: Identifiable {
    let id = UUID()
    var lineName: String       // 전압선명
    var lineSize: String       // 전압선 규격
    var neutralIndex: Int      // 중성선 선택 인덱스 (-1 = 미선택)
    var distanceText: String
    var distance: Double { Double(distanceText) ?? 0 }
}
