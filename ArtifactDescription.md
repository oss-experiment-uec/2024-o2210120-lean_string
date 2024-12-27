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

[Miri](https://github.com/rust-lang/miri) を使用する。
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
==> cargo miri test --target i686-unknown-linux-gnu --all-features
....ログがたくさん出る
error: could not compile `lean_string` (lib) due to 80 previous errors; 1 warning emitted
warning: build failed, waiting for other jobs to finish..
```

after を選択し、全てパスすれば良い。

```console
Select implementation to test (before/after): after
==> cd /workspace/after
/workspace/after
==> cargo miri test --target i686-unknown-linux-gnu --all-features
....ログがたくさん出る
test result: ok. 1 passed; 0 failed; 1 ignored; 0 measured; 0 filtered out; finished in 0.47s
```

テストは複数存在するため上記のような `test result: ok.` が複数個表示される。
また、いくつかのテストケースは `ignored` となるが、これは問題ない。

もし仮にエラーが発生した場合はそのテストで停止し `error: test failed` と表示されるのですぐに気がつく
今回は正しく改変されるはずなのでこれは表示されないはずである。

### テストケース

使用されたテストケースが記述されたファイルは tests ディレクトリ以下に格納されている

以下の例では改変後のリポジトリ以下に移動し、cat で内容を確認している。

```console
$ docker run -it --rm --name lean_string ryota2357/oss-experiment-uec-2024-lean_string bash
root@09ac733d95b8:/workspace# ls
after  before  run_tests.sh
root@09ac733d95b8:/workspace# cd after/tests/
root@09ac733d95b8:/workspace/after/tests# ls
alloc_string.rs  arbitrary.rs  handmade.rs  loom.rs  property.rs  serde.rs
root@09ac733d95b8:/workspace/after/tests# cat handmade.rs
use lean_string::LeanString;

const INLINE_LIMIT: usize = size_of::<LeanString>();

#[test]
fn new_empty() {
    assert_eq!(LeanString::new(), "");

    let s = LeanString::new();
    assert_eq!(s.as_str(), "");
    assert!(s.is_empty());
    assert_eq!(s.len(), 0);
    assert!(!s.is_heap_allocated());
    assert_eq!(s.capacity(), INLINE_LIMIT);
...省略
```

## 制限と展望

この評価で使用した Miri によるテストでは、リポジトリ内に存在するテストケースを全て実行できていない。これは意図的である。
並列プログラムテストツールである [Loom](https://github.com/tokio-rs/loom) を使用したテストケースと [Proptest](https://github.com/proptest-rs/proptest) を使用したテストケースが実行されていない。
理由は、

1. 今回の変更箇所により、これらテストケースが失敗するようになるとは考えにく、
2. それよりもメモリの不正操作や未定義動作を起こしてしまう可能性が高い。
3. また、Miri に加えて Loom のテストも行うと「評価」にかかる時間が長くなってしまう。

というものである。なお、これらについてはローカルではテストしてあり、全てパスしている。

## 更なる使い方

今回の変更を含めたものが [lean_string v0.3.0](https://docs.rs/lean_string/0.3.0/lean_string/) としてリリース済みである。
Cargo.toml に `lean_string = "0.3.0"` を追加して利用可能である。
各種メソッドの使用方法は[ドキュメント](https://docs.rs/lean_string/0.3.0/lean_string/struct.LeanString.html)を参照。
