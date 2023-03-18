from collections import defaultdict, namedtuple
import os
import re
import jaconv
# 実行中のディレクトリを取得する
cwd = os.path.dirname(os.path.abspath(__file__))
# cwdの1つ上の階層を取得する
parent_dir = os.path.dirname(cwd)


# Emojiのデータを自動生成する
# emoji_data.tsvは以下のフォーマット
# >
# The data format is tab separated fields as follows:
# 1) unicode code point
# 2) actual data (in utf-8)
# 3) space separated Yomi
# 4) unicode name
# 5) Japanese name
# 6) space separated descriptions
# 7) unicode emoji version
# Sample:
# 1F1E6 1F1E8	🇦🇨	はた あせんしょんとう				E2.0
#
# emoji-sequences.txt, emoji-zwj-sequences.txtは以下のフォーマット
# >
# Format:
#   code_point(s) ; type_field ; description # comments
# Fields:
#   code_point(s): one or more code points in hex format, separated by spaces
#   type_field, one of the following:
#       Basic_Emoji
#       Emoji_Keycap_Sequence
#       RGI_Emoji_Flag_Sequence
#       RGI_Emoji_Tag_Sequence
#       RGI_Emoji_Modifier_Sequence
#     The type_field is a convenience for parsing the emoji sequence files, and is not intended to be maintained as a property.
#   short name: CLDR short name of sequence; characters may be escaped with \x{hex}.

# Emojiのデータ型をnamedtupleで定義する
# fieldはgenre, codepoints, variations, search keywords, emoji version
Emoji = namedtuple(
    'Emoji', ["genre", "codepoints", "variations", "keywords", "version", "order"])


# Emojiのデータを格納するリスト
emojis = []

# genreは一旦全てNoneで初期化する
# 基本的にはemoji_data.tsvのデータを格納し、emoji-sequences.txt、emoji-zwj-sequences.txtのデータからSkin Tone Modifierのついているバージョンを`variations`のフィールドに追加する。
# emoji_data.tsvを読み込む
with open(f'{parent_dir}/data/emoji_data.tsv', 'r') as f:
    for line in f:
        # コメント行は読み飛ばす
        if line.startswith('#'):
            continue
        # データをタブで分割する
        data = line.strip().split('\t')
        # データの数が7個でなければエラー
        if len(data) != 7:
            raise ValueError('Invalid data: {}'.format(line))
        # データを変数に格納する
        codepoints, unicode_emoji, name, _, jname, _, version = data
        # codepointsを空白で分割し、intに変換する
        codepoints = [int(cp, 16) for cp in codepoints.strip().split(' ')]
        # nameを空白で分割する
        name = name.split(' ')
        # jnameを空白で分割する
        jname = jname.split(' ')
        # nameとjnameを結合する
        keywords = name + jname
        # Emojiのデータを作成する
        emoji = Emoji(None, unicode_emoji, [], keywords, version, None)
        # Emojiのデータをリストに追加する
        emojis.append(emoji)
# print(emojis)

# emoji-sequences.txtを読み込み、Skin Tone Modifierのついているバージョンを`variations`のフィールドに追加する
with open(f'{parent_dir}/data/emoji-sequences.txt', 'r') as f:
    for line in f:
        # コメント行は読み飛ばす
        if line.startswith('#'):
            continue
        if not line.strip():
            continue
        # データをタブで分割する
        data = line.strip().split(';')
        # print(data)
        # データの数が3個でなければエラー
        if len(data) != 3:
            raise ValueError('Invalid data: {}'.format(line))
        # データを変数に格納する
        codepoints, genre, _ = data
        # codepointsに「..」が含まれている場合は読み飛ばす
        if '..' in codepoints:
            continue
        # codepointsを空白で分割し、intに変換する
        codepoints = [int(cp, 16) for cp in codepoints.strip().split(' ')]
        # skin tone modifierは0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FFの5つ
        # codepointsにこれらが含まれていない場合は読み飛ばす
        if not any(cp in codepoints for cp in range(0x1F3FB, 0x1F3FF + 1)):
            continue
        # codepointsからSkin Tone Modifierを除外する
        base_codepoints = [cp for cp in codepoints if cp not in range(
            0x1F3FB, 0x1F3FF + 1)]
        base_unicode_emoji = "".join([chr(cp)for cp in base_codepoints])
        # Skin Tone Modifierのついているバージョンを`variations`のフィールドに追加する
        for emoji in emojis:
            if emoji.codepoints == base_unicode_emoji:
                unicode_emoji = "".join([chr(cp)for cp in codepoints])
                emoji.variations.append(unicode_emoji)
                break
        else:
            print(data)


