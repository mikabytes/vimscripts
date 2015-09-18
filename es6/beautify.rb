
$assignment = /(?<!=)=(?!=)/
$single_quote_string = /'.*?(?<!\\)'/
$double_quote_string = /".*?(?<!\\)"/
$string = /(#{$single_quote_string}|#{$double_quote_string})/
$number = /[1-9][0-9]*/
$null = /null/
$undefined = /(undefined|void 0)/

$literal = /(#{$string}|#{$number}|#{$null}|#{$undefined})/
$identifier = /[a-zA-Z_$][a-zA-Z0-9_$]*/
$val = /(#{$literal}|#{$identifier})/

$dict_key = /[a-zA-Z0-9_$]+/
$dict_keyval = /#{$dict_key}\s*:\s*#{$val}/
$param_list = /#{$dict_keyval}(\s*,\s*#{$dict_keyval})*/

#
# beautify below
# 

def blockify str
  a = -> {
    str.gsub! /^  (\ *)(  [^ ]  [^{\n]*  ){  (  (?:  \n\1\ [^\n]*|\n)*  )  \n\1};?$/mx, '\1\2\3'
  }

  i = 0
  while a.call() and i < 30
    i+=1
  end
  perror "Infinite recursion detected!" if i == 30
end

def beautify str, expand_space: false
  str = str.dup

  str.gsub!(/ +$/, '')
  str.gsub! /\({(#{$param_list})}\)/, '(\1)'
  str.gsub!(/=\s*\(\)\s*=>/, '= =>')
  str.gsub! /shared\.?/, '@'
  str.gsub! /{\s+}/m, '{}'
  blockify str
  str.gsub! /^  |\G  /, '    ' if expand_space
  #str.gsub! /^(\s*(?:const|var|let|return|import|require|export).*)\s*;(\s*(\/\/|\/\*).*)?$/, '\1\2'
  #str.gsub! /^(.*?)(?<!,\=\+\[\()\s*;(\s*(\/\/|\/\*).*)?$/, '\1\2'
  str.gsub!(/ +$/, '')

  str
end


#
# uglify below
#

def braceify str
  indented_block = /^  (\ *)([^\s][^\n]*)(?<!{)\n     (       (?:  \s*\1\ [^\n]*\n?  )+    )/mx

  a = -> {
    str.gsub!(indented_block) {
      space = $1
      funccall = $2
      block = $3
      semi = funccall =~ /^[^(]*#{$identifier}\s*#{$assignment}/ ? ';' : ''

      "#{space}#{funccall} {\n#{block}#{space}}#{semi}\n" 
    }
  }

  i = 0
  while a.call() and i < 30
    i+=1
  end
  perror "Infinite recursion detected!" if i == 30
end

def uglify str, expand_space: false
  str = str.dup

  str.gsub!(/ +$/, '')
  str.gsub!(/\((#{$param_list})\)$/, '({\1})')
  str.gsub!(/=\s+=>/, '= () =>')
  str.gsub!(/@(#{$identifier})/, 'shared.\1')
  str.gsub!('@', 'shared')
  braceify(str)
  str.gsub! /^    |\G    /, '  ' if expand_space
  #str.gsub! /^(\s*(?:const|var|let|return|import|require|export).*?)(?<!;)(\s*(\/\/|\/\*).*)?$/, '\1;\2'

  str
end

