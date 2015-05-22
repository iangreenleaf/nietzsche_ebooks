require 'open-uri'
require_relative './config/sources.rb'

task :fetch do
  SOURCES.each do |work|
    headers = work[:headers]
    footers = work[:footers]
    open(work[:url]) do |f|
      f.set_encoding work[:encoding]
      out_fn = File.join ".", "texts", "converted", "#{work[:title]}.txt"
      File.open(out_fn, "w") do |out|
        lines = []
        paragraph = ->{
          out.puts lines.compact.join(" ") unless lines.empty?
        }
        f.each_line do |line|
          line = line.encode Encoding::UTF_8
          if headers.empty?
            if footers.first && line.chomp =~ footers.first
              footers.shift
              if footers.empty?
                paragraph.call
                break
              end
            end

            line.gsub!(/--+/, "—")
            line.gsub!(/\.\.\./, "…")

            if line.chomp =~ /^\s*[A-Z0-9.:—…']*\s*$/
              paragraph.call
              lines = []
            else
              lines << line.chomp.lstrip
            end
          elsif line.chomp =~ headers.first
            headers.shift
          end
        end
        paragraph.call
      end
    end
  end
end
