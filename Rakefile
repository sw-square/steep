require "bundler/gem_tasks"
require "rake/testtask"

if ENV["VSCODE_CWD"]
  require "minitest"
  Minitest.seed = Time.now.to_i
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :test do
  desc "Run output test"
  task :output do
    sh "ruby", "bin/output_test.rb"
  end
end

Rake::Task[:release].enhance do
  Rake::Task[:"release:note"].invoke
  Rake::Task[:"release:github"].invoke
end

namespace :release do
  desc "Ensure release note"
  task :note do
    version = Gem::Version.new(Steep::VERSION)
    major, minor, patch, pre = Steep::VERSION.split(".", 4)
    major = major.to_i
    minor = minor.to_i
    patch = patch.to_i

    wiki_url = "https://github.com/soutaro/steep/wiki/Release-Note-#{major}.#{minor}"

    puts "🧐 Checking if Release note page already exists..."

    unless `curl --silent -o/dev/null --head #{wiki_url} -w '%{http_code}'` == "200"
      pre_flag = version.prerelease? ? " --pre" : ""
      pre_requirement = version.prerelease? ? ", '~> #{major}.#{minor}.#{patch}.#{pre}'" : ""

      puts "----"

      puts <<~PREFIX if patch
        **The latest version of Steep #{major}.#{minor} is `#{pre}`.**

      PREFIX

      puts <<~TEMPLATE
        Some of the highlights in Steep #{major}.#{minor} are:

        * New feature 1 (URL)
        * New feature 2 (URL)
        * New feature 3 (URL)

        You can install it with `$ gem install steep#{pre_flag}` or using Bundler.

        ```rb
        gem 'steep', require: false#{pre_requirement}
        ```

        See the [CHANGELOG](https://github.com/soutaro/steep/blob/master/CHANGELOG.md) for the details.

        ## New feature 1

        ## New feature 2

        ## New feature 3

        ## Diagnostics updates

        ## Updating Steep

      TEMPLATE
      puts "----"
      puts

      puts "  ⏩️ Create the release note with the template: #{wiki_url}"
    else
      if patch == 0 || version.prerelease?
        puts "  ⏩️ Open the release note and update it at: #{wiki_url}"
      else
        puts "  ✅ Release note is ready!"
      end
    end
    puts
  end

  desc "Create GitHub release automatically"
  task :github do
    version = Gem::Version.new(Steep::VERSION)
    major, minor, patch, *_ = Steep::VERSION.split(".")
    major = major.to_i
    minor = minor.to_i
    patch = patch.to_i

    puts "✏️ Making a draft release on GitHub..."

    content = File.read(File.join(__dir__, "CHANGELOG.md"))
    changelog = content.scan(/^## \d.*?(?=^## \d)/m)[0]
    changelog = changelog.sub(/^.*\n^.*\n/, "").rstrip

    notes = <<NOTES
[Release note](https://github.com/soutaro/steep/wiki/Release-Note-#{major}.#{minor})

#{changelog}
NOTES

    command = [
      "gh",
      "release",
      "create",
      "--draft",
      "v#{Steep::VERSION}",
      "--title=#{Steep::VERSION}",
      "--notes=#{notes}"
    ]

    if version.prerelease?
      command << "--prerelease"
    end

    require "open3"
    output, status = Open3.capture2(*command)
    if status.success?
      puts "  ⏩️ Done! Open #{output.chomp} and publish the release!"
      puts
    end
  end
end
