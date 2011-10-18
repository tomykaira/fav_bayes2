# -*- coding: utf-8 -*-

require 'rubygems'
require 'MeCab'

miquire :core, 'utils'
miquire :core, 'plugin'

class MeCab::Tagger
  require 'kconv'

  def node_filter (node)
    features = node.feature.toutf8.split(',')
    case features[0]
    when "助動詞", "助詞", "記号", "連体詞", "副詞", "フィラー", "接続詞", "接頭詞"
      return nil
    end

    case features[1]
    when "非自立", "代名詞", "接尾", "数", "数詞"
      return nil
    end

    word = features[4] != '*' ? features[4] : node.surface.toutf8
    case word
    when "れる", "する", "ある", "なる", "いい", "できる", "思う", "RT", "QT", "ー", "～", "w", "^！", "♪", "こと", "ない", "いう"
      return nil
    when /[[:punct:]]/
      return nil
    end

    word
  end

  def to_words(text)
    words = []

    # 前処理
    text.gsub!(/https?:[[:alnum:].\/]*/ix, '')
    text.gsub!(/(#[^ ,.、。()]*)/i) { |m| words.push m ; '' }
    text.gsub!(/(@[[:alnum:]_]*)/i) { |m| words.push m ; '' }

    if text.length < 5
      return []
    end

    node = parseToNode(text.toeuc)
    while node
      words << node_filter(node)
      node = node.next
    end

    p words.compact.find_all{ |x| !x.empty? }
  end
end

Plugin.create(:fav_bayes2) do
  def load
    File.open(CACHE_FILE) { |f| Marshal.load(f) }
  rescue
    {
      :count => { :unfav => 0, :fav => 0 },
      :words => { :unfav => {},:fav => {}},
      :wc    => { :unfav => 0, :fav => 0 },
      :vocab => 0,
      :ids   => { :unfav => [], :fav => [] }
    }
  end

  def dump
    File.open(CACHE_FILE, 'wb') { |f| Marshal.dump(@cache, f) }
  end

  def register(message, fav = false)
    if fav
      to = :fav
      from = :unfav
    else
      to = :unfav
      from = :fav
    end

    p message.to_s

    words = @mecab.to_words(message[:message].dup)

    # リスト更新
    in_other = false
    if @cache[:ids][from].include?(message[:id_str])
      in_other = true
      @cache[:ids][from].delete(message[:id_str])
    end

    @cache[:ids][to] << message[:id_str]
    @cache[:count][to] += 1
    @cache[:count][from] -= 1 if in_other
    words.each do |w|
      if in_other && @cache[:words][from].has_key?(w) && @cache[:words][from][w] > 0
        @cache[:words][from][w] -= 1
      end
      if @cache[:words][to].has_key?(w) && @cache[:words][to][w] > 0
        @cache[:words][to][w] += 1
      else
        @cache[:words][to][w] = 1
        @cache[:vocab] += 1
      end
    end
    @cache[:wc][to]   += words.size
    @cache[:wc][from] -= words.size if in_other

    printf "%d / %d\t%d / %d\n", @cache[:count][:fav], @cache[:count][:unfav], @cache[:wc][:fav], @cache[:wc][:unfav]

    dump

    return words
  end

  def get_original_message_from(message)
    message[:retweet] || message
  end

  def calc(words, type)
    p0 = Math.log(@cache[:count][type] / (@cache[:count][:unfav] + @cache[:count][:fav]).to_f)
    p1 = words.map{|w| Math.log(@cache[:words][type].has_key?(w) ? @cache[:words][type][w] + 1 : 1) }.inject(:+)
    p2 = words.size * Math.log(@cache[:wc][type] + @cache[:vocab])
    p p0 + p1, p2
    return p0 + p1 - p2
  end

  # initialization
  @mecab = ::MeCab::Tagger.new
  CACHE_FILE = File.expand_path(Environment::CONFROOT + "fav_bayes2.dat")
  @cache = load

  # callbacks
  onfavorite do |service, user, message|
    # 自分か?, 一回目か?(id_str based)
    message = get_original_message_from(message)
    register(message, true) if user.is_me?(service) && !@cache[:ids][:fav].include?(message[:id_str])
  end

  onunfavorite do |service, user, message|
    message = get_original_message_from(message)
    register(message, false) if user.is_me?(service) && !@cache[:ids][:unfav].include?(message[:id_str])
  end

  onupdate do |service, messages|
    messages.each do |m|
      m = get_original_message_from(m)
      next if @cache[:ids][:fav].include?(m[:id_str]) || @cache[:ids][:unfav].include?(m[:id_str])

      words = register(m, m[:favorited])

      next if !words || words.empty?
      fav_score = calc(words, :fav)
      unfav_score = calc(words, :unfav)

      p fav_score, unfav_score, fav_score/unfav_score
      m.favorite(true) if fav_score > unfav_score
    end
  end
end