require 'colorize'

module Gantree
  class Docker < Base

    def initialize options
      check_credentials
      set_aws_keys
      @options = options
      @hub = @options[:hub]
      raise "Please provide a hub name in your .gantreecfg ex { hub : 'bleacher' }" unless @hub
      @origin = `git remote show origin | grep "Push" | cut -f1 -d"/" | cut -d":" -f3`.strip
      @repo = `basename $(git rev-parse --show-toplevel)`.strip
      @branch = `git rev-parse --abbrev-ref HEAD`.strip
      @hash = `git rev-parse --verify --short #{@branch}`.strip
    end

    def build 
      puts "Building..."
      output = `docker build -t #{@hub}/#{@repo}:#{@origin}-#{@branch}-#{@hash} .`
      if $?.success?
        puts "Image Built: #{@hub}/#{@repo}:#{tag}".green 
        puts "docker push #{@hub}/#{@repo}:#{tag}"
        puts "gantree deploy app_name -t #{tag}"
      else
        puts "Error: Image was not built successfully".red
        puts "#{output}"
      end
    end

    def push 
      puts "Pushing..."
      output = `docker push #{@hub}/#{@repo}:#{tag}`
      if $?.success?
        puts "Image Pushed: #{@hub}/#{@repo}:#{tag}".green 
        puts "gantree deploy app_name -t #{tag}"
      else
        puts "Error: Image was not pushed successfully".red
        puts "#{output}"
      end
    end

    def tag
      "#{@origin}-#{@branch}-#{@hash}"
    end
  end
end
