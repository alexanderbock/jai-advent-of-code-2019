Program :: struct {
    name: string;
    memory: []int;

    pc : int;
    input_counter := 0;
    relative_base := 0;

    do_debug_print := true;
    do_full_debug_print := false;
    do_print := true;
}

read_program :: (filename: string) -> Program, success: bool {
  content, success := File.read_entire_file(filename);
  if !success {
    print("Error loading file\n");
    return Program.{}, false;
  }  
  string_values := String.split(content, ",");

  program : Program;
  program.memory = map(string_values, unsafe_string_to_int);

  return program, true;
}

copy_program :: (program: Program) -> Program {
  res : Program;
  res.memory = array_copy(program.memory);
  res.pc = program.pc;
  res.input_counter = program.input_counter;
  res.do_debug_print = program.do_debug_print;
  res.do_print = program.do_print;
  return res;
}

free_program :: (program: Program) {
  array_free(program.memory);
}

run_intcode_program :: (program: *Program, input: (count: int) -> (int, bool) = null, output: (value: int) -> void = null) -> int, success: bool {
  while true {
    op := cast(OpCode) (program.memory[program.pc] % 100);

    if program.do_debug_print {
      if program.name  print("[%, pc: %] %\n", program.name, program.pc, op);
      else             print("[pc: %] %\n", program.pc, op);
    }

    if #complete op == {
      case OpCode.Addition;
        parameters := read_parameters(program, 3);
        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);
        set_value(program, parameters[2], p1 + p2);

        if program.do_full_debug_print  print("  memory[%] = % + %\n", get_value(program, parameters[2]), p1, p2);
        program.pc += 4;

      case OpCode.Multiplication;
        parameters := read_parameters(program, 3);
        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);
        set_value(program, parameters[2], p1 * p2);
        
        if program.do_full_debug_print  print("  memory[%] = % * %\n", get_value(program, parameters[2]), p1, p2);
        program.pc += 4;      

      case OpCode.Input;
        inp, exists := input(program.input_counter);
        if !exists {
          if program.do_full_debug_print  print("Could not get input... Waiting\n");
          return 0, false;
        }

        parameters := read_parameters(program, 1);
        set_value(program, parameters[0], inp);
        program.input_counter += 1;
        if program.do_print  print("  Input: %\n", inp);
        program.pc += 2;

      case OpCode.Output;
        parameters := read_parameters(program, 1);
        p1 := get_value(program, parameters[0]);
        if program.do_print  print("  Output: %\n", p1);
        if output  output(p1);
        program.pc += 2;

      case OpCode.JumpIfTrue;
        parameters := read_parameters(program, 2);
        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);

        if p1 != 0 {
          if program.do_full_debug_print  print("  (% != 0) => Jump to %\n", p1, p2);
          program.pc = p2;
        }
        else {
          if program.do_full_debug_print  print("  (% == 0) => No jump\n", p1);
          program.pc += 3;
        }

      case OpCode.JumpIfFalse;
        parameters := read_parameters(program, 2);
        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);

        if p1 == 0 {
          if program.do_full_debug_print  print("  (% == 0) => Jump to %\n", p1, p2);
          program.pc = p2;
        }
        else {
          if program.do_full_debug_print  print("  (% != 0) => No jump\n", p1);
          program.pc += 3;
        }

      case OpCode.LessThan;
        parameters := read_parameters(program, 3);

        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);

        if program.do_full_debug_print  print("  memory[%] = % < %\n", get_value(program, parameters[2]), p1, p2);
        if p1 < p2 {
          set_value(program, parameters[2], 1);
        }
        else {
          set_value(program, parameters[2], 0);
        }
        program.pc += 4;

      case OpCode.Equals;
        parameters := read_parameters(program, 3);

        p1 := get_value(program, parameters[0]);
        p2 := get_value(program, parameters[1]);

        if program.do_full_debug_print  print("  memory[%] = % == %\n", get_value(program, parameters[2]), p1, p2);
        if p1 == p2  set_value(program, parameters[2], 1);
        else         set_value(program, parameters[2], 0);
        program.pc += 4;

      case OpCode.SetRelativeBase;
        // SetRelativeBase only allows immediate mode
        parameters := read_parameters(program, 1);
        p1 := get_value(program, parameters[0]);
        if program.do_full_debug_print  print("  relative_base = % + %\n", program.relative_base, p1);
        program.relative_base += p1;
        program.pc += 2;

      case OpCode.Halt;
        break;
      case;
        return -1, true;
    }
  }

  return program.memory[0], true;
}


