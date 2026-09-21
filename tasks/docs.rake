# frozen_string_literal: true

namespace :docs do
  # The API reference in the READMEs is a list of every public method. It was
  # hand-maintained once and drifted: it described ten of seventeen resources
  # while the guide above it described all of them, so the file carried two
  # inventories and one of them lied. This compares it against the source.
  desc "Check the API reference in both READMEs against the code"
  task :check do
    code = Yandex360Docs.signatures_from_code
    problems = []

    Yandex360Docs::READMES.each do |readme|
      documented = Yandex360Docs.signatures_from_readme(readme)

      missing = (code - documented).sort
      extra   = (documented - code).sort

      missing.each {|sig| problems << "#{readme}: #{sig} exists in the code but is not documented" }
      extra.each   {|sig| problems << "#{readme}: #{sig} is documented but does not exist" }
    end

    if problems.empty?
      puts "API reference matches the code: #{code.size} methods."
    else
      problems.each {|problem| warn problem }
      abort "The API reference and the code disagree."
    end
  end
end

# Kept out of the task body so it can be required and tested.
module Yandex360Docs
  READMES = %w[README.md README.ru.md].freeze
  ROOT = File.expand_path("..", __dir__)

  class << self
    # accessor name => resource class, as the client exposes them.
    def accessors
      client = read(File.join(ROOT, "lib/yandex360/client.rb"))
      client.scan(/^    def (\w+)\n      (\w+)\.new\(self\)/).to_h
    end

    def signatures_from_code
      signatures = accessors.flat_map do |accessor, klass|
        public_methods_of(klass).map {|signature| "#{accessor}.#{signature}" }
      end
      signatures.to_set
    end

    def signatures_from_readme(path)
      text = read(File.join(ROOT, path))
      heading = text[/^## (?:API Reference|Справочник API)$.*/m]
      abort "#{path}: no API reference section" if heading.nil?

      body = heading[/```ruby\n(.*?)```/m, 1].to_s
      documented = body.lines.filter_map do |line|
        line = line.split("#").first.to_s.strip
        line if line.match?(/\A\w+\.[\w?]/)
      end
      documented.to_set
    end

    private

    def public_methods_of(klass)
      source = resource_source(klass)
      signatures = []
      source.each_line do |line|
        break if line.match?(/^\s+private\s*$/)

        match = line.match(/^    def ([\w?]+)(\(.*\))?/)
        signatures << "#{match[1]}#{match[2]}" if match
      end
      # Constants are spelled out in the docs, where a reader cannot resolve them.
      signatures.map {|signature| signature.gsub("MAX_PAGE_SIZE", "100") }
    end

    def resource_source(klass)
      Dir[File.join(ROOT, "lib/yandex360/resources/*.rb")].each do |path|
        source = read(path)
        return source if source.match?(/class #{Regexp.escape(klass)}\b/)
      end
      abort "No resource file defines #{klass}"
    end

    def read(path)
      File.read(path, encoding: "UTF-8").gsub("\r\n", "\n")
    end
  end
end
