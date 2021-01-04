# 556回より後がhref_arrayで取れなくなっている
# encoding error : input conversion failed due to input error, bytes 0xAD 0xA2 0xA1 0xCA

# todo:原因調査

require 'open-uri'
require 'nokogiri'

output = ""
href_array = []

def roop_until_seikai(idx, doc)
  roop_count = idx
  while roop_count < 1000 do
    text = doc.xpath("//*[@id=\"page-body-inner\"]/div[1]/text()[#{roop_count}]").text
    roop_count += 1
      
    if text.include?("正解：")
      return roop_count
    end
  end

  puts "reach 1000 limited"

  return 1000
end

def roop_until_question(idx, doc)
  roop_count = idx
  while roop_count < 1000 do
    text = doc.xpath("//*[@id=\"page-body-inner\"]/div[1]/text()[#{roop_count+1}]").text
    roop_count += 1

    # byebug
      
    if text.start_with?(/|\t|\r|\f| /)
      return roop_count
    end
  end

  puts "reach 1000 limited"

  return 1000
end

doc = Nokogiri::HTML(URI.open("https://seesaawiki.jp/saturdayuattack25/d/%b2%e1%b5%ee%a4%ce%bd%d0%c2%ea%cc%e4%c2%ea"))
for div_num in 580..670 do
  link = doc.xpath("//*[@id=\"page-body-inner\"]/div[1]/a[#{div_num}]")[0]
  next if link == nil
  href_array.push(link[:href])
end

puts "href completed"

href_array.each_with_index do |url, array_idx|
  puts "extracting #{array_idx+1}..."
  doc = Nokogiri::HTML(URI.open(url))

  idx = 1

  while idx < 200 do
    div_path = doc.xpath("//*[@id=\"page-body-inner\"]/div[1]/text()[#{idx}]")
    text = div_path.text

    # 冒頭にtabが入らないよう1から始める
    idx += 1

    if text.include?("フィルムクイズ")
      break
    elsif text.include?("※")
      idx = roop_until_question(idx, doc)
      next
    elsif text.include?("オープニングクイズ") || text.include?("画像問題") || text.include?("アナグラムの問題") || text.include?("漢字クイズ") || text.include?("漢字問題") || text.include?("3択の問題") || text.include?("2択の問題") || text.include?("4択の問題") || text.include?("5ヒント問題") || text.include?("第1ヒント") || text.include?("ひらめきクイズ") || text.include?("ファイブクイズ")
      idx = roop_until_seikai(idx, doc)
      next
    end
    
    if text.include?("正解：")
      output += "\t" unless output == ""
      output += text.gsub("\n", "").split("：")[1].gsub("「","『").gsub("」","』")
      output += "\n"
    else
      output += text.gsub("\n", "")
      output += "\t" unless output != ""
    end
  end
end

File.open("quiz.txt", mode = "w"){|f|
  f.write(output)
}