def zwj_sequence_skin_tone_pattern_match(codepoints, pattern):
    """
    skin-tone modifierは-1で指定する
    """
    if len(codepoints) != len(pattern):
        return False
    for cp, p in zip(codepoints, pattern):
        if p == -1:
            if cp not in range(0x1F3FB, 0x1F3FF + 1):
                return False
        else:
            if cp != p:
                return False
    return True


# emoji-zwj-sequences.txtを読み込み、Skin Tone Modifierのついているバージョンを`variations`のフィールドに追加する
with open(f'{parent_dir}/data/emoji-zwj-sequences.txt', 'r') as f:
    for line in f:
        # コメント行は読み飛ばす
        if line.startswith('#'):
            continue
        if not line.strip():
            continue
        # データをタブで分割する
        data = line.strip().split(';')
        # print(data)
        # データの数が3個でなければエラー
        if len(data) != 3:
            raise ValueError('Invalid data: {}'.format(line))
        # データを変数に格納する
        codepoints, genre, _ = data
        # codepointsに「..」が含まれている場合は読み飛ばす
        if '..' in codepoints:
            continue
        # codepointsを空白で分割し、intに変換する
        codepoints = [int(cp, 16) for cp in codepoints.strip().split(' ')]
        unicode_emoji = "".join([chr(cp)for cp in codepoints])
        # 特定のコードポイントは追加だけして終わる
        if codepoints == [0x1F468, 0x200D, 0x1F9B0]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "男性", "男", "おとこ", "顔", "かお", "赤い髪", "髪", "赤髪"], "E11.0", None))
            continue
        elif codepoints == [0x1F468, 0x200D, 0x1F9B1]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "男性", "男", "おとこ", "顔", "かお", "カール", "髪", "巻き毛"], "E11.0", None))
            continue
        elif codepoints == [0x1F468, 0x200D, 0x1F9B2]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "男性", "男", "おとこ", "顔", "かお", "ハゲ", "脱毛"], "E11.0", None))
            continue
        elif codepoints == [0x1F468, 0x200D, 0x1F9B3]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "男性", "男", "おとこ", "顔", "かお", "白い髪", "髪", "白髪"], "E11.0", None))
            continue
        elif codepoints == [0x1F469, 0x200D, 0x1F9B0]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "女性", "女", "おんな", "顔", "かお", "赤い髪", "髪", "赤髪"], "E11.0", None))
            continue
        elif codepoints == [0x1F469, 0x200D, 0x1F9B1]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "女性", "女", "おんな", "顔", "かお", "カール", "髪", "巻き毛"], "E11.0", None))
            continue
        elif codepoints == [0x1F469, 0x200D, 0x1F9B2]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "女性", "女", "おんな", "顔", "かお", "ハゲ", "脱毛"], "E11.0", None))
            continue
        elif codepoints == [0x1F469, 0x200D, 0x1F9B3]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "女性", "女", "おんな", "顔", "かお", "白い髪", "髪", "白髪"], "E11.0", None))
            continue
        elif codepoints == [0x1F9D1, 0x200D, 0x1F9B0]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "顔", "かお", "赤い髪", "髪", "赤髪"], "E11.0", None))
            continue
        elif codepoints == [0x1F9D1, 0x200D, 0x1F9B1]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                          "顔", "かお", "カール", "髪", "巻き毛"], "E11.0", None))
            continue
        elif codepoints == [0x1F9D1, 0x200D, 0x1F9B2]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                "顔", "かお", "ハゲ", "脱毛"], "E11.0", None))

            continue
        elif codepoints == [0x1F9D1, 0x200D, 0x1F9B3]:
            emojis.append(Emoji(None, unicode_emoji, [], [
                "顔", "かお", "白い髪", "髪", "白髪"], "E11.0", None))

            continue

        # skin tone modifierは0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FFの5つ
        # codepointsにこれらが含まれていない場合は読み飛ばす
        if not any(cp in codepoints for cp in range(0x1F3FB, 0x1F3FF + 1)):
            continue

        # codepointsの特殊なルールを適用
        # 1F9D1 _ 200D 2764 FE0F 200D 1F9D1 _のパターンにマッチする場合、0x1F491のvariationにする
        if zwj_sequence_skin_tone_pattern_match(codepoints, [0x1F9D1, -1, 0x200D, 0x2764, 0xFE0F, 0x200D, 0x1F9D1, -1]):
            base_codepoints = [0x1F491]
        # 1F9D1 _ 200D 2764 FE0F 200D 1F48B 200D 1F9D1 _のパターンにマッチする場合、0x1F48Fのvariationにする
        elif zwj_sequence_skin_tone_pattern_match(codepoints, [0x1F9D1, -1, 0x200D, 0x2764, 0xFE0F, 0x200D, 0x1F48B, 0x200D, 0x1F9D1, -1]):
            base_codepoints = [0x1F48F]
        # 1F468 _ 200D 1F91D 200D 1F468 _のパターンにマッチする場合、0x1F46Cのvariationにする
        elif zwj_sequence_skin_tone_pattern_match(codepoints, [0x1F468, -1, 0x200D, 0x1F91D, 0x200D, 0x1F468, -1]):
            base_codepoints = [0x1F46C]
        # 1F469 _ 200D 1F91D 200D 1F468 _のパターンにマッチする場合、0x1F46Bのvariationにする
        elif zwj_sequence_skin_tone_pattern_match(codepoints, [0x1F469, -1, 0x200D, 0x1F91D, 0x200D, 0x1F468, -1]):
            base_codepoints = [0x1F46B]
        # 1F469 _ 200D 1F91D 200D 1F469 _のパターンにマッチする場合、0x1F46Dのvariationにする
        elif zwj_sequence_skin_tone_pattern_match(codepoints, [0x1F469, -1, 0x200D, 0x1F91D, 0x200D, 0x1F469, -1]):
            base_codepoints = [0x1F46D]
        # handshake: 1F91C, pattern: 1FAF1 _ 200D 1FAF2 _
        elif zwj_sequence_skin_tone_pattern_match(codepoints, [0x1FAF1, -1, 0x200D, 0x1FAF2, -1]):
            base_codepoints = [0x1F91C]
        else:
            # codepointsからSkin Tone Modifierを除外する
            base_codepoints = [cp for cp in codepoints if cp not in range(
                0x1F3FB, 0x1F3FF + 1) and cp != 0xFE0F]
        base_unicode_emoji = "".join([chr(cp)for cp in base_codepoints])
        # print(base_codepoints)
        # print(base_unicode_emoji)
        # Skin Tone Modifierのついているバージョンを`variations`のフィールドに追加する
        for emoji in emojis:
            if emoji.codepoints == base_unicode_emoji:
                unicode_emoji = "".join([chr(cp)for cp in codepoints])
                emoji.variations.append(unicode_emoji)
                # print(emoji)
                break
        else:
            print(base_unicode_emoji)
            print(data, base_codepoints)


