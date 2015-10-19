require 'spec_helper'
require 'cc/engine/analyzers/javascript/main'
require 'cc/engine/analyzers/reporter'
require 'cc/engine/analyzers/engine_config'
require 'flay'
require 'tmpdir'

module CC::Engine::Analyzers::Javascript
  describe Main do
    before { @code = Dir.mktmpdir }

    describe "#run" do
      it "prints an issue" do

        create_source_file("foo.js", <<-EOJS)
          console.log("hello JS!");
          console.log("hello JS!");
          console.log("hello JS!");
        EOJS

        assert_equal run_engine(engine_conf), printed_issue
      end

      def create_source_file(path, content)
        File.write(File.join(@code, path), content)
      end

      def run_engine(config = nil)
        io = StringIO.new

        engine = ::CC::Engine::Analyzers::Javascript::Main.new(directory: @code, engine_config: config)
        reporter = ::CC::Engine::Analyzers::Reporter.new(@code, engine, io)

        reporter.run

        io.string
      end

      def printed_issue
        issue = {"type":"issue","check_name":"Identical code","description":"Duplication found in ExpressionStatement","categories":["Duplication"],"location":{"path":"foo.js","lines":{"begin":1,"end":1}},"remediation_points":378000, "other_locations":[{"path":"foo.js","lines":{"begin":2,"end":2}},{"path":"foo.js","lines":{"begin":3,"end":3}}], "content":{"body": read_up}}
        issue.to_json + "\0\n"
      end

      def engine_conf
        CC::Engine::Analyzers::EngineConfig.new({
          'config' => {
            'languages' => {
                'javascript' => {
                  'mass_threshold' => 1
                }
            }
          }
        })
      end
    end
  end
end