#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "nokogiri"
require "open-uri"
require "date"

def pad(n)
  n.to_s.rjust(2, "0")
end

today = Date.today
year = today.year
month = today.month
days = Date.new(year, month, -1).day

title = "Igeliturgikus Útmutató - #{year}. #{pad(month)}"
puts "<html><head><title>#{title}</title><meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"></head><body>"
puts "<h1>#{title}</h1>"

(1..days).each do |day|
  date_desc = "#{year}-#{pad(month)}-#{pad(day)}"

  page = Nokogiri::HTML(open("http://igenaptar.katolikus.hu/nap/index2016.php?holnap=#{date_desc}"))
  page_content = page.css("body").children

  page_title = page_content[1]
  page_title.name = "h1"

  rulers = page_content.css("hr")
  rulers.each { |hr| page_content.delete(hr) }

  puts page_content.to_html
end

puts "</body></html>"
