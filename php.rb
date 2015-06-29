
def php_beautify
  return if $nophp
  $curbuf.count.times do |i|
    line = $curbuf[i+1]

    if qualified_for_semicolon(line) && line[-1] == ';'
      line.chop!
    end

    if $inside_php and not $inside_comment
      line.gsub!('@', '!OMG!')
      line.gsub!('$this->', '@')

      match = /pDebug::log_symfony.*var_export.*\(([^,]*), true/.match(line)
      if match
        line.gsub! /pDebug.*$/, "log #{match[1]}"
      end
    end

    $curbuf[i+1] = line
  end

end

def php_uglify
  return if $nophp

  $curbuf.count.times do |i|
    line = $curbuf[i+1]

    if $inside_php and not $inside_comment
      line.gsub!('@', '$this->')
      line.gsub!('!OMG!', '@') 
      
      match = /^\s*log (.*)$/.match(line)
      if match
        line.gsub! /log.*$/, "pDebug::log_symfony(var_export(#{match[1]}, true))"
      end
    end

    if qualified_for_semicolon(line) && line[-1] != ';'
      line+=';'
    end

    $curbuf[i+1] = line
  end

end

$nested_paran = 0
$inside_php = false
$inside_comment = false

def qualified_for_semicolon line
    line = line.strip.chomp(';')
    $nested_paran += line.scan('(').count
    $nested_paran -= line.scan(')').count

    $inside_php = true if line['<?']
    $inside_php = false if line['?>']

    $inside_comment = true if line['/*']
    $inside_comment = false if line['*/']

    !line.empty? and
      !line.start_with?('if') and
      !line.start_with?('else') and
      !line.end_with?(',') and
      !line['//'] and
      !line.start_with?('foreach') and
      !line['function'] and
      $nested_paran == 0 and
      $inside_php and
      !$inside_comment and
      (line.end_with?(')') or
       line.end_with?("'") or
       line[/=[^>]/] or
       line == 'break' or
       line.start_with?('return')
      )
end

VIM.command("autocmd BufRead,BufWritePost *.php :ruby php_beautify")
VIM.command("autocmd BufWritePre *.php :ruby php_uglify")
