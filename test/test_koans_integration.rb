require 'test/unit'
require 'capybara/poltergeist'

class TestKoansIntegration < Test::Unit::TestCase
  include Capybara::DSL

  setup do
    Capybara.current_driver = :poltergeist
    Capybara.app_host = 'http://localhost:9292' # TODO: Fire up the app automatically.
    Capybara.match = :first
  end

  def test_homepage
    visit '/'
    assert_includes page.body, "Ruby Koans Online"
    find(:first, "a", text: "Start the Koans").click
    assert_includes page.body, "about_asserts"
  end

  TriangleSolved = "def triangle(a,b,c)\nmatching_sides = [ a==b, b==c, c==a]\nif matching_sides.count(true) == 3\n :equilateral\n elsif matching_sides.count(true) == 1\n :isosceles \n else \n   :scalene \n end \n end"

  Triangle2Solved = "class TriangleError < StandardError\nend\n def triangle a, b, c\n a,b,c = [a,b,c].sort\n raise TriangleError if [a,b,c].any?{|side| side <= 0} || a+b <= c\n [nil, :equilateral, :isosceles, :scalene][[a,b,c].uniq.count]\n end\n"

  ProxySolved = "class Proxy\n   def initialize(target_object)\n     @object = target_object\n     @messages = {}\n @messes = []\n  end\n   def method_missing(method_name, *args)\n     @messes << method_name\n @messages[method_name] ||= 0\n     @messages[method_name] += 1\n     @object.send(method_name, *args)\n   end\n   def called?(m)\n     @messes.include? m\n   end\n   def number_of_times_called(m)\n     @messages[m] || 0\n   end\n   def messages\n @messes\nend\n end"

  KoansWithAnswers = {
    "about_asserts": ["true", "true", "2", "2", "2"],
    "about_nil": ["true", "NoMethodError", "undefined method", "true", "\"\"", "\"nil\""],
    "about_objects": ["true", "true", "true", "true", "true", "\"123\"", "\"\"", "\"123\"", "\"nil\"", "Fixnum", "true", "0", "20", "8", "1", "3", "5", "201", "true", "true"],
    "about_arrays": ["Array", "0", "2", "[1, 2, 333]", ":peanut", ":peanut", ":jelly", ":jelly", ":jelly", ":butter", "[:peanut]", "[:peanut, :butter]", "[:and, :jelly]", "[:and, :jelly]", "[]", "[]", "nil", "Range", "[1,2,3,4,5]", "[1,2,3,4]", "[:peanut, :butter, :and]", "[:peanut, :butter]", "[:and, :jelly]", "[1, 2, :last]", ":last", "[1, 2]", "[:first, 1, 2]", ":first", "[1, 2]"],
    "about_array_assignment": ["[\"John\", \"Smith\"]", "\"John\"", "\"Smith\"", "\"John\"", "\"Smith\"", "\"John\"", "[\"Smith\",\"III\"]", "\"Cher\"", "nil", "[\"Willie\", \"Rae\"]", "\"Johnson\"", "\"John\"", "'Rob'", "'Roy'"],
    "about_hashes": ["Hash", "0", "2", "\"uno\"", "\"dos\"", "nil", "\"eins\"", "true", "true", "2", "true", "true", "Array", "2", "true", "true", "Array", "true", "54", "26", "true"],
    "about_strings": ["true", "true", "'He said, \"Go Away.\"'", "\"Don't\"", "true", "true", "true", "54", "53", "\"Hello, World\"", "\"Hello, \"", "\"World\"", "\"Hello, World\"", "\"Hello, \"", "\"Hello, World\"", "\"World\"", "\"Hello, World\"", "1", "2", "2", "\"\\\\'\"", "\"The value is 123\"", "'The value is \#{value}'", "\"The square root of 5 is 2.23606797749979\"", "\"let\"", "\"let\"", "\"a\"", "\"Sausage\"", "\"Egg\"", "\"Cheese\"", "\"the\"", "\"rain\"", "\"in\"", "\"spain\"", "\"Now is the time\"", "true", "false"],
    "about_symbols": ["true", "true", "false", "true", "true", "true", ":catsAndDogs", "\"cats and dogs\"", "\"cats and dogs\"", "'It is raining cats and dogs.'", "false", "false", "false", "false", "NoMethodError", ":catsdogs"],
    "about_regular_expressions": ["Regexp", "\"match\"", "nil", "\"ab\"", "\"a\"", "\"bccc\"", "\"abb\"", "\"a\"", "\"\"", "\"a\"", "[\"cat\", \"bat\", \"rat\"]", "\"42\"", "\"42\"", "\"42\"", "\" \\t\\n\"", "\"variable_1\"", "\"variable_1\"", "\"abc\"", "\"the number is \"", "\"the number is \"", "\"space:\"", "\" = \"", "\"start\"", "nil", "\"end\"", "nil", "\"2\"", "\"42\"", "\"vines\"", "\"hahaha\"", "\"Gray\"", "\"James\"", "\"Gray, James\"", "\"Gray\"", "\"James\"", "\"James Gray\"", "\"Summer\"", "nil", "[\"one\", \"two\", \"three\"]", "\"one t-three\"", "\"one t-t\""],
    "about_methods": ["5", "5", "ArgumentError", "wrong number of arguments", "ArgumentError", "wrong number of arguments", ":default_value", "2", "[]", "[:one]", "[:one, :two]", ":return_value", ":return_value", "12", "12", "\"a secret\"", "NoMethodError", "private method `my_private_method' called ", "\"Fido\"", "NoMethodError"],
    "about_constants": ["\"nested\"", "\"top level\"", "\"nested\"", "\"nested\"", "4", "4", "2", "4"],
    "about_control_statements": [":true_value", ":true_value", ":true_value", ":false_value", "nil", ":true_value", ":false_value", ":true_value", ":false_value", ":false_value", "3628800", "3628800", "[1, 3, 5, 7, 9]", "\"FISH\"", "\"AND\"", "\"CHIPS\""],
    "about_true_and_false": [":true_stuff", ":false_stuff", ":false_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff", ":true_stuff"],
    "about_triangle_project": [TriangleSolved],
    "about_exceptions": ["RuntimeError", "StandardError", "Exception", "Object", ":exception_handled", "true", "true", "\"Oops\"", ":exception_handled", "\"My Message\"", ":always_run", "MySpecialError"],
    "about_triangle_project_2": [Triangle2Solved],
    "about_iteration": ["6", "6", "6", "[11, 12, 13]", "[11, 12, 13]", "[2, 4, 6]", "[2, 4, 6]", "\"Clarence\"", "9", "24", "[11, 12, 13]", "[\"THIS\", \"IS\", \"A\", \"TEST\"]"],
    "about_blocks": ["3", "3", "\"Jim\"", "[:peanut, :butter, :and, :jelly]", ":with_block", ":no_block", ":modified_in_a_block", "11", "11", "\"JIM\"", "20", "11"],
    "about_sandwich_code": ["4", "\"test\\n\"", "4", "file_sandwich(file_name) do |file|\n  while line = file.gets\n    return line if line.match /e/\n  end\nend", "4"],
    "about_scoring_project": [ "(1..6).collect do |n|\n score_for_number = 0\n count = dice.select{|x| x==n }.count\n extra = count % 3\n score_for_number += (n==1)? 1000 : n*100 if count/3==1\n score_for_number += extra*100 if n == 1\n score_for_number += extra*50  if n == 5\n score_for_number\n end.inject(0){|n,t| n+t }"],
    "about_classes": ["Dog", "[]", "[:@name]", "NoMethodError", "\"Fido\"",  "\"Fido\"", "\"Fido\"", "\"Fido\"", "\"Fido\"", "ArgumentError", "true", "@name", "fido", "\"My dog is Fido\"", "\"<Dog named 'Fido'>\"", "\"[1, 2, 3]\"", "\"[1, 2, 3]\"", "\"STRING\"", "'\"STRING\"'"],
    "about_open_classes": ["\"WOOF\"", "\"HAPPY\"", "\"WOOF\"", "false", "true"],
    "about_dice_project": [ "class DiceSet\n def roll number\n @number = number\n @values = nil\n end\n def values\n return @values unless @values.nil?\n @values ||= []\n @number.times{ @values.push(rand(6).to_i+1) }\n @values\n end\n end\n "],
    "about_inheritance": ["true", "true", "\"Chico\"", ":happy", "NoMethodError", "\"yip\"", "\"WOOF\"", "\"WOOF, GROWL\"", "NoMethodError"],
    "about_modules": ["NoMethodError", "\"WOOF\"", "\"Fido\"", "\"Rover\"", ":in_object"],
    "about_scope": ["NameError", ":jims_dog", ":joes_dog", "true", "true", "true", "false", "true", "3.1416", "true", "true", "true", "true", "[:Dog]", "0"],
    "about_message_passing": ["\"?\"", "downcase", "true", "true", "false", "[]", "[]", "[3, 4, nil, 6]", "[3, 4, nil, 6]", "NoMethodError", "NoMethodError", "\"Someone called foobar with <>\"", "\"Someone called foobaz with <1>\"", "\"Someone called sum with <1, 2, 3, 4, 5, 6>\"", "false", "\"Foo to you too\"", "\"Foo to you too\"", "NoMethodError", "true", "false"],
    "about_proxy_object_project": [ProxySolved],
    "about_to_str": ["\"non-string-like\"", "TypeError", "\"string-like\"", "false", "false", "true"],
  }

  def fill_inputs_with(answers)
    assert_not_nil answers
    inputs = page.find_all(".koanInput")
    assert_equal answers.count, inputs.count
    answers.each_with_index do |answer, index|
      inputs[index].set(answer)
    end
  end

  KoansWithAnswers.each_pair do |koan_name, answers|
    define_method("test_#{koan_name}_happy_path") do
      page.visit "/en/#{koan_name}"
      fill_inputs_with(answers)
      click_on "Click to submit Meditation or press Enter while in the form."
      assert_include page.body, "has heightened your awareness"
    end
  end

  def test_about_scoring_project_shouldnt_share_answers_with_dice_project
      page.reset!
      page.visit "/en/about_dice_project"
      fill_inputs_with KoansWithAnswers[:about_dice_project]
      click_on "Click to submit Meditation or press Enter while in the form."
      assert_include page.body, "has heightened your awareness"
      page.visit "/en/about_scoring_project"
      input = page.find(".koanInput")
      assert_equal "# You need to write this method\n", input.value
  end

  def test_about_triangle_project_2_should_share_answers_with_triangle_project
      page.reset!
      page.visit "/en/about_triangle_project"
      input = page.find(".koanInput")
      assert_equal "# You need to write the triangle method\n", input.value
      fill_inputs_with KoansWithAnswers[:about_triangle_project]
      click_on "Click to submit Meditation or press Enter while in the form."
      assert_include page.body, "has heightened your awareness"
      page.visit "/en/about_triangle_project_2"
      input = page.find(".koanInput")
      assert_equal TriangleSolved, input.value
      fill_inputs_with KoansWithAnswers[:about_triangle_project_2]
      click_on "Click to submit Meditation or press Enter while in the form."
      assert_include page.body, "has heightened your awareness"
  end

  def test_about_triangle_syntax_error
    page.reset!
    missing_end_answer = "def triangle(a,b,c)
