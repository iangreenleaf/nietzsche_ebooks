require 'open-uri'
require_relative './config/sources.rb'

task :fetch do
  SOURCES.each do |work|
    headers = work[:headers]
    footers = work[:footers]
    open(work[:url]) do |f|
      out_fn = File.join ".", "texts", "converted", "#{work[:title]}.txt"
      File.open(out_fn, "w") do |out|
        f.each_line do |line|
          if headers.first && line.chomp =~ headers.first
            headers.shift
          end
          if headers.empty?
            if footers.first && line.chomp =~ footers.first
              footers.shift
              break if footers.empty?
            end
            line.gsub!(/--+/, "—")
            line.gsub!(/\.\.\./, "…")
            out << line
          end
        end
      end
    end
  end
end