def apply_cldr_data(emojis, file_name):
    # ja.xmlを読み込んで絵文字の検索クエリを追加する
    # ja.xmlのフォーマットは、<annotation cp="emoji.codepoints" type="tts">'|'-separated queries</annotation>
    # <annotation cp="😖">困惑 | 困惑した顔 | 混乱 | 顔</annotation>
    with open(f"{parent_dir}/data/{file_name}", "r") as f:
        for line in f:
            if not line.strip():
                continue
            codepoints = None
            queries = set()
            # 正規表現を使う
            match = re.findall(
                r'<annotation cp=".+?" type="tts">.+</annotation>', line)
            if match:
                codepoints = match[0].split("\"")[1]
                _queries = re.sub(r"</?annotation.*?>", "", match[0])
                queries |= {query.strip() for query in _queries.split("|")}
            match = re.findall(
                r'<annotation cp=".+?">.+</annotation>', line)
            if match:
                codepoints = match[0].split("\"")[1]
                _queries = re.sub(r"</?annotation.*?>", "", match[0])
                queries |= {query.strip() for query in _queries.split("|")}

            if codepoints is None:
                continue
            codepoints2 = "".join(
                [cp for cp in codepoints if ord(cp) != 0xFE0F])

            for i in range(len(emojis)):
                if emojis[i].codepoints in [codepoints, codepoints2]:
                    for query in queries:
                        # queryのフィルタ
                        if query.startswith("旗: "):
                            query = query[3:]
                        emojis[i].keywords.append(query)