if a == b && b == c
if c == a
:equilateral
else
:isosceles
end
end"
    page.visit "/en/about_triangle_project"
    fill_inputs_with [missing_end_answer]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Syntax Error"
    assert_include page.body, "Click your browser back button to return."
  end

  def test_about_asserts_syntax_error
    page.reset!
    modified_answers = KoansWithAnswers[:about_asserts].clone
    modified_answers[0] = ":::"
    page.visit "/en/about_asserts"
    fill_inputs_with modified_answers
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Syntax Error"
    assert_include page.body, "Click your browser back button to return."
  end

  def test_about_triangle_undefined_method_should_show_errors
    page.reset!
    undefined_method_answer = "def triangle(a,b,c)
  matching_sides = [ a==b, b==c, c==a]
  if matching_sides.sum(true) == 3
    :equilateral
  elsif matching_sides.sum(true) == 2
    :isosceles
  else
    :scalene
  end
end"
    page.visit "/en/about_triangle_project"
    fill_inputs_with [undefined_method_answer]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "undefined method `sum' for [true, true, true]:Array"
  end

  def test_attempts_to_shell_out_in_about_triangle
    page.reset!
    attempt_to_shell_out = "`pwd`"
    page.visit "/en/about_triangle_project"
    fill_inputs_with [attempt_to_shell_out]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "What do you think you're doing, Dave?"
    assert_include page.body, "Click your browser back button to return."
  end

  def test_attempts_to_shell_out_in_about_asserts
    page.reset!
    modified_answers = KoansWithAnswers[:about_asserts].clone
    modified_answers[0] = "`pwd`"
    page.visit "/en/about_asserts"
    fill_inputs_with modified_answers
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "What do you think you're doing, Dave?"
    assert_include page.body, "Click your browser back button to return."
  end

  def test_infinite_loop_in_about_triangle
    page.reset!
    infinite_loop = "def triangle(a, b, c)
  while(true) do
    puts 'hi'
  end
