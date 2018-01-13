#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "optparse"
require "nokogiri"
require "open-uri"
require "time"
require "gepub"
require "tmpdir"

def pad(n)
  n.to_s.rjust(2, "0")
end

$hun_month_names = [
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

def to_hun_date(year, month, day)
  "#{year}. #{$hun_month_names[month-1]} #{day}."
end

def to_date_desc(year, month, day)
  "#{year}-#{pad(month)}-#{pad(day)}"
end

today = Time.now
year = today.year
month = today.month
generate_for_kindle = false

OptionParser.new do |options|
  options.on("-y YYYY", "--year YYYY", "Specify the year for which to generate") do |y|
    year = y.to_i
  end

  options.on("-m MM", "--month MM", "Generate guide for the given month") do |m|
    month = m.to_i
  end

  options.on("-k", "--kindle", "Generate MOBI format for Amazon Kindle") do
    generate_for_kindle = true
  end
end.parse!

days = Date.new(year, month, -1).day

guide_url_tmpl = "http://igenaptar.katolikus.hu/nap/index.php?holnap=%{date_desc}"

epub_file = File.join File.dirname(__FILE__), "#{year}-#{pad(month)}.epub"

Dir.mktmpdir do |work_dir|
  # Download and prepare each day of the month as a chapter
  (1..days).each do |day|
    date_desc = to_date_desc(year, month, day)

    url = guide_url_tmpl % {:date_desc => date_desc}
    puts "Fetching #{url} ..."
    page = Nokogiri::HTML(open(url))
    page_content = page.css("body").children

    page_title = page_content[1]
    page_title.name = "h1"
    page_title["id"] = date_desc
    page_title.content = to_hun_date(year, month, day)

    rulers = page_content.css("hr")
    rulers.each { |hr| page_content.delete(hr) }

    out_file = File.join(work_dir, "#{date_desc}.html")
    puts "Writing #{out_file} ..."
    File.write out_file, page.to_html
  end

  # Generate EPUB file from chapters
  epub_blr = GEPUB::Builder.new do
    language "hu"
    title "Igeliturgikus Útmutató - #{year}. #{$hun_month_names[month]}"
    creator "Szabadkai Márk"
    unique_identifier guide_url_tmpl % {:date_desc => to_date_desc(year, month, 1)}, "url"
    date today

    resources(:workdir => work_dir) do
      ordered do
        (1..days).each do |day|
          file "#{to_date_desc(year, month, day)}.html"
          heading to_hun_date(year, month, day)
        end
      end
    end
  end

  puts "Generating #{epub_file} ..."
  epub_blr.generate_epub epub_file
end


if generate_for_kindle
  puts "Starting MOBIL file generator..."
  exec "./kindlegen #{epub_file}"
end