#scope_file

File :: #import "File";
String :: #import "String";

OpCode :: enum u32 {
  Addition :: 1;
  Multiplication :: 2;
  Input :: 3;
  Output :: 4;
  JumpIfTrue :: 5;
  JumpIfFalse :: 6;
  LessThan :: 7;
  Equals :: 8;
  SetRelativeBase :: 9;
  Halt :: 99;
}

ParameterMode :: enum u32 {
  Position :: 0;
  Immediate :: 1;
  Relative :: 2;
}

Parameter :: struct {
  value : int;
  mode : ParameterMode;
}

get_value :: (program: *Program, parameter: Parameter) -> int {
  if #complete parameter.mode == {
    case ParameterMode.Position;
      v := parameter.value;
      if v >= program.memory.count  array_resize(*program.memory, v + 1);

      return program.memory[parameter.value];
    case ParameterMode.Immediate;
      return parameter.value;
    case ParameterMode.Relative;
      v := program.relative_base + parameter.value;
      if v >= program.memory.count  array_resize(*program.memory, v + 1);
      
      return program.memory[program.relative_base + parameter.value];
  }
}

set_value :: (program: *Program, parameter: Parameter, value: int) {
  if #complete parameter.mode == {
    case ParameterMode.Position;
      v := parameter.value;
      if v >= program.memory.count  array_resize(*program.memory, v + 1);

      program.memory[v] = value;
    case ParameterMode.Immediate;
      assert(false, "Not allowed to use immediate mode to set values");
    case ParameterMode.Relative;
      v := program.relative_base + parameter.value;
      if v >= program.memory.count  array_resize(*program.memory, v + 1);

      program.memory[v] = value;
  }
}

read_parameters :: (program: *Program, n_parameters: int) -> []Parameter {
  parameters : [..]Parameter;
  parameters.allocator = __temporary_allocator;

  parameter_mode := program.memory[program.pc] / 100;
  for 1..n_parameters {
    param := program.memory[program.pc + it];
    mode := cast(ParameterMode) (parameter_mode % 10);
    parameter_mode = parameter_mode / 10;

    p : Parameter;
    p.value = param;
    p.mode = mode;
    array_add(*parameters, p);

    // value : int;
    // if #complete mode == {
    //   case ParameterMode.Position;
    //     if param >= program.memory.count {
    //       print("Resizing memory from % to %\n", program.memory.count, param);
    //       array_resize(*program.memory, param + 1);
    //     }
    //     value = program.memory[param];
    //   case ParameterMode.Immediate;
    //     value = param;
    //   case ParameterMode.Relative;
    //     position := param + program.relative_base;
    //     if position < 0  print("Illegal relative position % (%)\n", position, param);
    //     if position >= program.memory.count {
    //       print("Resizing memory from % to %\n", program.memory.count, position);
    //       array_resize(*program.memory, position + 1);
    //     }

    //     value = position;
    // }

    // array_add(*parameters, value);
  }

  return parameters;
}

unsafe_string_to_int :: (content: string) -> int {
  return string_to_int(content);
}

map :: (array: [] $T, func : (T) -> $R) -> []R {
  result : [..]R;
  // result.allocator = __temporary_allocator;
  for array {
    array_add(*result, func(it));
  }
  return result;
}
