Program :: struct {
    name: string;
    memory: []int;
    pc : int;
    input_counter := 0;
    do_debug_print := true;
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

    if program.do_debug_print  print("[%, pc: %] %\n", program.name, program.pc, op);

    if #complete op == {
      case OpCode.Addition;
        parameters := read_parameters(program, 3);
        address := program.memory[program.pc + 3];
        program.memory[address] = parameters[0] + parameters[1];
        program.pc += 4;

      case OpCode.Multiplication;
        parameters := read_parameters(program, 2);
        address := program.memory[program.pc + 3];
        program.memory[address] = parameters[0] * parameters[1];
        program.pc += 4;      

      case OpCode.Input;
        inp, exists := input(program.input_counter);
        if !exists {
          if program.do_debug_print  print("Could not get input... Waiting\n");
          return 0, false;
        }

        address := program.memory[program.pc + 1];
        program.memory[address] = inp;
        program.input_counter += 1;
        if program.do_print  print("  Input: %\n", inp);
        program.pc += 2;

      case OpCode.Output;
        parameters := read_parameters(program, 1);
        if program.do_print  print("  Output: %\n", parameters[0]);
        if output  output(parameters[0]);
        program.pc += 2;

      case OpCode.JumpIfTrue;
        parameters := read_parameters(program, 2);
        if parameters[0] != 0  program.pc = parameters[1];
        else                   program.pc += 3;

      case OpCode.JumpIfFalse;
        parameters := read_parameters(program, 2);
        if parameters[0] == 0  program.pc = parameters[1];
        else                   program.pc += 3;      

      case OpCode.LessThan;
        parameters := read_parameters(program, 2);
        address := program.memory[program.pc + 3];
        if parameters[0] < parameters[1]  program.memory[address] = 1;
        else                              program.memory[address] = 0;
        program.pc += 4;

      case OpCode.Equals;
        parameters := read_parameters(program, 2);
        address := program.memory[program.pc + 3];
        if parameters[0] == parameters[1]  program.memory[address] = 1;
        else                               program.memory[address] = 0;
        program.pc += 4;

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
  Halt :: 99;
}

ParameterMode :: enum u32 {
  Position :: 0;
  Immediate :: 1;
}

read_parameters :: (program: *Program, n_parameters: int) -> []int {
  parameters : [..]int;
  parameters.allocator = __temporary_allocator;

  parameter_mode := program.memory[program.pc] / 100;
  for 1..n_parameters {
    param := program.memory[program.pc + it];
    mode := cast(ParameterMode) (parameter_mode % 10);
    parameter_mode = parameter_mode / 10;

    if (mode == ParameterMode.Position) && param >= program.memory.count {
      print("Encountered address outside program range: %", param);
    }
    value : int;
    if #complete mode == {
      case ParameterMode.Position;
        value = program.memory[param];
      case ParameterMode.Immediate;
        value = param;
    }

    array_add(*parameters, value);
  }

  return parameters;
}

unsafe_string_to_int :: (content: string) -> int {
  return string_to_int(content);
}

map :: (array: [] $T, func : (T) -> $R) -> [] R {
  result : [..]R;
  result.allocator = __temporary_allocator;
  for array {
    array_add(*result, func(it));
  }
  return result;
}
