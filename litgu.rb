#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "optparse"
require "nokogiri"
require "open-uri"
require "date"

def pad(n)
  n.to_s.rjust(2, "0")
end

def hun_date(year, month, day)
  month_names = [
    "január",
    "február",
    "március",
    "április",
    "május",
    "június",
    "július",
    "augusztus",
    "szeptember",
    "október",
    "november",
    "december"
  ]

  "#{year}. #{month_names[month-1]} #{day}."
end

today = Date.today
year = today.year
month = today.month

OptionParser.new do |options|
  options.on("-m MM", "--month MM", "Generate guide for the given month") do |m|
    month = m.to_i
    puts month
  end
end.parse!

days = Date.new(year, month, -1).day


title = "Igeliturgikus Útmutató - #{year}. #{pad(month)}"
puts "<html><head><title>#{title}</title><meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"></head><body>"
puts "<h1>#{title}</h1>"

puts "<h2>Tartalom</h2>"
puts "<ul>"
(1..days).each do |day|
  date_desc = "#{year}-#{pad(month)}-#{pad(day)}"

  puts "<li><a href=\"\##{date_desc}\">#{hun_date(year, month, day)}</a></li>"
end
puts "</ul>"

(1..days).each do |day|
  date_desc = "#{year}-#{pad(month)}-#{pad(day)}"

  page = Nokogiri::HTML(open("http://igenaptar.katolikus.hu/nap/index2016.php?holnap=#{date_desc}"))
  page_content = page.css("body").children

  page_title = page_content[1]
  page_title.name = "h1"
  page_title["id"] = date_desc
  page_title.content = hun_date(year, month, day)
  
  rulers = page_content.css("hr")
  rulers.each { |hr| page_content.delete(hr) }

  puts page_content.to_html
end

puts "</body></html>"
