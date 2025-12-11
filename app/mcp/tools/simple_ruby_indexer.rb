# frozen_string_literal: true

# Simple Ruby indexer that doesn't depend on Ruby LSP
class SimpleRubyIndexer
  attr_reader :classes, :modules, :methods, :private_methods, :project_root

  def initialize(root_dir)
    @project_root = root_dir
    @classes = []
    @modules = []
    @methods = []
    @private_methods = {}
    index_files
  end

  def index_files
    ruby_files = Dir.glob("#{@project_root}/**/*.rb")
    render_progress("Found #{ruby_files.size} Ruby files to index")

    ruby_files.each do |file|
      begin
        index_file(file)
      rescue => e
        puts "Error indexing #{file}: #{e.message}"
      end
    end

    render_progress("Indexing complete: #{@classes.size} classes, #{@modules.size} modules, #{@methods.size} methods")
  end

  def render_progress(message)
    puts message
  end

  def index_file(file)
    content = File.read(file)
    relative_path = file.sub("#{@project_root}/", "")

    # Track the current context (class or module)
    context_stack = []
    current_visibility = "public"

    content.lines.each_with_index do |line, line_num|
      # Skip comments
      next if line.strip.start_with?("#")

      # Check for visibility modifiers
      if line =~ /^\s*(private|protected|public)\b/
        current_visibility = $1
        next
      end

      # Find class definitions
      if line =~ /^\s*class\s+([A-Z][A-Za-z0-9:]*)/
        class_name = $1

        # Handle class inheritance
        superclass = nil
        if line =~ /^\s*class\s+[A-Z][A-Za-z0-9:]*\s*<\s*([A-Z][A-Za-z0-9:]*)/
          superclass = $1
        end

        # Build the full name based on nesting
        if context_stack.any?
          full_name = context_stack.last[:name] + "::" + class_name
        else
          full_name = class_name
        end

        class_info = {
          name: full_name,
          type: :class,
          superclass: superclass,
          file: relative_path,
          line: line_num + 1
        }

        @classes << class_info
        context_stack.push(class_info)

        # Find module definitions
      elsif line =~ /^\s*module\s+([A-Z][A-Za-z0-9:]*)/
        module_name = $1

        # Build the full name based on nesting
        if context_stack.any?
          full_name = context_stack.last[:name] + "::" + module_name
        else
          full_name = module_name
        end

        module_info = {
          name: full_name,
          type: :module,
          file: relative_path,
          line: line_num + 1
        }

        @modules << module_info
        context_stack.push(module_info)

        # Find method definitions
      elsif line =~ /^\s*def\s+([a-zA-Z0-9_?!]+)(\(.*?\))?/
        method_name = $1

        # Extract parameters
        parameters = []
        if $2
          params_str = $2.gsub(/[()]/, "")
          parameters = params_str.split(",").map(&:strip).reject(&:empty?)
        end

        container = context_stack.last&.dig(:name) || "Object"

        method_info = {
          name: method_name,
          container: container,
          visibility: current_visibility,
          parameters: parameters,
          file: relative_path,
          line: line_num + 1
        }

        @methods << method_info

        # Track private methods by container
        if current_visibility != "public"
          @private_methods[container] ||= []
          @private_methods[container] << method_name
        end

        # Check for end of class/module definition
      elsif line =~ /^\s*end\b/
        # Pop from context stack if we're in a class/module
        context_stack.pop if context_stack.any?

        # Reset visibility at the end of a class/module
        current_visibility = "public" if context_stack.empty?
      end
    end
  end

  def all_classes
    @classes
  end

  def all_modules
    @modules
  end

  def all_methods
    @methods
  end

  def find_constant(name)
    @classes.find { |c| c[:name] == name } || @modules.find { |m| m[:name] == name }
  end

  def methods_for(constant_name)
    @methods.select { |m| m[:container] == constant_name }
  end

  def callers_for(method_info)
    # This would require deeper analysis - not implemented in the simple version
    []
  end
end
