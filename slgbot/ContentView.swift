//
//  ContentView.swift
//  slgbot
//
//  Created by 김용덕 on 3/2/26.
//

import SwiftUI

struct LineImpedance: Identifiable {
    let id = UUID()
    let type: String     // 선종 코드 (ex: "AL", "AS", ...)
    let ln: String       // 전압선명 (ex: "AL-ACSR전선")
    let ls: String       // 전압선 규격 (ex: "160")
    let nn: String       // 중성선명 (ex: "AL-ACSR전선")
    let ns: String       // 중성선 규격 (ex: "95")
    let rs1: Double      // 정상/역상 저항 (p.u./km, 100MVA 22.9kV 기준)
    let xs1: Double      // 정상/역상 리액턴스 (p.u./km)
    let rs0: Double      // 영상 저항 (p.u./km)
    let xs0: Double      // 영상 리액턴스 (p.u./km)
}

struct LineInput: Identifiable {
    let id = UUID()
    var lineName: String       // 전압선명
    var lineSize: String       // 전압선 규격
    var neutralIndex: Int      // 중성선 선택 인덱스 (-1 = 미선택)
    var distanceText: String
    var distance: Double { Double(distanceText) ?? 0 }
}

struct ContentView: View {
    // 임피던스 데이터 (p.u./km, 100MVA 22.9kV 기준) - HTML DB와 동일
    let lineImpedanceDB: [LineImpedance] = [
        // AL-ACSR전선
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"160",nn:"AL-ACSR전선",ns:"95",rs1:0.022968,xs1:0.071391,rs0:0.078974,xs0:0.222305),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"240",nn:"AL-ACSR전선",ns:"95",rs1:0.022968,xs1:0.071391,rs0:0.078974,xs0:0.222305),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"32",nn:"AL-ACSR전선",ns:"32",rs1:0.171452,xs1:0.086911,rs0:0.264,xs0:0.285673),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"58",nn:"AL-ACSR전선",ns:"32",rs1:0.094807,xs1:0.082637,rs0:0.187354,xs0:0.2814),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"58",nn:"AL-ACSR전선",ns:"58",rs1:0.094806,xs1:0.082634,rs0:0.16962,xs0:0.249429),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"95",nn:"AL-ACSR전선",ns:"58",rs1:0.057448,xs1:0.07902,rs0:0.132239,xs0:0.245888),
        LineImpedance(type:"AL",ln:"AL-ACSR전선",ls:"95",nn:"AL-ACSR전선",ns:"95",rs1:0.057446,xs1:0.079019,rs0:0.113451,xs0:0.229933),
        // AS-AISC 특고압 가공 단심 케이블
        LineImpedance(type:"AS",ln:"AS-AISC 특고압 가공 단심 케이블",ls:"150",nn:"AS-AISC 특고압 가공 단심 케이블",ns:"150",rs1:0.06199347838523294,xs1:0.028603573539787576,rs0:0.09450620697545814,xs0:0.01510268682900784),
        LineImpedance(type:"AS",ln:"AS-AISC 특고압 가공 단심 케이블",ls:"50",nn:"AS-AISC 특고압 가공 단심 케이블",ns:"50",rs1:0.16462310024599073,xs1:0.03184531187429683,rs0:0.47582998035887947,xs0:0.01891649663431285),
        LineImpedance(type:"AS",ln:"AS-AISC 특고압 가공 단심 케이블",ls:"95",nn:"AS-AISC 특고압 가공 단심 케이블",ns:"95",rs1:0.08743158978661736,xs1:0.02974771648137908,rs0:0.13544745523540742,xs0:0.01718121317289907),
        // AT-AITC 특고압 가공 3심 케이블
        LineImpedance(type:"AT",ln:"AT-AITC 특고압 가공 3심 케이블",ls:"150",nn:"AT-AITC 특고압 가공 3심 케이블",ns:"150",rs1:0.02484697088156214,xs1:0.024217692263686814,rs0:0.07360652924238669,xs0:0.04528899143799699),
        LineImpedance(type:"AT",ln:"AT-AITC 특고압 가공 3심 케이블",ls:"240",nn:"AT-AITC 특고압 가공 3심 케이블",ns:"240",rs1:0.04155145782879808,xs1:0.02326423981236056,rs0:0.08861387082626191,xs0:0.04090311016189623),
        LineImpedance(type:"AT",ln:"AT-AITC 특고압 가공 3심 케이블",ls:"50",nn:"AT-AITC 특고압 가공 3심 케이블",ns:"50",rs1:0.16706393852138596,xs1:0.027840811578726568,rs0:0.244350794225892,xs0:0.05673042085391202),
        LineImpedance(type:"AT",ln:"AT-AITC 특고압 가공 3심 케이블",ls:"95",nn:"AT-AITC 특고압 가공 3심 케이블",ns:"95",rs1:0.087927385061307,xs1:0.02650597814686982,rs0:0.14496291069964343,xs0:0.05154363951869721),
        // AW-특고압ACSR/AW
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"160",nn:"AL-ACSR전선",ns:"95",rs1:0.022968,xs1:0.071391,rs0:0.078974,xs0:0.222305),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"240",nn:"AL-ACSR전선",ns:"95",rs1:0.022968,xs1:0.071391,rs0:0.078974,xs0:0.222305),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"32",nn:"AL-ACSR전선",ns:"32",rs1:0.171452,xs1:0.086911,rs0:0.264,xs0:0.285673),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"58",nn:"AL-ACSR전선",ns:"32",rs1:0.094807,xs1:0.082637,rs0:0.187354,xs0:0.2814),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"58",nn:"AL-ACSR전선",ns:"58",rs1:0.094806,xs1:0.082634,rs0:0.16962,xs0:0.249429),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"95",nn:"AL-ACSR전선",ns:"58",rs1:0.057448,xs1:0.07902,rs0:0.132239,xs0:0.245888),
        LineImpedance(type:"AW",ln:"AW-특고압ACSR/AW",ls:"95",nn:"AL-ACSR전선",ns:"95",rs1:0.057446,xs1:0.079019,rs0:0.113451,xs0:0.229933),
        // CA-22.9kV TR CNCE-W/AL
        LineImpedance(type:"CA",ln:"CA-22.9kV TR CNCE-W/AL",ls:"240",nn:"CA-22.9kV TR CNCE-W/AL",ns:"240",rs1:0.03081558322686448,xs1:0.02543811140138441,rs0:0.006445338570965465,xs0:0.028679849735893673),
        LineImpedance(type:"CA",ln:"CA-22.9kV TR CNCE-W/AL",ls:"400",nn:"CA-22.9kV TR CNCE-W/AL",ns:"400",rs1:0.019431360958029025,xs1:0.019431360958029025,rs0:0.003337083579641884,xs0:0.020670849144753154),
        LineImpedance(type:"CA",ln:"CA-22.9kV TR CNCE-W/AL",ls:"95",nn:"CA-22.9kV TR CNCE-W/AL",ns:"95",rs1:0.07831658435193837,xs1:0.02890867832421198,rs0:0.023493068400678863,xs0:0.05278312770542134),
        // CB-22.9kV FR CNCO-W/AL
        LineImpedance(type:"CB",ln:"CB-22.9kV FR CNCO-W/AL",ls:"240",nn:"CB-22.9kV FR CNCO-W/AL",ns:"240",rs1:0.030720237981731855,xs1:0.022310787361034308,rs0:0.05669228275585897,xs0:0.01090749604317233),
        LineImpedance(type:"CB",ln:"CB-22.9kV FR CNCO-W/AL",ls:"400",nn:"CB-22.9kV FR CNCO-W/AL",ns:"400",rs1:0.019355084761922925,xs1:0.020594572948647050,rs0:0.044926679506493015,xs0:0.010850288896092752),
        LineImpedance(type:"CB",ln:"CB-22.9kV FR CNCO-W/AL",ls:"95",nn:"CB-22.9kV FR CNCO-W/AL",ns:"95",rs1:0.0777254438321161,xs1:0.024866039930588660,rs0:0.101618962262352,xs0:0.01090749604317233),
        // CE-TR CNCE-W
        LineImpedance(type:"CE",ln:"CE-TR CNCE-W",ls:"200",nn:"CE-TR CNCE-W",ns:"200",rs1:0.024637211342270366,xs1:0.02658225434297592,rs0:0.08689765641387465,xs0:0.024599073244217315),
        LineImpedance(type:"CE",ln:"CE-TR CNCE-W",ls:"325",nn:"CE-TR CNCE-W",ns:"325",rs1:0.017848629888827445,xs1:0.024618142293243840,rs0:0.05440399687267597,xs0:0.016952384584580769),
        LineImpedance(type:"CE",ln:"CE-TR CNCE-W",ls:"60",nn:"CE-TR CNCE-W",ns:"60",rs1:0.074903224576190395,xs1:0.03167369043305811,rs0:0.24631490627562407,xs0:0.09868232871226711),
        LineImpedance(type:"CE",ln:"CE-TR CNCE-W",ls:"600",nn:"CE-TR CNCE-W",ns:"600",rs1:0.013596231955912360,xs1:0.020842470585991877,rs0:0.0301481665109361,xs0:0.012738124749718733),
        // CF-특고압케이블 FR CNCO-W
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"100",nn:"CF-특고압케이블 FR CNCO-W",ns:"100",rs1:0.043896,xs1:0.00865,rs0:0.138822,xs0:0.038004),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"150",nn:"CF-특고압케이블 FR CNCO-W",ns:"150",rs1:0.029128,xs1:0.02653,rs0:0.096775,xs0:0.025666),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"200",nn:"CF-특고압케이블 FR CNCO-W",ns:"200",rs1:0.022767,xs1:0.025823,rs0:0.074178,xs0:0.020651),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"250",nn:"CF-특고압케이블 FR CNCO-W",ns:"250",rs1:0.018242,xs1:0.024887,rs0:0.058122,xs0:0.018134),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"325",nn:"CF-특고압케이블 FR CNCO-W",ns:"325",rs1:0.014325,xs1:0.023741,rs0:0.044678,xs0:0.015617),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"400",nn:"CF-특고압케이블 FR CNCO-W",ns:"400",rs1:0.014301,xs1:0.02341,rs0:0.053222,xs0:0.017353),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"60",nn:"CF-특고압케이블 FR CNCO-W",ns:"60",rs1:0.073879,xs1:0.03112,rs0:0.216242,xs0:0.067733),
        LineImpedance(type:"CF",ln:"CF-특고압케이블 FR CNCO-W",ls:"600",nn:"CF-특고압케이블 FR CNCO-W",ns:"600",rs1:0.014035,xs1:0.024351,rs0:0.029481,xs0:0.012757),
        // CN-특고압케이블CNCV
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"100",nn:"CN-특고압케이블CNCV",ns:"100",rs1:0.043896,xs1:0.00865,rs0:0.138822,xs0:0.038004),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"150",nn:"CN-특고압케이블CNCV",ns:"150",rs1:0.029128,xs1:0.02653,rs0:0.096775,xs0:0.025666),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"200",nn:"CN-특고압케이블CNCV",ns:"200",rs1:0.022767,xs1:0.025823,rs0:0.074178,xs0:0.020651),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"250",nn:"CN-특고압케이블CNCV",ns:"250",rs1:0.018242,xs1:0.024887,rs0:0.058122,xs0:0.018134),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"325",nn:"CN-특고압케이블CNCV",ns:"325",rs1:0.014325,xs1:0.023741,rs0:0.044678,xs0:0.015617),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"400",nn:"CN-특고압케이블CNCV",ns:"400",rs1:0.014301,xs1:0.02341,rs0:0.053222,xs0:0.017353),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"60",nn:"CN-특고압케이블CNCV",ns:"60",rs1:0.073879,xs1:0.03112,rs0:0.216242,xs0:0.067733),
        LineImpedance(type:"CN",ln:"CN-특고압케이블CNCV",ls:"600",nn:"CN-특고압케이블CNCV",ns:"600",rs1:0.014035,xs1:0.024351,rs0:0.029481,xs0:0.012757),
        // CT-특고압케이블TR CNCV-W
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"100",nn:"CT-특고압케이블TR CNCV-W",ns:"100",rs1:0.043896,xs1:0.00865,rs0:0.138822,xs0:0.038004),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"150",nn:"CT-특고압케이블TR CNCV-W",ns:"150",rs1:0.029128,xs1:0.02653,rs0:0.096775,xs0:0.025666),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"200",nn:"CT-특고압케이블TR CNCV-W",ns:"200",rs1:0.022767,xs1:0.025823,rs0:0.074178,xs0:0.020651),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"250",nn:"CT-특고압케이블TR CNCV-W",ns:"250",rs1:0.018242,xs1:0.024887,rs0:0.058122,xs0:0.018134),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"325",nn:"CT-특고압케이블TR CNCV-W",ns:"325",rs1:0.014325,xs1:0.023741,rs0:0.044678,xs0:0.015617),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"400",nn:"CT-특고압케이블TR CNCV-W",ns:"400",rs1:0.014301,xs1:0.02341,rs0:0.053222,xs0:0.017353),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"60",nn:"CT-특고압케이블TR CNCV-W",ns:"60",rs1:0.073879,xs1:0.03112,rs0:0.216242,xs0:0.067733),
        LineImpedance(type:"CT",ln:"CT-특고압케이블TR CNCV-W",ls:"600",nn:"CT-특고압케이블TR CNCV-W",ns:"600",rs1:0.014035,xs1:0.024351,rs0:0.029481,xs0:0.012757),
        // CW-특고압케이블CNCV-W
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"100",nn:"CW-특고압케이블CNCV-W",ns:"100",rs1:0.043896,xs1:0.00865,rs0:0.138822,xs0:0.038004),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"150",nn:"CW-특고압케이블CNCV-W",ns:"150",rs1:0.029128,xs1:0.02653,rs0:0.096775,xs0:0.025666),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"200",nn:"CW-특고압케이블CNCV-W",ns:"200",rs1:0.022767,xs1:0.025823,rs0:0.074178,xs0:0.020651),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"250",nn:"CW-특고압케이블CNCV-W",ns:"250",rs1:0.018242,xs1:0.024887,rs0:0.058122,xs0:0.018134),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"325",nn:"CW-특고압케이블CNCV-W",ns:"325",rs1:0.014325,xs1:0.023741,rs0:0.044678,xs0:0.015617),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"400",nn:"CW-특고압케이블CNCV-W",ns:"400",rs1:0.014301,xs1:0.02341,rs0:0.053222,xs0:0.017353),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"60",nn:"CW-특고압케이블CNCV-W",ns:"60",rs1:0.073879,xs1:0.03112,rs0:0.216242,xs0:0.067733),
        LineImpedance(type:"CW",ln:"CW-특고압케이블CNCV-W",ls:"600",nn:"CW-특고압케이블CNCV-W",ns:"600",rs1:0.014035,xs1:0.024351,rs0:0.029481,xs0:0.012757),
        // EC-특고압ACSR-OC
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"160",nn:"AL-ACSR전선",ns:"95",rs1:0.03557,xs1:0.077498,rs0:0.091575,xs0:0.228411),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"160",nn:"WO-WO전선",ns:"60",rs1:0.034999,xs1:0.077498,rs0:0.089524,xs0:0.231611),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"240",nn:"WO-WO전선",ns:"60",rs1:0.023604,xs1:0.074538,rs0:0.078129,xs0:0.228651),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"32",nn:"AL-ACSR전선",ns:"32",rs1:0.176981,xs1:0.087964,rs0:0.269528,xs0:0.286726),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"32",nn:"WO-WO전선",ns:"22",rs1:0.167256,xs1:0.087964,rs0:0.255962,xs0:0.281705),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"58",nn:"AL-ACSR전선",ns:"32",rs1:0.097664,xs1:0.083686,rs0:0.190211,xs0:0.282449),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"58",nn:"AL-ACSR전선",ns:"58",rs1:0.097663,xs1:0.083683,rs0:0.172478,xs0:0.250478),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"58",nn:"WO-WO전선",ns:"38",rs1:0.092325,xs1:0.083683,rs0:0.164131,xs0:0.251626),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"95",nn:"AL-ACSR전선",ns:"58",rs1:0.059739,xs1:0.080851,rs0:0.134531,xs0:0.247718),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"95",nn:"AL-ACSR전선",ns:"95",rs1:0.059738,xs1:0.08085,rs0:0.115743,xs0:0.231763),
        LineImpedance(type:"EC",ln:"EC-특고압ACSR-OC",ls:"95",nn:"WO-WO전선",ns:"60",rs1:0.057642,xs1:0.08085,rs0:0.112167,xs0:0.234963),
        // EH-특고압수밀형 OC-W
        LineImpedance(type:"EH",ln:"EH-특고압수밀형 OC-W",ls:"100",nn:"WO-WO전선",ns:"60",rs1:0.035406,xs1:0.080206,rs0:0.096234,xs0:0.198883),
        LineImpedance(type:"EH",ln:"EH-특고압수밀형 OC-W",ls:"150",nn:"WO-WO전선",ns:"60",rs1:0.023077,xs1:0.077212,rs0:0.083904,xs0:0.195889),
        LineImpedance(type:"EH",ln:"EH-특고압수밀형 OC-W",ls:"38",nn:"WO-WO전선",ns:"38",rs1:0.095779,xs1:0.087555,rs0:0.169674,xs0:0.21151),
        LineImpedance(type:"EH",ln:"EH-특고압수밀형 OC-W",ls:"60",nn:"WO-WO전선",ns:"38",rs1:0.059766,xs1:0.083983,rs0:0.13386,xs0:0.209016),
        LineImpedance(type:"EH",ln:"EH-특고압수밀형 OC-W",ls:"60",nn:"WO-WO전선",ns:"60",rs1:0.059765,xs1:0.083982,rs0:0.120592,xs0:0.202658),
        // EW-특고압ACSR/AW-OC
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"160",nn:"AL-ACSR전선",ns:"95",rs1:0.034999,xs1:0.077498,rs0:0.091004,xs0:0.228411),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"160",nn:"WO-WO전선",ns:"60",rs1:0.034999,xs1:0.077498,rs0:0.089524,xs0:0.231611),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"240",nn:"AL-ACSR전선",ns:"95",rs1:0.023604,xs1:0.074538,rs0:0.079609,xs0:0.225451),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"240",nn:"WO-WO전선",ns:"60",rs1:0.023604,xs1:0.074538,rs0:0.078129,xs0:0.228651),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"32",nn:"AL-ACSR전선",ns:"32",rs1:0.167256,xs1:0.087964,rs0:0.259802,xs0:0.286726),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"32",nn:"WO-WO전선",ns:"22",rs1:0.167256,xs1:0.087964,rs0:0.255962,xs0:0.281705),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"58",nn:"AL-ACSR전선",ns:"32",rs1:0.092332,xs1:0.08368,rs0:0.187806,xs0:0.278164),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"58",nn:"AL-ACSR전선",ns:"58",rs1:0.092325,xs1:0.083683,rs0:0.16714,xs0:0.250478),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"58",nn:"WO-WO전선",ns:"38",rs1:0.092325,xs1:0.083683,rs0:0.164131,xs0:0.251626),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"95",nn:"AL-ACSR전선",ns:"58",rs1:0.057643,xs1:0.080851,rs0:0.132435,xs0:0.247718),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"95",nn:"AL-ACSR전선",ns:"95",rs1:0.057642,xs1:0.08085,rs0:0.113647,xs0:0.231763),
        LineImpedance(type:"EW",ln:"EW-특고압ACSR/AW-OC",ls:"95",nn:"WO-WO전선",ns:"60",rs1:0.057642,xs1:0.08085,rs0:0.112167,xs0:0.234963),
        // OW-OW전선
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"100",nn:"WO-WO전선",ns:"60",rs1:0.0337,xs1:0.0769,rs0:0.1215,xs0:0.2978),
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"22",nn:"WO-WO전선",ns:"22",rs1:0.156,xs1:0.0887,rs0:0.2342,xs0:0.3402),
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"38",nn:"WO-WO전선",ns:"22",rs1:0.0922,xs1:0.0849,rs0:0.1704,xs0:0.336),
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"38",nn:"WO-WO전선",ns:"38",rs1:0.0922,xs1:0.0849,rs0:0.1585,xs0:0.3205),
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"60",nn:"WO-WO전선",ns:"38",rs1:0.0922,xs1:0.0807,rs0:0.1427,xs0:0.3163),
        LineImpedance(type:"OW",ln:"OW-OW전선",ls:"60",nn:"WO-WO전선",ns:"60",rs1:0.0573,xs1:0.0807,rs0:0.1354,xs0:0.3016),
        // TW-ACSR/AW-TR/OC
        LineImpedance(type:"TW",ln:"TW-ACSR/AW-TR/OC",ls:"160",nn:"TW-ACSR/AW-TR/OC",ns:"160",rs1:0.08947,xs1:0.07756,rs0:0.36495,xs0:0.35642),
        LineImpedance(type:"TW",ln:"TW-ACSR/AW-TR/OC",ls:"240",nn:"TW-ACSR/AW-TR/OC",ns:"240",rs1:0.08046,xs1:0.07461,rs0:0.35922,xs0:0.35347),
        LineImpedance(type:"TW",ln:"TW-ACSR/AW-TR/OC",ls:"58",nn:"TW-ACSR/AW-TR/OC",ns:"58",rs1:0.14463,xs1:0.08419,rs0:0.39333,xs0:0.36305),
        LineImpedance(type:"TW",ln:"TW-ACSR/AW-TR/OC",ls:"95",nn:"TW-ACSR/AW-TR/OC",ns:"95",rs1:0.10943,xs1:0.08114,rs0:0.37566,xs0:0.36),
        // WL-AL피복저손실ACSR/AW/L
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"160",nn:"AL-ACSR전선",ns:"95",rs1:0.0347,xs1:0.0707,rs0:0.1199,xs0:0.2926),
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"32",nn:"AL-ACSR전선",ns:"32",rs1:0.172,xs1:0.0881,rs0:0.2472,xs0:0.3512),
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"58",nn:"AL-ACSR전선",ns:"32",rs1:0.0948,xs1:0.0838,rs0:0.1702,xs0:0.3474),
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"58",nn:"AL-ACSR전선",ns:"58",rs1:0.0948,xs1:0.0838,rs0:0.1585,xs0:0.3312),
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"95",nn:"AL-ACSR전선",ns:"58",rs1:0.058,xs1:0.0803,rs0:0.1402,xs0:0.3236),
        LineImpedance(type:"WL",ln:"WL-AL피복저손실ACSR/AW/L",ls:"95",nn:"AL-ACSR전선",ns:"95",rs1:0.058,xs1:0.0803,rs0:0.135,xs0:0.3085),
        // WO-WO전선
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"100",nn:"WO-WO전선",ns:"60",rs1:0.033886,xs1:0.080317,rs0:0.094714,xs0:0.198993),
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"22",nn:"WO-WO전선",ns:"22",rs1:0.156021,xs1:0.09133,rs0:0.24425,xs0:0.229355),
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"38",nn:"WO-WO전선",ns:"22",rs1:0.09235,xs1:0.087557,rs0:0.180579,xs0:0.225581),
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"38",nn:"WO-WO전선",ns:"38",rs1:0.092349,xs1:0.087556,rs0:0.166508,xs0:0.212393),
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"60",nn:"WO-WO전선",ns:"38",rs1:0.057481,xs1:0.083983,rs0:0.131575,xs0:0.209016),
        LineImpedance(type:"WO",ln:"WO-WO전선",ls:"60",nn:"WO-WO전선",ns:"60",rs1:0.05748,xs1:0.083982,rs0:0.118307,xs0:0.202658),
    ]
    
    // 전압선명 리스트 (unique)
    var lineNames: [String] {
        Array(Set(lineImpedanceDB.map { $0.ln })).sorted()
    }
    
    // 전압선명별 전압선 규격 리스트 (unique)
    func lineSizes(for ln: String) -> [String] {
        let items = lineImpedanceDB.filter { $0.ln == ln }.map { $0.ls }
        return Array(Set(items)).sorted { (Int($0) ?? 0) < (Int($1) ?? 0) }
    }
    
    // 전압선명+규격 → 가능한 중성선 옵션 목록
    func neutralOptions(ln: String, ls: String) -> [LineImpedance] {
        lineImpedanceDB.filter { $0.ln == ln && $0.ls == ls }
    }

    @State private var busImpedanceRS1: String = ""
    @State private var busImpedanceXS1: String = ""
    @State private var busImpedanceRS0: String = ""
    @State private var busImpedanceXS0: String = ""

    @State private var lines: [LineInput] = [LineInput(lineName: "", lineSize: "", neutralIndex: -1, distanceText: "")]
    
    @State private var showDBSheet = false
    @FocusState private var isTextFieldFocused: Bool

    // 기준값 (100MVA, 22.9kV)
    let baseMVA: Double = 100.0
    let baseKV: Double = 22.9
    var baseCurrentA: Double { baseMVA * 1_000_000 / (sqrt(3.0) * baseKV * 1_000) }
    
    @State private var resultSLG: String = ""
    @State private var calcDetail: String = ""
    @State private var showCalcDetail = false
    
    // 티피컬 모선 임피던스 적용
    func applyTypicalBusImpedance() {
        busImpedanceRS1 = "0.00021"
        busImpedanceXS1 = "0.34817"
        busImpedanceRS0 = "0"
        busImpedanceXS0 = "0.49724"
    }
    
    // 1선지락전류 계산
    func calculateSLG() {
        guard let brs1 = Double(busImpedanceRS1),
              let bxs1 = Double(busImpedanceXS1),
              let brs0 = Double(busImpedanceRS0),
              let bxs0 = Double(busImpedanceXS0) else {
            resultSLG = "모선 임피던스를 입력하세요"
            calcDetail = ""
            return
        }
        
        var detail = "=== 1선지락전류 계산과정 ===\n\n"
        detail += "■ 기준값\n"
        detail += "  기준용량: \(Int(baseMVA)) MVA\n"
        detail += "  기준전압: \(String(format: "%.1f", baseKV)) kV\n"
        detail += String(format: "  기준전류 Ibase = %.1f A\n", baseCurrentA)
        detail += String(format: "  (= %gMVA / (√3 × %.1fkV))\n\n", baseMVA, baseKV)
        
        detail += "■ 모선 임피던스 (p.u.)\n"
        detail += String(format: "  Z1_bus = %.5f + j%.5f\n", brs1, bxs1)
        detail += String(format: "  Z0_bus = %.5f + j%.5f\n\n", brs0, bxs0)
        
        // 선로 임피던스 합산
        var sumRS1 = 0.0, sumXS1 = 0.0, sumRS0 = 0.0, sumXS0 = 0.0
        detail += "■ 선로 임피던스 (p.u./km × km)\n"
        var idx = 0
        for line in lines {
            let opts = neutralOptions(ln: line.lineName, ls: line.lineSize)
            guard line.neutralIndex >= 0, line.neutralIndex < opts.count else { continue }
            let rec = opts[line.neutralIndex]
            idx += 1
            let lr1 = rec.rs1 * line.distance
            let lx1 = rec.xs1 * line.distance
            let lr0 = rec.rs0 * line.distance
            let lx0 = rec.xs0 * line.distance
            sumRS1 += lr1; sumXS1 += lx1; sumRS0 += lr0; sumXS0 += lx0
            detail += "  [\(idx)] \(line.lineName) \(line.lineSize)mm²\n"
            detail += "      중성선: \(rec.nn) \(rec.ns)mm² × \(String(format: "%.3f", line.distance))km\n"
            detail += String(format: "      Z1 = %.5f + j%.5f\n", lr1, lx1)
            detail += String(format: "      Z0 = %.5f + j%.5f\n", lr0, lx0)
        }
        detail += String(format: "\n  선로합계 Z1 = %.5f + j%.5f\n", sumRS1, sumXS1)
        detail += String(format: "  선로합계 Z0 = %.5f + j%.5f\n\n", sumRS0, sumXS0)
        
        // 총 임피던스
        let totalR1 = brs1 + sumRS1
        let totalX1 = bxs1 + sumXS1
        let totalR0 = brs0 + sumRS0
        let totalX0 = bxs0 + sumXS0
        
        detail += "■ 총 임피던스 (p.u.)\n"
        detail += String(format: "  Z1_total = %.5f + j%.5f\n", totalR1, totalX1)
        detail += String(format: "  Z0_total = %.5f + j%.5f\n\n", totalR0, totalX0)
        
        // 2Z1 + Z0
        let zR = 2.0 * totalR1 + totalR0
        let zX = 2.0 * totalX1 + totalX0
        let zMag = sqrt(zR * zR + zX * zX)
        
        detail += "■ 합성 임피던스\n"
        detail += String(format: "  2Z1 + Z0 = %.5f + j%.5f\n", zR, zX)
        detail += String(format: "  |2Z1 + Z0| = %.5f p.u.\n\n", zMag)
        
        guard zMag > 0 else {
            resultSLG = "임피던스 값 오류"
            calcDetail = detail
            return
        }
        
        // SLG 전류
        let slgCurrent = 3.0 * baseCurrentA / zMag
        detail += "■ 1선지락전류 (SLG)\n"
        detail += String(format: "  Islg = 3 × Ibase / |2Z1 + Z0|\n")
        detail += String(format: "       = 3 × %.1f / %.5f\n", baseCurrentA, zMag)
        detail += String(format: "       = %.1f A\n", slgCurrent)
        
        resultSLG = String(format: "%.1f A", slgCurrent)
        calcDetail = detail
    }
    
    var body: some View {
        Form {
            // 기준 정보
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1선지락전류 계산")
                        .font(.title2).bold()
                    Text("기준: \(Int(baseMVA))MVA, \(String(format: "%.1f", baseKV))kV / Ibase = \(String(format: "%.1f", baseCurrentA)) A")
                        .font(.caption).foregroundColor(.secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("• 정상임피던스 = 역상임피던스 (Z1 = Z2)")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            
            // 모선 임피던스 입력
            Section(header:
                HStack {
                    Text("모선 임피던스 (p.u.)")
                    Spacer()
                    Button("Typical") {
                        applyTypicalBusImpedance()
                    }
                    .font(.caption)
                    .textCase(nil)
                }
            ) {
                HStack {
                    Text("정상").font(.caption).frame(width: 30)
                    TextField("RS1", text: $busImpedanceRS1)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                    TextField("XS1", text: $busImpedanceXS1)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                }
                HStack {
                    Text("영상").font(.caption).frame(width: 30)
                    TextField("RS0", text: $busImpedanceRS0)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                    TextField("XS0", text: $busImpedanceXS0)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                }
            }
            
            // 선로 정보
            Section(header:
                HStack {
                    Text("선로 정보 (최대 10개)")
                    Spacer()
                    Button("DB 보기") {
                        showDBSheet = true
                    }
                    .font(.caption)
                    .textCase(nil)
                }
            ) {
                ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                    VStack(alignment: .leading, spacing: 6) {
                        // 전압선 행
                        HStack(spacing: 4) {
                            Text("\(index + 1).")
                                .font(.caption).foregroundColor(.secondary)
                                .frame(width: 20, alignment: .trailing)
                            Picker("", selection: $lines[index].lineName) {
                                Text("전압선 선택").tag("")
                                ForEach(lineNames, id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .onChange(of: lines[index].lineName) {
                                lines[index].lineSize = ""
                                lines[index].neutralIndex = -1
                            }
                            Picker("", selection: $lines[index].lineSize) {
                                Text("규격").tag("")
                                ForEach(lineSizes(for: lines[index].lineName), id: \.self) { sz in
                                    Text(sz + "mm²").tag(sz)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 90)
                            .disabled(lines[index].lineName.isEmpty)
                            .onChange(of: lines[index].lineSize) {
                                let opts = neutralOptions(ln: lines[index].lineName, ls: lines[index].lineSize)
                                lines[index].neutralIndex = opts.count == 1 ? 0 : -1
                            }
                            if lines.count > 1 {
                                Button(action: { lines.remove(at: index) }) {
                                    Image(systemName: "minus.circle").foregroundColor(.red).font(.caption)
                                }
                                .buttonStyle(.borderless)
                                .frame(width: 24)
                            }
                        }
                        // 중성선 + 거리 행
                        HStack(spacing: 4) {
                            Text("").frame(width: 20)
                            Text("중성선").font(.caption2).foregroundColor(.secondary).frame(width: 36)
                            let opts = neutralOptions(ln: lines[index].lineName, ls: lines[index].lineSize)
                            Picker("", selection: $lines[index].neutralIndex) {
                                Text("선택").tag(-1)
                                ForEach(Array(opts.enumerated()), id: \.offset) { i, opt in
                                    Text("\(opt.nn.components(separatedBy: "-").first ?? opt.nn) \(opt.ns)mm²").tag(i)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .disabled(opts.isEmpty)
                            TextField("km", text: $lines[index].distanceText)
                                .keyboardType(.decimalPad)
                                .focused($isTextFieldFocused)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.vertical, 2)
                    if index < lines.count - 1 {
                        Divider()
                    }
                }
                
                Button(action: {
                    if lines.count < 10 {
                        lines.append(LineInput(lineName: "", lineSize: "", neutralIndex: -1, distanceText: ""))
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("선로 추가")
                    }
                }.disabled(lines.count >= 10)
            }
            
            // 계산 + 결과
            Section {
                Button(action: calculateSLG) {
                    Text("1선지락전류 계산")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                
                if !resultSLG.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1선지락전류 (SLG)").font(.headline)
                        Text(resultSLG)
                            .font(.title)
                            .bold()
                            .foregroundColor(.blue)
                        if !calcDetail.isEmpty {
                            Button("계산과정 보기") {
                                showCalcDetail = true
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    isTextFieldFocused = false
                }
            }
        }
        .sheet(isPresented: $showCalcDetail) {
            NavigationStack {
                ScrollView {
                    Text(calcDetail)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("계산과정")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("닫기") { showCalcDetail = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showDBSheet) {
            NavigationStack {
                List {
                    ForEach(lineNames, id: \.self) { name in
                        Section(header: Text(name)) {
                            HStack {
                                Text("전압선").bold().frame(width: 30, alignment: .leading)
                                Text("중성선").bold().frame(width: 50, alignment: .leading)
                                Text("RS1").bold().frame(maxWidth: .infinity, alignment: .trailing)
                                Text("XS1").bold().frame(maxWidth: .infinity, alignment: .trailing)
                                Text("RS0").bold().frame(maxWidth: .infinity, alignment: .trailing)
                                Text("XS0").bold().frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .font(.caption2)
                            ForEach(lineImpedanceDB.filter { $0.ln == name }) { db in
                                HStack {
                                    Text(db.ls).frame(width: 30, alignment: .leading)
                                    Text("\(db.nn.components(separatedBy: "-").first ?? "") \(db.ns)").frame(width: 50, alignment: .leading)
                                    Text(String(format: "%.4f", db.rs1)).frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(String(format: "%.4f", db.xs1)).frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(String(format: "%.4f", db.rs0)).frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(String(format: "%.4f", db.xs0)).frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .font(.caption2)
                            }
                        }
                    }
                }
                .navigationTitle("임피던스 DB (p.u./km)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("닫기") { showDBSheet = false }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
