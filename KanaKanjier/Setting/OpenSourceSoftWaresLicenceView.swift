//
//  OpenSourceSoftWaresLicenceView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct OpenSourceSoftWaresLicenceView: View {
    private let licence_mecab = """
    MeCab is copyrighted free software by Taku Kudo <taku@chasen.org> and
    Nippon Telegraph and Telephone Corporation, and is released under
    any of the GPL (see the file GPL), the LGPL (see the file LGPL), or the
    BSD License (see the file BSD).
    """

    private let licence_ipadic = """
    Copyright 2000, 2001, 2002, 2003 Nara Institute of Science
    and Technology.  All Rights Reserved.

    Use, reproduction, and distribution of this software is permitted.
    Any copy of this software, whether in its original form or modified,
    must include both the above copyright notice and the following
    paragraphs.

    Nara Institute of Science and Technology (NAIST),
    the copyright holders, disclaims all warranties with regard to this
    software, including all implied warranties of merchantability and
    fitness, in no event shall NAIST be liable for
    any special, indirect or consequential damages or any damages
    whatsoever resulting from loss of use, data or profits, whether in an
    action of contract, negligence or other tortuous action, arising out
    of or in connection with the use or performance of this software.

    A large portion of the dictionary entries
    originate from ICOT Free Software.  The following conditions for ICOT
    Free Software applies to the current dictionary as well.

    Each User may also freely distribute the Program, whether in its
    original form or modified, to any third party or parties, PROVIDED
    that the provisions of Section 3 ("NO WARRANTY") will ALWAYS appear
    on, or be attached to, the Program, which is distributed substantially
    in the same form as set out herein and that such intended
    distribution, if actually made, will neither violate or otherwise
    contravene any of the laws and regulations of the countries having
    jurisdiction over the User or the intended distribution itself.

    NO WARRANTY

    The program was produced on an experimental basis in the course of the
    research and development conducted during the project and is provided
    to users as so produced on an experimental basis.  Accordingly, the
    program is provided without any warranty whatsoever, whether express,
    implied, statutory or otherwise.  The term "warranty" used herein
    includes, but is not limited to, any warranty of the quality,
    performance, merchantability and fitness for a particular purpose of
    the program and the nonexistence of any infringement or violation of
    any right of any third party.

    Each user of the program will agree and understand, and be deemed to
    have agreed and understood, that there is no warranty whatsoever for
    the program and, accordingly, the entire risk arising from or
    otherwise connected with the program is assumed by the user.

    Therefore, neither ICOT, the copyright holder, or any other
    organization that participated in or was otherwise related to the
    development of the program and their respective officials, directors,
    officers and other employees shall be held liable for any and all
    damages, including, without limitation, general, special, incidental
    and consequential damages, arising out of or otherwise in connection
    with the use or inability to use the program or any product, material
    or result produced or otherwise obtained by using the program,
    regardless of whether they have been advised of, or otherwise had
    knowledge of, the possibility of such damages at any time during the
    project or thereafter.  Each user will be deemed to have agreed to the
    foregoing by his or her commencement of use of the program.  The term
    "use" as used herein includes, but is not limited to, the use,
    modification, copying and distribution of the program and the
    production of secondary products from the program.

    In the case where the program, whether in its original form or
    modified, was distributed or delivered to or received by a user from
    any person, organization or entity other than ICOT, unless it makes or
    grants independently of ICOT any specific warranty to the user in
    writing, such person, organization or entity, will also be exempted
    from and not be held liable to the user for any such damages as noted
    above as far as the program is concerned.
    """

    var body: some View {
        Form {
            Section {
                Text("本アプリケーションは多くのオープンソースソフトウェアを用いて作成されています。この場を借りて感謝申し上げます。")
            }
            Group {
                Section {
                    Text("JMdict/EDICT").font(.title).padding()
                    Text("本アプリケーションは基礎的な語彙の基盤としてJMdict/EDICTを使用しています。これらのファイルはElectronic Dictionary Research and Development Groupの所有物であり、ライセンスに基づいて使用されています。")
                    FallbackLink("Licence", destination: "https://www.edrdg.org/edrdg/licence.html")
                    FallbackLink("JMdict-EDICT Dictionary Project", destination: "https://www.edrdg.org/wiki/index.php/JMdict-EDICT_Dictionary_Project")
                }
                Section {
                    Text("IPAdic").font(.title).padding()
                    Text("本アプリケーションは基礎的な語彙の基盤としてIPAdicを使用しています。")
                    Text(licence_ipadic)
                }
                Section {
                    Text("MeCab").font(.title).padding()
                    Text("本アプリケーションは形態素解析器としてMeCabを使用しています。")
                    FallbackLink("MeCab: Yet Another Part-of-Speech and Morphological Analyzer", destination: "https://taku910.github.io/mecab/")
                    Text(licence_mecab)
                }
                Section {
                    Text("mecab-ipadic-NEologd").font(.title).padding()
                    Text("本アプリケーションは固有名詞などの解析のためmecab-ipadic-NEologdを使用しています。")
                    FallbackLink("Licence", destination: "https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING")
                    FallbackLink("mecab-ipadic-NEologd : Neologism dictionary for MeCab", destination: "https://github.com/neologd/mecab-ipadic-neologd")
                }
                Section {
                    Text("MJ文字情報一覧表").font(.title).padding()
                    Text("本アプリケーションは音読みから漢字への変換を行うためMJ文字情報一覧表を使用しています。")
                    Text("本アプリケーションの持つ辞書のうち、MJ文字情報一覧表から派生した部分はクリエイティブ・コモンズ 表示 – 継承 2.1 日本 ライセンスを継承し、その著作権は独立行政法人情報処理推進機構(IPA)に帰属します。")
                    FallbackLink("MJ文字情報一覧表 | 文字情報基盤整備事業", destination: "https://moji.or.jp/mojikiban/mjlist/#")
                }
                Section {
                    Text("japanese-word2vec-model-builder").font(.title).padding()
                    Text("本アプリケーションは変換精度の向上のためjapanese-word2vec-model-builderを使用しています。")
                    FallbackLink("Licence", destination: "https://github.com/shiroyagicorp/japanese-word2vec-model-builder/blob/master/LICENSE")
                    FallbackLink("Japanese Word2Vec Model Builder", destination: "https://github.com/shiroyagicorp/japanese-word2vec-model-builder")
                }

                Group {
                    Section {
                        Text("Emoji-IME-Dictionary").font(.title).padding()
                        Text("本アプリケーションは絵文字への変換候補を表示するためにEmoji-IME-Dictionaryのデータを使用しています。")
                        FallbackLink("Licence", destination: "https://github.com/peaceiris/emoji-ime-dictionary/blob/main/LICENSE")
                        FallbackLink("Emoji-IME-Dictionary", destination: "https://github.com/peaceiris/emoji-ime-dictionary")
                    }

                    Section {
                        Text("Kaomojitoka to Google IME Dictionary").font(.title).padding()
                        Text("本アプリケーションは顔文字への変換候補を表示するためにKaomojitoka to Google IME Dictionaryのデータを使用しています。")
                        FallbackLink("Licence", destination: "https://github.com/nikukyugamer/kaomojitoka-to-google-ime-dictionary/blob/master/LICENSE")
                        FallbackLink(
                            "Kaomojitoka to Google IME Dictionary",
                            destination: "https://github.com/nikukyugamer/kaomojitoka-to-google-ime-dictionary"
                        )
                    }

                    Section {
                        Text("Kaomojic").font(.title).padding()
                        Text("本アプリケーションは顔文字への変換候補を表示するためにKaomojicのデータを使用しています。")
                        FallbackLink("Licence", destination: "https://github.com/mika-f/kaomojic/blob/develop/LICENSE")
                        FallbackLink("Kaomojic", destination: "https://github.com/mika-f/kaomojic")
                    }
                }

                Section {
                    Text("CustardKit").font(.title).padding()
                    Text("本アプリケーションで利用可能なカスタムタブのデータ構造の記述をCustardKitとしてオープンソースで公開し、アプリ内でも使用しています。")
                    FallbackLink("Licence", destination: "https://github.com/ensan-hcl/CustardKit/blob/main/LICENSE")
                    FallbackLink(
                        "CustardKit",
                        destination: "https://github.com/ensan-hcl/CustardKit"
                    )
                }

                Section {
                    Text("YMTGetDeviceName").font(.title).padding()
                    Text("本アプリケーションはデバイスが地球儀ボタンを表示すべき端末であるか判定するために。YMTGetDeviceNameを使用しています。")
                    FallbackLink("Licence", destination: "https://github.com/MasamiYamate/YMTGetDeviceName/blob/master/LICENSE")
                    FallbackLink(
                        "YMTGetDeviceName",
                        destination: "https://github.com/MasamiYamate/YMTGetDeviceName"
                    )
                }
                Group {
                    Section {
                        Text("Swift Algorithms").font(.title).padding()
                        Text("本アプリケーションはSwift Algorithmsを使用しています。")
                        FallbackLink("Apache License 2.0", destination: "https://github.com/apple/swift-algorithms/blob/main/LICENSE.txt")
                        FallbackLink(
                            "Swift Algorithms",
                            destination: "https://github.com/apple/swift-algorithms"
                        )
                    }
                    Section {
                        Text("Swift Collections").font(.title).padding()
                        Text("本アプリケーションはSwift Collectionsを使用しています。")
                        FallbackLink("Apache License 2.0", destination: "https://github.com/apple/swift-collections/blob/main/LICENSE.txt")
                        FallbackLink(
                            "Swift Collections",
                            destination: "https://github.com/apple/swift-collections"
                        )
                    }
                }
            }
            Section {
                HStack {
                    AzooKeyIcon(fontSize: 60)
                    Spacer()
                    Text("azooKeyを使ってくれてありがとう！")
                }
                .animation(.interpolatingSpring(stiffness: 30, damping: 5))

            }
        }
        .multilineTextAlignment(.leading)
        .navigationBarTitle(Text("オープンソースソフトウェア"), displayMode: .inline)
    }
}
