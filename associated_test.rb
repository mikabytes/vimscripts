#!/usr/bin/env ruby

class AssociatedTest

  def initialize(test_folder:, source_folder:, convert_to_test:, convert_to_source:, command_to_test_file:, command_to_test_all:)
    @test_folder = test_folder
    @source_folder = source_folder
    @convert_to_test = convert_to_test
    @convert_to_source = convert_to_source
    @command_to_test_file = command_to_test_file
    @command_to_test_all = command_to_test_all
  end


  def relative_path
    $curbuf.name[(Dir.pwd.length+1)..-1].dup
  end

  def get_alternate
    path = relative_path
    if path.include? @test_folder
      path.sub!(@test_folder, @source_folder)
      @convert_to_source.call(path)
    else
      path.sub!(@source_folder, @test_folder)
      @convert_to_test.call(path)
    end
    path
  end

  def find_buffer path
    full = Dir.pwd + '/' + path
    VIM::Buffer.count.times do |i|
      if VIM::Buffer[i].name == full
        return VIM::Buffer[i]
      end
    end
    nil
  end

  def go_to_alternative
    p = get_alternate
    buffer = find_buffer(p)

    if buffer
      VIM.command("b#{buffer.number}")
    else
      VIM.command("edit #{p}")
    end
  end

  def vertical_split_alternative
    p = get_alternate
    buffer = find_buffer(p)

    VIM.command("vsp")
    if buffer
      VIM.command("b#{buffer.number}")
    else
      VIM.command("edit #{p}")
    end
  end

  def test_file
    path = relative_path
    path = get_alternate unless path.include?(@test_folder)

    command = @command_to_test_file.sub('(path)', path)
    puts "Executing: #{command}"
    VIM.command(command)
  end

  def test_all 
    VIM.command(@command_to_test_all)
  end

  def bind_keys global_obj
    VIM.command("nmap <Leader>r :ruby #{global_obj}.test_file<CR>")
    VIM.command("nmap <Leader>R :ruby #{global_obj}.test_all<CR>")
    VIM.command("nmap Z :ruby #{global_obj}.vertical_split_alternative<CR>")
    VIM.command("nmap z :ruby #{global_obj}.go_to_alternative<CR>")
  end
end

