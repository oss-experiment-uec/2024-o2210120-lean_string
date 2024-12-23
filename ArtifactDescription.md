# Artifact Description

## 概要：32ビットアーキテクチャ対応

### 本ソフトウェアの説明

本ソフトウェア (`lean_string::LeanString`) は文字列を格納するデータ構造である。
標準ライブラリにも文字列を格納するデータ構造 `String` があるが、以下の点が異なっている。
以下標準ライブラリのものを `String`、本ソフトウェアのものを `LeanString` と呼ぶ。

- データ構造自体のサイズは2ワードである。(`String` は3ワード)
- `String` は1バイト以上の文字列をヒープに格納するが、`LeanString` は2ワード分(64ビットアーキテクチャであれば16バイト)の文字列をインライン(スタック)に格納し、それ以上の大きさの文字列のみヒープに格納する。(Small String Optimization)
- `LeanString` の複製(clone) は O(1) であり、格納されている文字列への編集を行おうとした時に初めて複製が行われる。(Clone-on-Write)

### 改変内容

`LeanString` の実装には多くのポインタ演算やビット演算が用いられており、それらはアーキテクチャのポインタサイズに依存したものが多く、現状は64ビットアーキテクチャのみを対象とした実装となっている。

本改変では32ビットアーキテクチャでも同様に動くようにした。

## 評価手順

### 概要

Miri を使用する。
Miri は Rust 言語の中間表現レベルでのインタプリタであり、複数のターゲットのエミュレートや未定義動作の実行時検出が可能なソフトウェアである。
Rust チームが公式で開発しており、標準ライブラリやその他多くのライブラリのテストで利用されている。

今回の評価では、32ビットアーキテクチャ環境においても、既に(改変元に)用意されているテストを全てパスすれば期待通り改変できているとする。

使用するターゲットは i686-unknown-linux-gnu である。

### 評価を行う

Docker イメージは既に Docker Hub に上がっているのでそれを使用する。
なおイメージを作成するのに使われた Dockerfile は [ArtifactEvaluation/Dockerfile](./ArtifactEvaluation/Dockerfile) である。

次のようにして、Docker イメージを pull して run する。

```console
$ docker pull ryota2357/oss-experiment-uec-2024-lean_string

$ docker run -it --rm --name lean_string ryota2357/oss-experiment-uec-2024-lean_string
Select implementation to test (before/after):
```

このように、改変前 (before) か改変後 (after) のどちらのテストを実行するか聞かれるので、それに答える。
例えば、before を選択すると、次のようにコンパイルエラーとなっていることが確認できる。

```console
Select implementation to test (before/after): before
==> cd /workspace/before
/workspace/before
==> cargo miri test --target i686-unknown-linux-gnu
....ログがたくさん出る
error: could not compile `lean_string` (lib) due to 80 previous errors; 1 warning emitted
warning: build failed, waiting for other jobs to finish..
```

after を選択し、全てパスすれば良い。(まだ実装が終わっていないため、現状はエラーになります。)

```console
TODO
```

## 制限と展望

TODO

## 更なる使い方

TODO
