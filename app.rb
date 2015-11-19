require 'timeout'
require File.expand_path(File.dirname(__FILE__) + '/fake_file')
require File.expand_path(File.dirname(__FILE__) + '/string')
require File.expand_path(File.dirname(__FILE__) + '/path_grabber')
KOAN_FILENAMES     = PathGrabber.new.koan_filenames
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")
ARRAY_ORIGINAL     = IO.read("koans/about_arrays.rb").remove_require_lines
CLASSES_ALLOWED    = %w(TriangleError Proxy DiceSet)

def input
  @input = (params[:input] ||= [])
  @input.map do |x|
    match_found = false
    class_clean = x.scan(/class\s+(\w+)/).all?{|z| match_found = true; CLASSES_ALLOWED.include? z.first}
    if class_clean
      if match_found || (def_clean = x.scan(/def\s+(\w+)/).all?{|z| %w(triangle).include? z.first})
        x
      end
    else
      "# not safe :( Use your browser Back button to return"
    end
  end
end
def current_koan_name
  return '' if @end
  claimed = params[:koan].to_s
  if KOAN_FILENAMES.include? claimed
    claimed
  else
    KOAN_FILENAMES.first
  end
end
def next_koan_name
  KOAN_FILENAMES[current_koan_count]
end
def current_koan_count
  KOAN_FILENAMES.index(current_koan_name)+1
end
def current_koan
  IO.read("koans/#{current_koan_name}.rb").remove_require_lines.gsub("assert false", "assert __")
end

def runnable_code(session={})
  unique_id = rand(10000)
  code = current_koan.swap_user_values(input,request,session).
    gsub(" ::About", " About").
    gsub("File", "FakeFile").
    gsub("IO", "FakeFile").
    gsub("Dir", "FakeFile").
    gsub(/([^\.])open\(/, '\1FakeFile.gimme(').
    gsub("ENV", '{:hacker => "AH AH AH! YOU DIDN\'T SAY THE MAGIC WORD!"}')
  index = code.rindex(/class About\w*? \< EdgeCase::Koan/)
  global_code = code[0...index]
  reset_global_classes = (global_code.scan(/class (\w+)/).flatten + CLASSES_ALLOWED).collect{|c| "Object.send(:remove_const, :#{c}) if defined? #{c};" }.join
  global_code = "#{reset_global_classes}begin; Object.send(:remove_method, :triangle);rescue;end#{global_code}"
  code = code[index..-1]
  <<-RUNNABLE_CODE
    require 'timeout'
    require 'test/unit/assertions'
    Test::Unit::Assertions::AssertionMessage.use_pp= false

    RESULTS = {:failures => {}, :pass_count => 0}
    $SAFE = 2
    Timeout.timeout(2) {
      #{global_code}
      module KoanArena
        module UniqueRun#{unique_id}
          #{::EDGECASE_CODE}
          #{::EDGECASE_OVERRIDES}
          #{code}
          path = EdgeCase::ThePath.new
          path.online_walk
          RESULTS[:pass_count] = path.sensei.pass_count
          RESULTS[:failures] = path.sensei.failures
        end
      end
      KoanArena.send(:remove_const, :UniqueRun#{unique_id})
    }
    RESULTS
  RUNNABLE_CODE
end

enable :sessions

def run_koan
  count = 0
  begin
    results = {:failures => {}}
    results = Thread.new {
      error_results = { pass_count: 0, failures: {} }
      begin
        eval(runnable_code(session), TOPLEVEL_BINDING)
      rescue SecurityError => se
        @error = "What do you think you're doing, Dave?"
        error_results
      rescue TimeoutError => te
        @error = 'Do you have an infinite loop?'
        error_results
      rescue SyntaxError => e
        @error = ['Syntax Error', e.message].flatten.join('<br/>')
        error_results
      rescue StandardError => e
        @error = ['Standard Error', e.message, e.backtrace, e.inspect].flatten.join('<br/>')
        error_results
      rescue Exception, Error => e
        @error = ['error', e.message].flatten.join('<br/>')
        error_results
      end
    }.value
  end
  # TODO: Present a nicer UI for error messages
  @pass_count = results[:pass_count]
  @failures   = results[:failures]
  @failures[:epic_fail] = true if @error
end

def next_page
  if KOAN_FILENAMES.last == current_koan_name
    @end = true
    :end
  else
    :next_koan
  end
end

### Internationalization
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
I18n.default_locale = :en

helpers do
  def t(path, options = {})
    options[:locale] = @locale

    # Just a simple alias
    I18n.t(path, options)
  end
end

get '/:locale/:koan' do
  @locale = params[:locale]
  do_stuff
end

get '/:locale' do
  return do_stuff if params[:koan]
  @locale = params[:locale]
  @hide_koan_name = true
  haml :intro
end

get '/' do
  redirect '/en'
end

def do_stuff
  return haml '%pre= runnable_code' if params[:dump]

  run_koan

  if @error && !request[:used_previous_session_code]
    return "#{@error.gsub(/\n/, "<br/>")} <br/><br/> Click your browser back button to return."
  elsif (@failures && @failures.count > 0) || params["input"].nil?
    @inputs = current_koan.swap_input_fields(input, @pass_count, @failures, session)
    return haml :koans
  else
    return haml next_page
  end
end
