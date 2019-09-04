require "erb"

# @ripienaar https://www.devco.net/archives/2010/11/18/a_few_rake_tips.php
def render_template(template, output, scope)
  tmpl = File.read(template)
  erb = ERB.new(tmpl, 0, "<>")
  File.open(output, "w") do |f|
    f.puts erb.result(scope)
  end
end

maintainer = 'jesse_weisner@bcit.ca, Juraj Ontkanin'
org_name = 'bcit'
image_name = 'openshift-postfix'
version = '3.4.4'
version_segments = version.split('.')
tags = [
  "#{version_segments[0]}.#{version_segments[1]}",
  'latest'
]

desc "Template, build, tag, push"
task :default do
  Rake::Task[:Dockerfile].invoke
  Rake::Task[:build].invoke
  Rake::Task[:test].invoke
  Rake::Task[:tag].invoke
end

desc "Update Dockerfile templates"
task :Dockerfile do
  render_template("Dockerfile.erb", "Dockerfile", binding)
end

desc "Build docker images"
task :build do
  sh "docker build -t #{org_name}/#{image_name}:#{version} . --no-cache --pull"
end

desc "Test docker images"
task :test do
  puts "Running tests on #{org_name}/#{image_name}:#{version}"
  puts "lol"
end

desc "Tag docker images"
task :tag do
  tags.each do |tag|
    sh "docker tag #{org_name}/#{image_name}:#{version} #{org_name}/#{image_name}:#{tag}"
  end
end

desc "Push to Docker Hub"
task :push do
  sh "docker push #{org_name}/#{image_name}:#{version}"

  tags.each do |tag|
    sh "docker push #{org_name}/#{image_name}:#{tag}"
  end
end
