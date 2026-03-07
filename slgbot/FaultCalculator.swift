import Foundation

// MARK: - 고장계산 엔진 (UI 의존성 없음)
// 계산식 변경 시 이 파일만 수정하면 됩니다.
struct FaultCalculator {
    // 기준값 (100MVA, 22.9kV)
    let baseMVA: Double = 100.0
    let baseKV: Double = 22.9
    var baseCurrentA: Double { baseMVA * 1_000_000 / (sqrt(3.0) * baseKV * 1_000) }

    // MARK: - 계산 결과
    struct Result {
        var slgCurrent: String = ""
        var threePhCurrent: String = ""
        var detailSLG: String = ""
        var detail3P: String = ""
    }

    // MARK: - 메인 계산 함수
    /// - Parameters:
    ///   - busRS1, busXS1: 정상 모선 임피던스 (p.u.)
    ///   - busRS0, busXS0: 영상 모선 임피던스 (p.u.)
    ///   - lines: 선로 입력 목록
    func calculate(busRS1: Double, busXS1: Double,
                   busRS0: Double, busXS0: Double,
                   lines: [LineInput]) -> Result {
        var result = Result()

        let baseInfo = "■ 기준값\n  기준용량: \(Int(baseMVA)) MVA\n  기준전압: \(String(format: "%.1f", baseKV)) kV\n" +
            String(format: "  기준전류 Ibase = %.1f A\n", baseCurrentA) +
            String(format: "  (= %gMVA / (√3 × %.1fkV))\n\n", baseMVA, baseKV)

        var dSlg = "=== 1선지락전류 계산과정 ===\n\n" + baseInfo
        var d3P  = "=== 3상단락전류 계산과정 ===\n\n" + baseInfo

        dSlg += "■ 모선 임피던스 (p.u.)\n"
        dSlg += String(format: "  Z1_bus = %.5f + j%.5f\n", busRS1, busXS1)
        dSlg += String(format: "  Z0_bus = %.5f + j%.5f\n\n", busRS0, busXS0)
        d3P  += "■ 모선 임피던스 (p.u.)\n"
        d3P  += String(format: "  Z1_bus = %.5f + j%.5f\n\n", busRS1, busXS1)

        // 선로 임피던스 합산
        var sumRS1 = 0.0, sumXS1 = 0.0, sumRS0 = 0.0, sumXS0 = 0.0
        dSlg += "■ 선로 임피던스 (p.u./km × km)\n"
        d3P  += "■ 선로 임피던스 (p.u./km × km)\n"
        var idx = 0

        for line in lines {
            let opts = lineImpedanceDB.neutralOptions(ln: line.lineName, ls: line.lineSize)
            guard line.neutralIndex >= 0, line.neutralIndex < opts.count else { continue }
            let rec = opts[line.neutralIndex]
            idx += 1
            let lr1 = rec.rs1 * line.distance
            let lx1 = rec.xs1 * line.distance
            let lr0 = rec.rs0 * line.distance
            let lx0 = rec.xs0 * line.distance
            sumRS1 += lr1; sumXS1 += lx1; sumRS0 += lr0; sumXS0 += lx0

            let desc = "  [\(idx)] \(line.lineName) \(line.lineSize)mm²\n" +
                       "      중성선: \(rec.nn) \(rec.ns)mm² × \(String(format: "%.3f", line.distance))km\n"
            dSlg += desc + String(format: "      Z1 = %.5f + j%.5f\n", lr1, lx1)
                        + String(format: "      Z0 = %.5f + j%.5f\n", lr0, lx0)
            d3P  += desc + String(format: "      Z1 = %.5f + j%.5f\n", lr1, lx1)
        }

        dSlg += String(format: "\n  선로합계 Z1 = %.5f + j%.5f\n", sumRS1, sumXS1)
        dSlg += String(format: "  선로합계 Z0 = %.5f + j%.5f\n\n", sumRS0, sumXS0)
        d3P  += String(format: "\n  선로합계 Z1 = %.5f + j%.5f\n\n", sumRS1, sumXS1)

        // 총 임피던스
        let tR1 = busRS1 + sumRS1, tX1 = busXS1 + sumXS1
        let tR0 = busRS0 + sumRS0, tX0 = busXS0 + sumXS0

        dSlg += "■ 총 임피던스 (p.u.)\n"
        dSlg += String(format: "  Z1_total = %.5f + j%.5f\n", tR1, tX1)
        dSlg += String(format: "  Z0_total = %.5f + j%.5f\n\n", tR0, tX0)
        d3P  += "■ 총 임피던스 (p.u.)\n"
        d3P  += String(format: "  Z1_total = %.5f + j%.5f\n\n", tR1, tX1)

        // 1선지락: Islg = 3 × Ibase / |2Z1 + Z0|
        let zR = 2.0 * tR1 + tR0, zX = 2.0 * tX1 + tX0
        let zMag = sqrt(zR * zR + zX * zX)
        dSlg += "■ 합성 임피던스\n"
        dSlg += String(format: "  2Z1 + Z0 = %.5f + j%.5f\n", zR, zX)
        dSlg += String(format: "  |2Z1 + Z0| = %.5f p.u.\n\n", zMag)

        if zMag > 0 {
            let slg = 3.0 * baseCurrentA / zMag
            dSlg += "■ 1선지락전류 (SLG)\n"
            dSlg += "  Islg = 3 × Ibase / |2Z1 + Z0|\n"
            dSlg += String(format: "       = 3 × %.1f / %.5f\n", baseCurrentA, zMag)
            dSlg += String(format: "       = %.1f A\n", slg)
            result.slgCurrent = String(format: "%.1f A", slg)
        }

        // 3상단락: I3p = Ibase / |Z1|
        let z1Mag = sqrt(tR1 * tR1 + tX1 * tX1)
        d3P += String(format: "■ |Z1_total| = %.5f p.u.\n\n", z1Mag)

        if z1Mag > 0 {
            let p3 = baseCurrentA / z1Mag
            d3P += "■ 3상단락전류\n"
            d3P += "  I3φ = Ibase / |Z1_total|\n"
            d3P += String(format: "      = %.1f / %.5f\n", baseCurrentA, z1Mag)
            d3P += String(format: "      = %.1f A\n", p3)
            result.threePhCurrent = String(format: "%.1f A", p3)
        }

        result.detailSLG = dSlg
        result.detail3P  = d3P
        return result
    }
}
