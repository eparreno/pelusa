module Pelusa
  class Runner
    # Public: Initializes an Analyzer.
    #
    # lints    - The lints to check the code for.
    # reporter - The Reporter to use. Will be used to report back the results in
    #            methods such as #run.
    def initialize(lints, reporter)
      @lints    = lints
      @reporter = reporter
    end

    # Public: Runs the analyzer on a set of files.
    #
    # Returns an Array of Reports of those file runs.
    def run(files)
      reporters = Array(files).map do |file|
        run_file(file)
      end
      @reporter.print_banner

      exit_code = 0

      reporters.each do |reporter|
        reporter.report
        exit_code = 1 unless reporter.successful?
      end
      exit_code
    end

    # Public: Runs the analyzer on a single file.
    #
    # Returns a Report of the single run.
    def run_file(file)
      ast      = parser.parse_file(file)
      analyzer = Analyzer.new(@lints, @reporter, file)
      analyzer.analyze(ast)
    end

    #######
    private
    #######

    # Internal: Returns the parser used to analyze the files, depending on the
    # current Rubinius mode.
    #
    # Returns a Rubinius::Melbourne parser.
    def parser
      return Rubinius::Melbourne19 if ENV['RBXOPT'].include?("-X19")
      Rubinius::Melbourne
    end
  end
end
