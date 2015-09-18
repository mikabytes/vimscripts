require 'minitest/autorun'
require 'shoulda/context'
require_relative 'es6/beautify'

class TestBeautifier < Minitest::Test

  context 'beautifier' do

    should '({param-list}) -> (param-list)' do
      assert_equal "callthis(dog: 'puppy')", (beautify "callthis({dog: 'puppy'})")
      assert_equal "callthis(one: 'one', two: 2)", (beautify "callthis({one: 'one', two: 2})")
      assert_equal "callthis(_$one: '\"one\"', two: 20)", (beautify "callthis({_$one: '\"one\"', two: 20})")
    end

    should '() =>   to   =>' do
      assert_equal 'call = =>', (beautify 'call = () =>')
    end

    should 'shared.   to   @' do
      assert_equal '@inst', (beautify 'shared.inst')
    end

    should 'shared=   to   @=' do
      assert_equal '@ = {}', (beautify 'shared = {}')
    end

    should 'remove braces on indented block' do
      input = '''
  function foo() {
    a

    b {
    }
    
    c {
      lal
    };
  }

  stuff'''

      expected = '''
  function foo()
    a

    b {}

    c
      lal

  stuff'''

      assert_equal expected, beautify(input)
    end

    should 'switch from 2-space indent to 4-space' do
      input = '''
a
  b
    c
  d
e'''

      expected = '
a
    b
        c
    d
e'

      assert_equal expected, beautify(input, expand_space: true)
    end

    should 'remove semicolons from const, let, var, return' do
      assert_equal "const a=5\nlet b=4\nvar c=3\nreturn\nreturn 1\nimport whateva\nrequire apa/*lol*/\nexport a //nocomment", 
        beautify("const a=5;\nlet b=4  ;\nvar c=3\nreturn;\nreturn 1;\nimport whateva;\nrequire apa;/*lol*/\nexport a; //nocomment")
    end

    should 'not remove semicolons from lines not ending in ,\=+[(' do
      input = '
      a = 1;
      k();
      b.c(;
        d;
      );
      e = [;
        1,
        2
      ];
      b =;
        1
        '

      expected = '
      a = 1
      k()
      b.c(;
        d
      )
      e = [;
        1
      ];
      b =;
        1
        '

    end

  end

  context 'uglifier' do

    should '(param-list) -> ({param-list})' do
      assert_equal "callthis({dog: 'puppy'})", (uglify "callthis(dog: 'puppy')")
      assert_equal "callthis({one: 'one', two: 2})", (uglify "callthis(one: 'one', two: 2)")
      assert_equal "callthis({_$one: '\"one\"', two: 20})", (uglify "callthis(_$one: '\"one\"', two: 20)")
    end

    should '= =>   to   = () =>' do
      assert_equal 'call = () =>', (uglify 'call = =>')
    end

    should '@var   to   shared.var' do
      assert_equal 'shared.var', (uglify '@var')
    end

    should '@ = {}   to   shared = {}' do
      assert_equal 'shared = {}', (uglify '@ = {}')
    end

    should 'add braces to blocks' do
      input = '''
function foo()
  a

  b

  c = =>
    d
    e

other = 1'''

      expected = '''
function foo() {
  a

  b

  c = () => {
    d
    e
  };
}

other = 1'''

      assert_equal expected, uglify(input)
    end

    should 'switch from 4-space indent to 2-space' do
      input = '
a
    b
        c
    d
e'


      expected = '
a {
  b {
    c
  }
  d
}
e'
      assert_equal expected, uglify(input, expand_space: true)
    end

    should 'add semicolons from const, let, var' do
      assert_equal "const a=5;\nlet b=4;\nvar c=3;\nreturn;\nreturn 1;\nimport whateva;\nrequire apa;/*lol*/\nexport a; // comment",
        uglify("const a=5\nlet b=4\nvar c=3;\nreturn\nreturn 1\nimport whateva\nrequire apa/*lol*/\nexport a // comment")
    end


  end
end
