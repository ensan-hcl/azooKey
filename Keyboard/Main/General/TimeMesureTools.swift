//
//  TimeMesureTools.swift
//  Keyboard
//
//  Created by β α on 2020/12/14.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

protocol BenchmarkTarget {
    associatedtype ProcessType: Hashable, CustomDebugStringConvertible
}

struct Kana2KanjiTarget: BenchmarkTarget {
    enum ProcessType: String, CustomDebugStringConvertible {
        case LOUDSTXT2読み込み_全体
        case LOUDS_前方一致検索
        case LOUDS_byfix検索
        case LOUDS_検索_childNodeIndices
        case LOUDS_検索_searchCharNodeIndex
        case LOUDS_ビルド
        case LOUDS_ビルド_バイナリ読み込み
        case 辞書読み込み_全体
        case 辞書読み込み_軽量データ読み込み
        case 辞書読み込み_誤り訂正候補列挙
        case 辞書読み込み_検索対象列挙
        case 辞書読み込み_検索
        case 辞書読み込み_辞書データ生成
        case 辞書読み込み_ノード生成
        case 変換_全体
        case 変換_辞書読み込み
        case 変換_処理
        case 変換_処理_N_Best計算
        case 変換_処理_連接コスト計算_全体
        case 変換_処理_連接コスト計算_CCValue
        case 変換_処理_連接コスト計算_Memory
        case 変換_結果処理
        case 結果の処理_全体
        case 結果の処理_文節化
        case 結果の処理_文全体変換
        case 結果の処理_予測変換_全体
        case 結果の処理_予測変換_日本語_全体
        case 結果の処理_予測変換_日本語_雑多なデータ取得
        case 結果の処理_予測変換_日本語_Dicdataの読み込み
        case 結果の処理_予測変換_日本語_連接計算
        case 結果の処理_予測変換_外国語
        case 結果の処理_予測変換_ゼロヒント
        case 結果の処理_付加候補
        case 結果の処理_並び替え

        var debugDescription: String {
            return self.rawValue
        }
    }
}

final class BenchmarkTool<Target: BenchmarkTarget> {
    var benchmarks: [Target.ProcessType: (Int, Double)] = [:]
    var timers: [Target.ProcessType: Date] = [:]
    var timeFormatter = NumberFormatter()

    init() {
        self.timeFormatter.maximumIntegerDigits = 2
        self.timeFormatter.maximumFractionDigits = 6
        self.timeFormatter.minimumFractionDigits = 6
    }

    @inlinable
    func start(process: Target.ProcessType) {
        #if DEBUG
        self.timers[process] = Date()
        #endif
    }

    @inlinable
    func end(process: Target.ProcessType) {
        #if DEBUG
        guard let time = timers[process] else {
            return
        }
        let benchmark = -time.timeIntervalSinceNow
        let (count, timeSum) = benchmarks[process, default: (.zero, .zero)]
        benchmarks[process, default: (.zero, .zero)] = (count+1, timeSum + benchmark)
        #endif
    }

    func reset() {
        self.benchmarks = [:]
        self.timers = [:]
    }

    @inlinable
    func result() {
        #if DEBUG
        let pairs = self.benchmarks.map {(key: $0.key, value: $0.value)}
        debug("=== Benchmark Result ===")
        debug(pairs.sorted {$0.value > $1.value}.map {"⏱\(self.timeFormatter.string(from: NSNumber(value: $0.value.1)) ?? "") - \($0.value.0): \($0.key.debugDescription)"}.joined(separator: "\n"))
        debug("=== === ===  === === ===")
        #endif
    }
}

// MARK: 速度測定用のベンチマークツール
// ターゲットとして次の文章を用いる。
// ベンチマークツールそのものの速度への影響があるので注意が必要
//  ようしょうきからてにすすいえいやきゅうしょうりんじけんぽうなどさまざまなすぽーつをけいけんしながらそだちしょうがっこうじだいはろさんせるすきんこうにたいざいしておりごるふやてにすをならっていた

var conversionBenchmark = BenchmarkTool<Kana2KanjiTarget>()
