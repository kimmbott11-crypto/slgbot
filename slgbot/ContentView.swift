//
//  ContentView.swift
//  slgbot
//
//  Created by 김용덕 on 3/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var busImpedanceRS1: String = ""
    @State private var busImpedanceXS1: String = ""
    @State private var busImpedanceRS0: String = ""
    @State private var busImpedanceXS0: String = ""

    @State private var lines: [LineInput] = [LineInput(lineName: "", lineSize: "", neutralIndex: -1, distanceText: "")]

    @State private var showDBSheet = false
    @FocusState private var isTextFieldFocused: Bool

    @State private var calcResult = FaultCalculator.Result()
    @State private var showCalcDetailSLG = false
    @State private var showCalcDetail3P = false

    private let calculator = FaultCalculator()

    // MARK: - DB 헬퍼 (뷰에서 사용)
    var lineNames: [String] { lineImpedanceDB.uniqueLineNames }

    func lineSizes(for ln: String) -> [String] { lineImpedanceDB.sizes(for: ln) }
    func neutralOptions(ln: String, ls: String) -> [LineImpedance] { lineImpedanceDB.neutralOptions(ln: ln, ls: ls) }

    // MARK: - 액션
    func applyTypicalBusImpedance() {
        busImpedanceRS1 = "0.00021"
        busImpedanceXS1 = "0.34817"
        busImpedanceRS0 = "0"
        busImpedanceXS0 = "0.49724"
    }

    func calculate() {
        guard let brs1 = Double(busImpedanceRS1),
              let bxs1 = Double(busImpedanceXS1),
              let brs0 = Double(busImpedanceRS0),
              let bxs0 = Double(busImpedanceXS0) else {
            calcResult = FaultCalculator.Result(slgCurrent: "모선 임피던스를 입력하세요",
                                                threePhCurrent: "모선 임피던스를 입력하세요",
                                                detailSLG: "", detail3P: "")
            return
        }
        calcResult = calculator.calculate(busRS1: brs1, busXS1: bxs1,
                                          busRS0: brs0, busXS0: bxs0,
                                          lines: lines)
    }

    // MARK: - 뷰
    var body: some View {
        Form {
            headerSection
            busImpedanceSection
            lineInfoSection
            resultSection
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") { isTextFieldFocused = false }
            }
        }
        .sheet(isPresented: $showCalcDetailSLG) { detailSheet(title: "1선지락전류 계산과정", text: calcResult.detailSLG, binding: $showCalcDetailSLG) }
        .sheet(isPresented: $showCalcDetail3P)  { detailSheet(title: "3상단락전류 계산과정",  text: calcResult.detail3P,  binding: $showCalcDetail3P) }
        .sheet(isPresented: $showDBSheet) { dbSheet }
    }
}

