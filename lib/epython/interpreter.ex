defmodule EPython.InterpreterState do
  defstruct [:topframe]
end

defmodule EPython.Interpreter do
  defp builtins do
    %{
      "print" =>
        %EPython.PyBuiltinFunction{
          name: "print",
          function: fn args -> IO.puts Enum.join(args, " ") end
        },
     }
  end

  defp opname(1), do: "POP_TOP"
  defp opname(2), do: "ROT_TWO"
  defp opname(3), do: "ROT_THREE"
  defp opname(4), do: "DUP_TOP"
  defp opname(5), do: "DUP_TOP_TWO"
  defp opname(9), do: "NOP"
  defp opname(10), do: "UNARY_POSITIVE"
  defp opname(11), do: "UNARY_NEGATIVE"
  defp opname(12), do: "UNARY_NOT"
  defp opname(15), do: "UNARY_INVERT"
  defp opname(16), do: "BINARY_MATRIX_MULTIPLY"
  defp opname(17), do: "INPLACE_MATRIX_MULTIPLY"
  defp opname(19), do: "BINARY_POWER"
  defp opname(20), do: "BINARY_MULTIPLY"
  defp opname(22), do: "BINARY_MODULO"
  defp opname(23), do: "BINARY_ADD"
  defp opname(24), do: "BINARY_SUBTRACT"
  defp opname(25), do: "BINARY_SUBSCR"
  defp opname(26), do: "BINARY_FLOOR_DIVIDE"
  defp opname(27), do: "BINARY_TRUE_DIVIDE"
  defp opname(28), do: "INPLACE_FLOOR_DIVIDE"
  defp opname(29), do: "INPLACE_TRUE_DIVIDE"
  defp opname(50), do: "GET_AITER"
  defp opname(51), do: "GET_ANEXT"
  defp opname(52), do: "BEFORE_ASYNC_WITH"
  defp opname(55), do: "INPLACE_ADD"
  defp opname(56), do: "INPLACE_SUBTRACT"
  defp opname(57), do: "INPLACE_MULTIPLY"
  defp opname(59), do: "INPLACE_MODULO"
  defp opname(60), do: "STORE_SUBSCR"
  defp opname(61), do: "DELETE_SUBSCR"
  defp opname(62), do: "BINARY_LSHIFT"
  defp opname(63), do: "BINARY_RSHIFT"
  defp opname(64), do: "BINARY_AND"
  defp opname(65), do: "BINARY_XOR"
  defp opname(66), do: "BINARY_OR"
  defp opname(67), do: "INPLACE_POWER"
  defp opname(68), do: "GET_ITER"
  defp opname(69), do: "GET_YIELD_FROM_ITER"
  defp opname(70), do: "PRINT_EXPR"
  defp opname(71), do: "LOAD_BUILD_CLASS"
  defp opname(72), do: "YIELD_FROM"
  defp opname(73), do: "GET_AWAITABLE"
  defp opname(75), do: "INPLACE_LSHIFT"
  defp opname(76), do: "INPLACE_RSHIFT"
  defp opname(77), do: "INPLACE_AND"
  defp opname(78), do: "INPLACE_XOR"
  defp opname(79), do: "INPLACE_OR"
  defp opname(80), do: "BREAK_LOOP"
  defp opname(81), do: "WITH_CLEANUP_START"
  defp opname(82), do: "WITH_CLEANUP_FINISH"
  defp opname(83), do: "RETURN_VALUE"
  defp opname(84), do: "IMPORT_STAR"
  defp opname(85), do: "SETUP_ANNOTATIONS"
  defp opname(86), do: "YIELD_VALUE"
  defp opname(87), do: "POP_BLOCK"
  defp opname(88), do: "END_FINALLY"
  defp opname(89), do: "POP_EXCEPT"
  defp opname(90), do: "STORE_NAME"
  defp opname(91), do: "DELETE_NAME"
  defp opname(92), do: "UNPACK_SEQUENCE"
  defp opname(93), do: "FOR_ITER"
  defp opname(94), do: "UNPACK_EX"
  defp opname(95), do: "STORE_ATTR"
  defp opname(96), do: "DELETE_ATTR"
  defp opname(97), do: "STORE_GLOBAL"
  defp opname(98), do: "DELETE_GLOBAL"
  defp opname(100), do: "LOAD_CONST"
  defp opname(101), do: "LOAD_NAME"
  defp opname(102), do: "BUILD_TUPLE"
  defp opname(103), do: "BUILD_LIST"
  defp opname(104), do: "BUILD_SET"
  defp opname(105), do: "BUILD_MAP"
  defp opname(106), do: "LOAD_ATTR"
  defp opname(107), do: "COMPARE_OP"
  defp opname(108), do: "IMPORT_NAME"
  defp opname(109), do: "IMPORT_FROM"
  defp opname(110), do: "JUMP_FORWARD"
  defp opname(111), do: "JUMP_IF_FALSE_OR_POP"
  defp opname(112), do: "JUMP_IF_TRUE_OR_POP"
  defp opname(113), do: "JUMP_ABSOLUTE"
  defp opname(114), do: "POP_JUMP_IF_FALSE"
  defp opname(115), do: "POP_JUMP_IF_TRUE"
  defp opname(116), do: "LOAD_GLOBAL"
  defp opname(119), do: "CONTINUE_LOOP"
  defp opname(120), do: "SETUP_LOOP"
  defp opname(121), do: "SETUP_EXCEPT"
  defp opname(122), do: "SETUP_FINALLY"
  defp opname(124), do: "LOAD_FAST"
  defp opname(125), do: "STORE_FAST"
  defp opname(126), do: "DELETE_FAST"
  defp opname(127), do: "STORE_ANNOTATION"
  defp opname(130), do: "RAISE_VARARGS"
  defp opname(131), do: "CALL_FUNCTION"
  defp opname(132), do: "MAKE_FUNCTION"
  defp opname(133), do: "BUILD_SLICE"
  defp opname(135), do: "LOAD_CLOSURE"
  defp opname(136), do: "LOAD_DEREF"
  defp opname(137), do: "STORE_DEREF"
  defp opname(138), do: "DELETE_DEREF"
  defp opname(141), do: "CALL_FUNCTION_KW"
  defp opname(142), do: "CALL_FUNCTION_EX"
  defp opname(143), do: "SETUP_WITH"
  defp opname(144), do: "EXTENDED_ARG"
  defp opname(145), do: "LIST_APPEND"
  defp opname(146), do: "SET_ADD"
  defp opname(147), do: "MAP_ADD"
  defp opname(148), do: "LOAD_CLASSDEREF"
  defp opname(149), do: "BUILD_LIST_UNPACK"
  defp opname(150), do: "BUILD_MAP_UNPACK"
  defp opname(151), do: "BUILD_MAP_UNPACK_WITH_CALL"
  defp opname(152), do: "BUILD_TUPLE_UNPACK"
  defp opname(153), do: "BUILD_SET_UNPACK"
  defp opname(154), do: "SETUP_ASYNC_WITH"
  defp opname(155), do: "FORMAT_VALUE"
  defp opname(156), do: "BUILD_CONST_KEY_MAP"
  defp opname(157), do: "BUILD_STRING"
  defp opname(158), do: "BUILD_TUPLE_UNPACK_WITH_CALL"

  defp execute_instructions(state) do
    frame = state.topframe

    if frame.pc < byte_size(frame.code[:code]) do
      <<opcode, arg>> = binary_part frame.code[:code], frame.pc, 2
      #IO.puts "#{frame.pc}: #{opname opcode} #{arg} (#{inspect frame.stack})"

      # We increment the program counter here by 2 every time.
      # This is so that we don't need to increase it in *every* instruction
      # function. The caveat is that in JUMP_RELATIVE we need to subtract 2
      # from the delta, but that's literally the only caveat.
      frame = %{frame | pc: frame.pc + 2}
      state = %{state | topframe: frame}

      state = execute_instruction(opcode, arg, state)
      execute_instructions state
    else
      state
    end
  end

  # POP_TOP
  defp execute_instruction(1, _arg, state) do
    frame = state.topframe
    frame = %{frame | stack: tl(frame.stack)}
    %{state | topframe: frame}
  end

  # TODO: Replace the BINARY_* instructions with macros.

  # BINARY_POWER
  defp execute_instruction(19, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    # TODO: Add this to PyOperable.
    frame = %{frame | stack: [:math.pow(x, y) | stack]}

    %{state | topframe: frame}
  end

  # BINARY_MULTIPLY
  defp execute_instruction(20, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.mul(x, y) | stack]}

    %{state | topframe: frame}
  end

  # BINARY_MODULO
  # TODO: Test the semantics of modulo with negative numbers.
  defp execute_instruction(22, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.mod(x, y) | stack]}

    %{state | topframe: frame}
  end

  # TODO: Consolidate BINARY_* methods.

  # BINARY_ADD
  defp execute_instruction(23, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.add(x, y) | stack]}

    %{state | topframe: frame}
  end

  # BINARY_SUBTRACT
  defp execute_instruction(24, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.sub(x, y) | stack]}

    %{state | topframe: frame}
  end

  # BINARY_FLOOR_DIVIDE
  defp execute_instruction(26, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.floor_div(x, y) | stack]}

    %{state | topframe: frame}
  end

  # BINARY_TRUE_DIVIDE
  defp execute_instruction(27, _arg, state) do
    frame = state.topframe
    [y | stack] = frame.stack
    [x | stack] = stack

    frame = %{frame | stack: [EPython.PyOperable.true_div(x, y) | stack]}

    %{state | topframe: frame}
  end

  # RETURN_VALUE
  defp execute_instruction(83, _arg, state) do
    frame = state.topframe

    case frame.previous_frame do
      nil ->
        # RETURN_VALUEs at the module level are kind of a strange thing.
        # I just return the state as-is (with some sanity checks) for now,
        # but I'm not sure if a RETURN_VALUE can occur before the end of the
        # module.
        if hd(frame.stack) == :none do
          state
        else
          raise RuntimeError, message: "Tried to RETURN_VALUE at module level that wasn't :none"
        end

      parent ->
        parent = %{parent | stack: [hd(frame.stack) | parent.stack]}

        %{state | topframe: parent}
    end
  end

  # STORE_NAME
  defp execute_instruction(90, arg, state) do
    {value, frame} = pop_from_stack state.topframe

    name = elem(frame.code[:names], arg)
    variables = put_or_update frame.variables, name, value

    frame = %{frame | variables: variables}
    %{state | topframe: frame}
  end

  # UNPACK_SEQUENCE
  defp execute_instruction(92, arg, state) do
    if arg == 0 do
      state
    else
      frame = state.topframe
      [head | stack] = frame.stack

      # XXX: We really need to fix tuples.
      head = if(is_tuple(head), do: Tuple.to_list(head), else: head)

      {_, stack} = Enum.reduce((1..arg), {head, stack}, fn _, {[item | rest], stack} ->
        {rest, [item | stack]}
      end)

      frame = %{frame | stack: stack}
      %{state | topframe: frame}
    end
  end

  # LOAD_CONST
  defp execute_instruction(100, arg, state) do
    frame = state.topframe
    const = elem(frame.code[:consts], arg)
    frame = %{frame | stack: [const | frame.stack]}

    %{state | topframe: frame}
  end

  # LOAD_NAME
  defp execute_instruction(101, arg, state) do
    # TODO: Look in the parents if we can't find it here.
    frame = state.topframe

    name = elem(frame.code[:names], arg)

    b = builtins()
    value = if Map.has_key?(b, name) do
      b[name]
    else
      frame.variables[name]
    end

    frame = %{frame | stack: [value | frame.stack]}
    %{state | topframe: frame}
  end

  # COMPARE_OP
  defp execute_instruction(107, arg, state) do
    frame = state.topframe

    [y | stack] = frame.stack
    [x | stack] = stack

    result = case arg do
      0 -> x < y
      1 -> x <= y
      2 -> x == y
      3 -> x != y
      4 -> x > y
      5 -> x >= y
      6 -> if(is_tuple(y), do: x in Tuple.to_list(y), else: x in y)
      7 -> x not in y
      #8 -> x is y
      #9 -> x is not y
      #10 -> 'exception match'
      #11 -> 'BAD'
    end

    frame = %{frame | stack: [result | stack]}

    %{state | topframe: frame}
  end

  # JUMP_FORWARD
  defp execute_instruction(110, arg, state) do
    frame = state.topframe
    # remember, we have to account for always adding 2
    frame = %{frame | pc: frame.pc + (2 * arg - 2)}

    %{state | topframe: frame}
  end

  # POP_JUMP_IF_FALSE, POP_JUMP_IF_TRUE
  defp execute_instruction(opcode, arg, state) when opcode == 114 or opcode == 115 do
    frame = state.topframe
    [head | stack] = frame.stack

    should_jump =
      if opcode == 114 do  # POP_JUMP_IF_FALSE
        not truthy?(head)
      else
        truthy?(head)
      end

    pc =
      if should_jump do
        arg
      else
        frame.pc
      end

    frame = %{frame | pc: pc}
    frame = %{frame | stack: stack}

    %{state | topframe: frame}
  end

  # LOAD_GLOBAL
  defp execute_instruction(116, arg, state) do
    frame = state.topframe
    module_frame = get_module_frame frame

    name = elem(frame.code[:names], arg)

    b = builtins()
    value =
      if Map.has_key?(module_frame.variables, name) do
        module_frame.variables[name]
      else
        if Map.has_key?(b, name) do
          b[name]
        else
          raise RuntimeError, message: "Unknown global #{inspect name}"
        end
      end

    frame = %{frame | stack: [value | frame.stack]}
    %{state | topframe: frame}
  end

  # LOAD_FAST
  defp execute_instruction(124, arg, state) do
    frame = state.topframe

    name = elem(frame.code[:varnames], arg)

    value = frame.variables[name]

    frame = %{frame | stack: [value | frame.stack]}
    %{state | topframe: frame}
  end

  # STORE_FAST
  defp execute_instruction(125, arg, state) do
    {value, frame} = pop_from_stack state.topframe

    name = elem(frame.code[:varnames], arg)
    variables = put_or_update frame.variables, name, value

    frame = %{frame | variables: variables}
    %{state | topframe: frame}
  end


  # CALL_FUNCTION
  defp execute_instruction(131, arg, state) do
    frame = state.topframe

    {args, stack} =
      if arg == 0 do
        {[], frame.stack}
      else
        Enum.reduce((1..arg), {[], frame.stack},
                    fn _, {args, [head | tail]} -> {[head | args], tail} end)
      end

    [func | stack] = stack

    frame = %{frame | stack: stack}
    state = %{state | topframe: frame}

    EPython.PyCallable.call(func, args, state)
  end

  # MAKE_FUNCTION
  defp execute_instruction(132, arg, state) do
    if arg != 0 do
      raise ArgumentError, message: "Flags for MAKE_FUNCTION are not supported yet."
    end

    frame = state.topframe
    [fname | stack] = frame.stack
    [fcode | stack] = stack

    func = %EPython.PyUserFunction{name: fname, code: fcode}

    stack = [func | stack]
    frame = %{frame | stack: stack}

    %{state | topframe: frame}
  end

  defp execute_instruction(opcode, arg, _state) do
    raise ArgumentError, message: "Unknown instruction #{opcode} with opname #{inspect opname(opcode)} and arg #{arg}"
  end

  # TODO: Maybe use a protocol?
  # truthy?(integer)
  defp truthy?(0), do: false
  defp truthy?(n) when is_integer(n), do: true

  # truthy?(float)
  defp truthy?(0.0), do: false
  defp truthy?(n) when is_float(n), do: true

  # truthy?(atom)
  defp truthy?(:true), do: true
  defp truthy?(:ellipsis), do: true
  defp truthy?(:stopiteration), do: true
  defp truthy?(n) when is_atom(n), do: false

  defp get_module_frame(frame) do
    case frame.previous_frame do
      nil    -> frame
      parent -> get_module_frame parent
    end
  end

  defp pop_from_stack(frame) do
    [head | stack] = frame.stack
    {head, %{frame | stack: stack}}
  end

  defp put_or_update(map, name, value) when is_map(map) do
    if Map.has_key?(map, name) do
      %{map | name => value}
    else
      Map.put(map, name, value)
    end
  end

  def interpret(bf) do
    code = bf.code_obj
    state = %EPython.InterpreterState{topframe: %EPython.PyFrame{code: code}}

    execute_instructions state
  end
end
