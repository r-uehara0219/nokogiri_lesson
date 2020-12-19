require 'open-uri'
require 'nokogiri'

output = ""
href_array = Array.new(5) { Array.new }

for theme_num in 1..13 do
  doc = Nokogiri::HTML(URI.open("https://ameblo.jp/nobu0388/theme#{theme_num}-10037386706.html"))
  doc = Nokogiri::HTML(URI.open("https://ameblo.jp/nobu0388/theme-10037386706.html")) if theme_num == 1
  for div_num in 1..20 do
    link = doc.xpath("//*[@id=\"main\"]/div/article/div/div/ul/li[#{div_num}]/div[1]/h1/a")[0]
    year = link.text.split("/")[0].to_i
    link_url = "https://ameblo.jp" + link[:href].gsub(/\?frm=theme/, "")
    next if year < 2016
    href_array[year-2016].push(link_url)
  end
end

href_array.each_with_index do |array, array_idx|
  array.each_with_index do |url, idx|
    puts "extracting #{array_idx + 2016}_#{idx}..."
    doc = Nokogiri::HTML(URI.open(url))

    text_buffer = doc.xpath("//*[@id=\"main\"]/div/article/div/div/div/div[2]").inner_html

    p "occurring error in #{array_idx + 2016}_#{idx}" unless text_buffer.include?("問題：")

    text_buffer.gsub!(/<\/p>/, "<br>")
    text_buffer.gsub!(/<p>/, "<br>")
    splited_text = text_buffer.split("<br>")
    yomiage_flug = false
    splited_text.each do |text|
      next unless yomiage_flug || text.include?("正解：")

      if !yomiage_flug && text.include?("正解：")
        yomiage_flug = true
        next
      end

      if /.*\[.+\].*/.match(text)
        yomiage_flug = false unless text.include?("アタックチャンス")
        next
      end

      if text.include?("問題：")
        output += text.gsub(/問題：/, "").gsub(/\n/, "")
        output += "\t"
      elsif text.include?("正解：")
        output += text.gsub(/正解：/, "").gsub(/\n/, "")
        output += "\n"
      end
    end
  end
  output += "\n\n\n"
end

File.open("quiz.txt", mode = "w"){|f|
  f.write(output)
}