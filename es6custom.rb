require_relative 'es6/uglify'
require_relative 'es6/beautify'

def es6_beautify
  str = ''
  $curbuf.count.times do |i|
    str += "#{$curbuf[1]}\n"
    $curbuf.delete(1)
  end

  str = beautify str, expand_space: true

  str.split("\n").each_with_index do |line, i|
    $curbuf.append(i, line)
  end

  VIM.command "if exists('b:view') | call winrestview(b:view) | endif"
end

def es6_uglify
  VIM.command("let b:view = winsaveview()")

  str = ''
  $curbuf.count.times do |i|
    str += "#{$curbuf[1]}\n"
    $curbuf.delete(1)
  end

  str = uglify str, expand_space: true

  str.split("\n").each_with_index do |line, i|
    $curbuf.append(i, line)
  end
end
