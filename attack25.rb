require 'open-uri'
require 'nokogiri'
require 'byebug'

output = ""
idx = 0

def roop_until_yomiage(idx, doc)
  roop_count = idx
  while roop_count < 1000 do
    text = doc.xpath("//*[@id=\"wikibody\"]/div[#{roop_count}]").text
    roop_count += 1
      
    if text.include?("読み上げ問題")
      return roop_count
    end
  end

  # 「読み上げ問題」がbodyに含まれない場合は1000を返してwhileを抜ける
  return 1000
end

def roop_until_seikai(idx, doc)
  roop_count = idx
  while roop_count < 1000 do
    text = doc.xpath("//*[@id=\"wikibody\"]/div[#{roop_count}]").text
    roop_count += 1
      
    if text.include?("正解：")
      return roop_count
    end
  end

  return 1000
end

for page_idx in 339..384 do
  idx = 0
  puts "extracting file_#{page_idx}..."

  doc = Nokogiri::HTML(URI.open("https://w.atwiki.jp/cdtvcdtv/pages/#{page_idx}.html"))
  idx = roop_until_yomiage(idx, doc)

  while idx < 1000 do
    div_path = doc.xpath("//*[@id=\"wikibody\"]/div[#{idx}]")
    text = div_path.text
    idx += 1

    if text.include?("映像クイズ")
      break
    elsif text.include?("アタックチャンス")
      next
    elsif text.include?("まずはこちら") || text.include?("こちらをご覧ください") || text.include?("こちらをお聴きください")
      idx = roop_until_seikai(idx, doc)
      next
    end
    
    if div_path.xpath("span")&.children&.to_s&.include?("@@@")
      idx = roop_until_yomiage(idx, doc)
    elsif text.include?("正解：")
      output += text.gsub("\n", "").split("：")[1]
      output += "\n"
    else
      output += text.gsub("\n", "")
      output += "\t"
    end
  end

  File.open("quiz.txt", mode = "w"){|f|
    f.write(output)
  }
end