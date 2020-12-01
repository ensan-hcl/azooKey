//
//  isPrime.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest

class PrimePeformance: XCTestCase{
    func testPerformancePure() throws {
        print()
        self.measure{
            let n = Int(10e7)
            // 数字が素数かどうかを持っておく配列を用意(false:素数、true:素数ではない)
            var is_prime = [Bool](repeating:false,count:n+1)
            // 0と1は素数ではないのでtrueを代入
            is_prime[0] = true
            is_prime[1] = true
            // エラトステネスの篩を利用する
            // 計算するのは√nまでで十分
            for i in 2...Int(sqrt(Double(n)))+1{
                // コーナーケースになりうるものは除いておく
                if i > n || n == 2{
                    continue
                }
                //iが素数でなければcontinue
                if is_prime[i]{
                    continue
                }
                // iが素数なら、n以下のiの倍数をすべてtrueにする
                var cnt = 2
                while i*cnt <= n{
                    is_prime[i*cnt] = true
                    cnt += 1
                }
            }
            // 戻り値となる配列を用意
            var result:[Int] = []
            for i in 0...n{
                // 素数ならresultに追加
                if is_prime[i]{
                    continue
                }
                result.append(i)
            }
            // resultを返す
            print(result.count)
        }
    }

    func testPerformanceReviewed() throws {
        print()
        self.measure{
            let n = Int(10e7)
            // 数字が素数かどうかを持っておく配列を用意(false:素数、true:素数ではない)。
            var is_not_prime = [Bool](repeating: false, count: n+1)
            // 0と1は素数ではないのでtrueを代入。
            is_not_prime[0] = true
            is_not_prime[1] = true
            // エラトステネスの篩を利用する
            // 計算するのは√nまでで十分
            (2...min(Int(sqrt(Double(n)))+1, n)).forEach{i in
                //is_not_prime[i]が最も成立しやすい条件なので、これを先に置くことで若干高速化が狙える。
                if is_not_prime[i] || n == 2{
                    return
                }
                //iが素数なら、n以下のiの倍数をすべてtrueにする。
                (2...n/i).forEach{
                    is_not_prime[i*$0] = true
                }
            }
            //2の倍数の場合を最初から除外することで、高速化が狙える。
            let result = [2] + stride(from: 3, to: n, by: 2).filter{!is_not_prime[$0]}
            // resultを返す
            print(result.count)
        }
    }

    func testPerformanceSet() throws {
        print()
        self.measure{
            let n = Int(10e7)
            // 数字が素数かどうかを持っておく配列を用意(false:素数、true:素数ではない)
            var is_prime = [Bool](repeating: true, count: n+1)
            // 0と1は素数ではないのでtrueを代入
            is_prime[0] = false
            is_prime[1] = false
            (0...n/2).forEach{
                is_prime[$0*2] = false
            }
            // エラトステネスの篩を利用する
            // 計算するのは√nまでで十分
            stride(from: 3, to: min(Int(sqrt(Double(n)))+1, n), by: 2).forEach{i in
                if is_prime[i]{
                    // iが素数なら、n以下のiの倍数をすべてtrueにする
                    (2...n/i).forEach{
                        is_prime[i*$0] = false
                    }
                }
            }
            // resultを返す
            let result = [2] + stride(from: 3, to: n, by: 2).filter{is_prime[$0]}
            print(result.count)
        }
    }

    func check_primes_pure(n:Int)->Bool{
        // 計算するのは√nまでで十分
        for i in 2...Int(sqrt(Double(n)))+1{
            // コーナーケースになりうるものは除いておく
            if i > n || n == 2{
                continue
            }
            if n%i == 0{
                return false
            }
        }
        return true
    }

    func check_primes_reviewed(n:Int)->Bool{
        if n == 2{
            return true
        }
        if n.isMultiple(of: 2){
            return false
        }
        // 計算するのは√nまでで十分
        //2の倍数をスキップして計算する
        for i in stride(from: 3, to: min(Int(sqrt(Double(n)))+1, n), by: 2){
            if n.isMultiple(of: i){
                return false
            }
        }
        return true
    }


    func testPerformanceCheckPrimePure() throws {
        print()
        self.measure{
            let values = Array(10000000...11000000)
            values.forEach{
                let bool = check_primes_pure(n: $0)
            }
        }
    }

    func testPerformanceCheckPrimeReviewed() throws {
        print()
        self.measure{
            let values = Array(10000000...11000000)
            values.forEach{
                let bool = check_primes_reviewed(n: $0)
            }
        }
    }

}