// MARK: - 섹션 뷰 분리
private extension ContentView {
    var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("고장계산기").font(.title2).bold()
                Text("기준: \(Int(calculator.baseMVA))MVA, \(String(format: "%.1f", calculator.baseKV))kV / Ibase = \(String(format: "%.1f", calculator.baseCurrentA)) A")
                    .font(.caption).foregroundColor(.secondary)
            }
            Text("• 정상임피던스 = 역상임피던스 (Z1 = Z2)")
                .font(.caption2).foregroundColor(.secondary)
        }
    }

    var busImpedanceSection: some View {
        Section(header:
            HStack {
                Text("모선 임피던스 (p.u.)")
                Spacer()
                Button("Typical") { applyTypicalBusImpedance() }
                    .font(.caption).textCase(nil)
            }
        ) {
            HStack {
                Text("정상").font(.caption).frame(width: 30)
                TextField("RS1", text: $busImpedanceRS1).keyboardType(.decimalPad).focused($isTextFieldFocused)
                TextField("XS1", text: $busImpedanceXS1).keyboardType(.decimalPad).focused($isTextFieldFocused)
            }
            HStack {
                Text("영상").font(.caption).frame(width: 30)
                TextField("RS0", text: $busImpedanceRS0).keyboardType(.decimalPad).focused($isTextFieldFocused)
                TextField("XS0", text: $busImpedanceXS0).keyboardType(.decimalPad).focused($isTextFieldFocused)
            }
        }
    }

    var lineInfoSection: some View {
        Section(header:
            HStack {
                Text("선로 정보 (최대 10개)")
                Spacer()
                Button("DB 보기") { showDBSheet = true }
                    .font(.caption).textCase(nil)
            }
        ) {
            ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                lineRow(index: index, line: line)
                if index < lines.count - 1 { Divider() }
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
    }

    var resultSection: some View {
        Section {
            Button(action: calculate) {
                Text("고장계산").frame(maxWidth: .infinity).padding(8)
            }.buttonStyle(.borderedProminent)

            if !calcResult.slgCurrent.isEmpty {
                resultRow(label: "1선지락전류 (SLG)", value: calcResult.slgCurrent, color: .blue) {
                    showCalcDetailSLG = true
                }
            }
            if !calcResult.threePhCurrent.isEmpty {
                resultRow(label: "3상단락전류", value: calcResult.threePhCurrent, color: .red) {
                    showCalcDetail3P = true
                }
            }
        }
    }

    @ViewBuilder
    func lineRow(index: Int, line: LineInput) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("\(index + 1).").font(.caption).foregroundColor(.secondary).frame(width: 20, alignment: .trailing)
                Picker("", selection: $lines[index].lineName) {
                    Text("전압선 선택").tag("")
                    ForEach(lineNames, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden().frame(maxWidth: .infinity)
                .onChange(of: lines[index].lineName) {
                    lines[index].lineSize = ""
                    lines[index].neutralIndex = -1
                }
                Picker("", selection: $lines[index].lineSize) {
                    Text("규격").tag("")
                    ForEach(lineSizes(for: lines[index].lineName), id: \.self) { Text($0 + "mm²").tag($0) }
                }
                .labelsHidden().frame(width: 90)
                .disabled(lines[index].lineName.isEmpty)
                .onChange(of: lines[index].lineSize) {
                    let opts = neutralOptions(ln: lines[index].lineName, ls: lines[index].lineSize)
                    lines[index].neutralIndex = opts.count == 1 ? 0 : -1
                }
                if lines.count > 1 {
                    Button(action: { lines.remove(at: index) }) {
                        Image(systemName: "minus.circle").foregroundColor(.red).font(.caption)
                    }.buttonStyle(.borderless).frame(width: 24)
                }
            }
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
                .labelsHidden().frame(maxWidth: .infinity).disabled(opts.isEmpty)
                TextField("km", text: $lines[index].distanceText)
                    .keyboardType(.decimalPad).focused($isTextFieldFocused)
                    .frame(width: 60).textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    func resultRow(label: String, value: String, color: Color, onDetail: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline)
            Text(value).font(.title).bold().foregroundColor(color)
            Button("계산과정 보기", action: onDetail).font(.caption)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    func detailSheet(title: String, text: String, binding: Binding<Bool>) -> some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { binding.wrappedValue = false }
                }
            }
        }
    }

    var dbSheet: some View {
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
                        }.font(.caption2)
                        ForEach(lineImpedanceDB.filter { $0.ln == name }) { db in
                            HStack {
                                Text(db.ls).frame(width: 30, alignment: .leading)
                                Text("\(db.nn.components(separatedBy: "-").first ?? "") \(db.ns)").frame(width: 50, alignment: .leading)
                                Text(String(format: "%.4f", db.rs1)).frame(maxWidth: .infinity, alignment: .trailing)
                                Text(String(format: "%.4f", db.xs1)).frame(maxWidth: .infinity, alignment: .trailing)
                                Text(String(format: "%.4f", db.rs0)).frame(maxWidth: .infinity, alignment: .trailing)
                                Text(String(format: "%.4f", db.xs0)).frame(maxWidth: .infinity, alignment: .trailing)
                            }.font(.caption2)
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

#Preview {
    ContentView()
}
