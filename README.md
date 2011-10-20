Fav Bayes 2
============

これはなに
---------

fav_bayes2 は、 [fav.rb](https://github.com/katsyoshi/fav) についていた fav_bayes がかなりわらなので、もうちょっとマトモなものが欲しいよって言われてつくりました。
でも本家 fav_bayes はたのしいよ。クセが絶妙だよ。

形態素解析して、ナイーブベイズで学習したりします。それだけだと fav 量がすくなくてておくれないので、きあいをいれられます。

Download
--------

もってけー

https://github.com/tomykaira/fav_bayes2/

Install
-------

かならず mecab-ipadic-utf8 を使用してください。
jumandic や utf8 でない辞書をつかうと、形態素解析に失敗し、ちゃんと学習しません。

### ubuntu
    apt-get install mecab mecab-ipadic-utf8 mecab-config

### Mac OS X
    brew install mecab mecab-ipadic

(その他の OS でうごいた人は @tomy_kaira か Issue で報告してね)

### Mecab Ruby Binding(必須)

rubygems などにのっていないので、自分で入手する必要があります。

[Rubyバインディングのソース](http://sourceforge.net/projects/mecab/files/mecab-ruby/0.98/)を入手してください。

次の手順で mecab-ruby-0.98.tar.gz を展開し、 gem を作成し、イントールします。

    tar zxvf mecab-ruby-0.98.tar.gz
    cd mecab-ruby-0.98/
    gem build mecab-ruby.gemspec
    gem install mecab-ruby


Settings
--------

設定画面に「ふぁぼべいず2」タブを追加します。

* 学習する: 学習したいときにつけてください。放置するけど、mikutter を閉じたくないときははずしたほうがいいです。
* ふぁぼる: ふぁぼります。学習を無効にしてふぁぼることもできます。放置したいときはこれ。
* アクセラレータ: ふぁぼを加速します。整数値でふぁぼへの熱意を指定してください。tomykaira は 5000 ぐらいにしてます。調整がむずかしいです。
* ふぁぼらないユーザ: ふぁぼんなとかいわれたらここに入れてあげましょう。自分を fav ってさみしくならないためにもだいじです。

ノーチューンだとあまりにふぁぼらなかったので、むしゃくしゃしてアクセラレータを追加しました。
統計的にデタラメなことをやってるのでもっといいロジックがあればおしえてください。

How To Use
----------

* 有効にします
* TLをよくみます
* ふぁぼります
* そのうち自然に★がついてきます

Thanks
------
* @katsyoshi さん : fav.rb の開発者で、fav_bayes 開発のお声をかけていただきました。