end"
    page.visit "/en/about_triangle_project"
    fill_inputs_with [infinite_loop]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Do you have an infinite loop?"
    assert_include page.body, "Click your browser back button to return."
  end

  def test_infinite_loop_in_about_asserts
    page.reset!
    modified_answers = KoansWithAnswers[:about_asserts].clone
    modified_answers[0] = 'loop{ puts "hi" }'
    page.visit "/en/about_asserts"
    fill_inputs_with modified_answers
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Do you have an infinite loop?"
    assert_include page.body, "Click your browser back button to return."
  end

  FILE_OPEN = 'File.open("config.ru")'
  def test_file_open_in_about_triangle_without_leading_space
    page.reset!
    page.visit "/en/about_triangle_project"
    fill_inputs_with [FILE_OPEN]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Standard Error"
    assert_include page.body, "private method `open' called for FakeFile:Class"
  end

  def test_file_open_in_about_triangle_with_leading_space
    page.reset!
    page.visit "/en/about_triangle_project"
    fill_inputs_with [" " + FILE_OPEN]
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "Standard Error"
    assert_include page.body, "private method `open' called for FakeFile:Class"
  end

  def test_file_open_in_about_asserts_without_leading_space
    page.reset!
    page.visit "/en/about_asserts"
    modified_answers = KoansWithAnswers[:about_asserts].clone
    modified_answers[0] = FILE_OPEN
    fill_inputs_with modified_answers
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "private method `open' called for FakeFile:Class"
  end

  def test_file_open_in_about_asserts_with_leading_space
    page.reset!
    page.visit "/en/about_asserts"
    modified_answers = KoansWithAnswers[:about_asserts].clone
    modified_answers[0] = " " + FILE_OPEN
    fill_inputs_with modified_answers
    click_on "Click to submit Meditation or press Enter while in the form."
    assert_include page.body, "private method `open' called for FakeFile:Class"
  end
end
