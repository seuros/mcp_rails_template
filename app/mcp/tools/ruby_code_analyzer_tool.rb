# frozen_string_literal: true

# Tool for accessing Ruby LSP's indexed classes, modules, and methods
# Simple Ruby Code Analyzer Tool for MCP
class RubyCodeAnalyzerTool < ApplicationMCPTool
  description "Analyze Ruby code structure without relying on Ruby LSP indexing"

  property :query_type, type: "string",
           description: "Type of query: 'classes', 'modules', 'methods', 'constant', or 'method_details'",
           required: true

  property :name, type: "string",
           description: "Name of the class/module/method to query (required for 'constant' and 'method_details')",
           required: false

  property :include_private, type: "boolean",
           description: "Whether to include private methods in results",
           required: false,
           default: false

  validates :query_type, inclusion: { in: %w[classes modules methods constant method_details] }
  validates :name, presence: true, if: -> { %w[constant method_details].include?(query_type) }

  def perform
    # Create a simple indexer
    indexer = SimpleRubyIndexer.new(Dir.pwd)

    case query_type
    when "classes"
      render_classes(indexer)
    when "modules"
      render_modules(indexer)
    when "methods"
      render_methods(indexer)
    when "constant"
      render_constant_details(indexer, name)
    when "method_details"
      class_name, method_name = parse_method_name(name)
      render_method_details(indexer, class_name, method_name)
    else
      render(text: "Invalid query type, must be 'classes', 'modules', 'methods', 'constant', or 'method_details'")
    end
  rescue => e
    render(text: "Error analyzing code: #{e.message}")
  end

  private

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

  def render_classes(indexer)
    classes = indexer.all_classes

    if classes.empty?
      render(text: "No classes found in the project.")
      return
    end

    render(text: "# Classes in Project\n\n")

    classes_by_namespace = classes.group_by do |klass|
      parts = klass[:name].split("::")
      if parts.size > 1
        parts[0...-1].join("::")
      else
        "Global Namespace"
      end
    end

    classes_by_namespace.sort.each do |namespace, classes|
      render(text: "## #{namespace}\n\n")

      classes.sort_by { |c| c[:name] }.each do |klass|
        class_name = klass[:name].split("::").last
        superclass = klass[:superclass] ? " < #{klass[:superclass]}" : ""
        location = "#{klass[:file]}:#{klass[:line]}"

        render(text: "- **#{class_name}**#{superclass} (#{location})")
      end

      render(text: "\n")
    end
  end

  def render_modules(indexer)
    modules = indexer.all_modules

    if modules.empty?
      render(text: "No modules found in the project.")
      return
    end

    render(text: "# Modules in Project\n\n")

    modules_by_namespace = modules.group_by do |mod|
      parts = mod[:name].split("::")
      if parts.size > 1
        parts[0...-1].join("::")
      else
        "Global Namespace"
      end
    end

    modules_by_namespace.sort.each do |namespace, modules|
      render(text: "## #{namespace}\n\n")

      modules.sort_by { |m| m[:name] }.each do |mod|
        module_name = mod[:name].split("::").last
        location = "#{mod[:file]}:#{mod[:line]}"

        render(text: "- **#{module_name}** (#{location})")
      end

      render(text: "\n")
    end
  end

  def render_methods(indexer)
    methods = indexer.all_methods

    if methods.empty?
      render(text: "No methods found in the project.")
      return
    end

    render(text: "# Methods in Project\n\n")

    methods_by_class = methods.group_by { |m| m[:container] }

    methods_by_class.sort_by { |container, _| container }.each do |container, methods|
      render(text: "## #{container}\n\n")

      # Filter private methods if needed
      methods_to_show = methods
      unless include_private
        methods_to_show = methods.reject { |m| m[:visibility] != "public" }
      end

      methods_to_show.sort_by { |m| m[:name] }.each do |method|
        location = "#{method[:file]}:#{method[:line]}"
        params = method[:parameters].empty? ? "()" : "(#{method[:parameters].join(', ')})"
        visibility = method[:visibility] != "public" ? " [#{method[:visibility]}]" : ""

        render(text: "- **#{method[:name]}**#{params}#{visibility} (#{location})")
      end

      render(text: "\n")
    end
  end

  def render_constant_details(indexer, const_name)
    constant = indexer.find_constant(const_name)

    unless constant
      render(text: "Constant '#{const_name}' not found in the index.")
      return
    end

    render(text: "# #{constant[:name]}\n\n")

    # Basic details
    render(text: "- **Type:** #{constant[:type].to_s.capitalize}")
    render(text: "- **Location:** #{constant[:file]}:#{constant[:line]}")

    if constant[:type] == :class && constant[:superclass]
      render(text: "- **Superclass:** #{constant[:superclass]}")
    end

    # Methods defined in this constant
    methods = indexer.methods_for(constant[:name])

    if methods.any?
      render(text: "\n## Methods\n\n")

      # Group by visibility
      methods_by_visibility = methods.group_by { |m| m[:visibility] }

      # Public methods
      if methods_by_visibility["public"]&.any?
        render(text: "### Public Methods\n\n")

        methods_by_visibility["public"].sort_by { |m| m[:name] }.each do |method|
          location = "#{method[:file]}:#{method[:line]}"
          params = method[:parameters].empty? ? "()" : "(#{method[:parameters].join(', ')})"

          render(text: "- **#{method[:name]}**#{params} (#{location})")
        end

        render(text: "\n")
      end

      # Private methods
      if include_private && methods_by_visibility["private"]&.any?
        render(text: "### Private Methods\n\n")

        methods_by_visibility["private"].sort_by { |m| m[:name] }.each do |method|
          location = "#{method[:file]}:#{method[:line]}"
          params = method[:parameters].empty? ? "()" : "(#{method[:parameters].join(', ')})"

          render(text: "- **#{method[:name]}**#{params} (#{location})")
        end

        render(text: "\n")
      end

      # Protected methods
      if include_private && methods_by_visibility["protected"]&.any?
        render(text: "### Protected Methods\n\n")

        methods_by_visibility["protected"].sort_by { |m| m[:name] }.each do |method|
          location = "#{method[:file]}:#{method[:line]}"
          params = method[:parameters].empty? ? "()" : "(#{method[:parameters].join(', ')})"

          render(text: "- **#{method[:name]}**#{params} (#{location})")
        end
      end
    else
      render(text: "\nNo methods found for this constant.")
    end

    # Show source if available
    source = fetch_source(constant[:file], constant[:line])
    if source
      render(text: "\n## Source\n\n```ruby\n#{source}\n```")
    end
  end

  def render_method_details(indexer, class_name, method_name)
    constant = indexer.find_constant(class_name)

    unless constant
      render(text: "Class/Module '#{class_name}' not found in the index.")
      return
    end

    methods = indexer.methods_for(constant[:name])
    method = methods.find { |m| m[:name] == method_name }

    unless method
      render(text: "Method '#{method_name}' not found in '#{class_name}'.")
      return
    end

    render(text: "# #{class_name}##{method_name}\n\n")

    # Basic details
    render(text: "- **Location:** #{method[:file]}:#{method[:line]}")
    render(text: "- **Visibility:** #{method[:visibility]}")

    params_str = method[:parameters].empty? ? "None" : method[:parameters].join(", ")
    render(text: "- **Parameters:** #{params_str}")

    # Show source if available
    source = fetch_source(method[:file], method[:line])
    if source
      render(text: "\n## Source\n\n```ruby\n#{source}\n```")
    end
  end

  def fetch_source(file, line)
    full_path = File.join(Dir.pwd, file)

    return nil unless File.exist?(full_path)

    begin
      lines = File.readlines(full_path)
      start_line = line - 1

      # Try to find the end of the definition (simplified)
      end_line = start_line
      nesting_level = 0
      lines[start_line..-1].each_with_index do |line, i|
        nesting_level += 1 if line =~ /\b(def|class|module|do|if|unless|case)\b/
        nesting_level -= 1 if line =~ /\bend\b/

        end_line = start_line + i
        break if nesting_level <= 0 && i > 0
      end

      lines[start_line..end_line].join
    rescue => e
      render(text: "# Error fetching source: #{e.message}" )
    end
  end

  def parse_method_name(full_name)
    if full_name.include?("#")
      # Instance method format: Class#method
      full_name.split("#", 2)
    elsif full_name.include?(".")
      # Class method format: Class.method
      full_name.split(".", 2)
    else
      # Try to find the last :: separator for a constant
      parts = full_name.split("::")
      if parts.size > 1
        [ parts[0..-2].join("::"), parts[-1] ]
      else
        [ nil, full_name ]
      end
    end
  end
end