apply_cldr_data(emojis, "ja.xml")
apply_cldr_data(emojis, "ja_derived.xml")
# emoji-test.txtを読み込んでジャンルの情報を追加する
# emoji-test.txtのフォーマットは、genre_name\temoji_list(comma-separated)
with open(f"{parent_dir}/data/emoji-test.txt", "r") as f:
    current_group = ""
    count = 0
    for line in f:
        if not line.strip():
            continue
        if line.startswith("# group:"):
            current_group = line.split(":")[1].strip()
            # ジャンルの統合
            if current_group == "Smileys & Emotion":
                current_group = "Smileys & People"
            if current_group == "People & Body":
                current_group = "Smileys & People"
            continue
        elif line.startswith("#"):
            continue
        count += 1
        codepoints = [int(cp, 16)
                      for cp in line.split(";")[0].strip().split(" ")]
        unicode_emoji1 = "".join([chr(cp)for cp in codepoints])
        unicode_emoji2 = "".join([chr(cp)for cp in codepoints if cp != 0xFE0F])
        for i in range(len(emojis)):
            if emojis[i].codepoints in [unicode_emoji1, unicode_emoji2]:
                # namedtupleのフィールドを変更するには、_replaceを使う
                emojis[i] = emojis[i]._replace(genre=current_group)
                emojis[i] = emojis[i]._replace(order=count)
                emojis[i] = emojis[i]._replace(codepoints=unicode_emoji1)
        # print(genre, emoji_list)

# フィルタリング
for i in range(len(emojis)):
    # keywordsの「絵文字」を除去する
    if "絵文字" in emojis[i].keywords:
        emojis[i].keywords.remove("絵文字")
    # keywordsの空文字を除去する
    if "" in emojis[i].keywords:
        emojis[i].keywords.remove("")
    # keywordsのカタカナをひらがなに、大文字を小文字に置き換え、重複を除去する
    new_keywords = [
        jaconv.kata2hira(query.lower())
        for query in emojis[i].keywords
    ]
    new_keywords = list(sorted(set(new_keywords)))
    emojis[i] = emojis[i]._replace(keywords=new_keywords)
    if emojis[i].genre is None:
        print("Error", emojis[i].codepoints, [ord(c)
              for c in emojis[i].codepoints])
        continue


def version_greater_or_equal(version1, version2):
    return float(version1[1:]) <= float(version2[1:])


# ジャンルごとにソートする
emojis_genre_sorted = defaultdict(list)
for genre in set([emoji.genre for emoji in emojis]):
    for emoji in emojis:
        if emoji.genre == genre:
            emojis_genre_sorted[genre].append(emoji)
    emojis_genre_sorted[genre] = sorted(
        emojis_genre_sorted[genre], key=lambda emoji: emoji.order)

emojis_sorted = sorted(emojis, key=lambda emoji: emoji.order)
# E13.1以下、E14.0以下、E15.0以下の3つをターゲットにファイルを出力する
for maximum_version in ["E13.1", "E14.0", "E15.0"]:
    # ジャンルごとにソートし、genre\temojis,の形式で出力する
    with open(f"{parent_dir}/generated/emoji_genre_{maximum_version}.txt.gen", "w") as f:
        lines = [genre + "\t" +
                 ",".join([
                     emoji.codepoints
                     for emoji in emojis
                     if version_greater_or_equal(emoji.version, maximum_version)
                 ])
                 for genre, emojis in emojis_genre_sorted.items()
                 ]
        f.write("\n".join(lines))

    # tsvにして./generated/emoji_all.tsv.genを出力する
    with open(f"{parent_dir}/generated/emoji_all_{maximum_version}.txt.gen", "w") as f:
        # emojiの各行をtsvの行にする
        lines = []
        for emoji in emojis_sorted:
            if version_greater_or_equal(emoji.version, maximum_version):
                line = "\t".join([
                    emoji.codepoints,
                    ",".join(emoji.keywords),
                    ",".join(emoji.variations)
                ])
                lines.append(line)
        # tsvの行を出力する
        f.write("\n".join(lines))

print("Successfuly generated emoji data files")
