module ExecutionCoreDebug
  def get_locals_string(frame)
    locals_string = "[LOCALS]\n["
    frame.locals.each_with_index do |item, index|
      locals_string << "(#{index} => #{item}), "
    end
    locals_string << ']'
  end

  def get_stack_string(frame)
    stack_string = "[STACK]\n["
    frame.stack.each_with_index do |i, index|
      stack_string << "(#{index} => #{i}), "
    end
    stack_string << ']'
  end
end