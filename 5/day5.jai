#import "Basic";
File :: #import "File";
String :: #import "String";
CMD :: #import "Command_Line";

Program : [..]int;
pc := 0;

main :: () {
  Configuration :: struct {
    file : string = "input";
    input : int = 0;
  }

  success, conf := CMD.parse_arguments(Configuration);

  file_content, file_success := File.read_entire_file(conf.file);
  if !file_success {
    print("Error loading file\n");
  }

  string_values := String.split(file_content, ",");
  Program = map(string_values, unsafe_string_to_int);

  result := run_intcode_program(conf.input);
  print("\n");
  // print("Result: %\n", result);
}



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

run_intcode_program :: (input: int) -> int, success: bool {
  while true {
    op := cast(OpCode) (Program[pc] % 100);

    print("[pc: %] %\n", pc, op);

    if #complete op == {
      case OpCode.Addition;
        parameters := read_parameters(3);
        address := Program[pc + 3];
        Program[address] = parameters[0] + parameters[1];
        pc += 4;

      case OpCode.Multiplication;
        parameters := read_parameters(2);
        address := Program[pc + 3];
        Program[address] = parameters[0] * parameters[1];
        pc += 4;      

      case OpCode.Input;
        address := Program[pc + 1];
        Program[address] = input;
        print("  Input: %\n", input);
        pc += 2;

      case OpCode.Output;
        parameters := read_parameters(1);
        print("  Output: %\n", parameters[0]);
        pc += 2;

      case OpCode.JumpIfTrue;
        parameters := read_parameters(2);
        if parameters[0] != 0  pc = parameters[1];
        else                   pc += 3;

      case OpCode.JumpIfFalse;
        parameters := read_parameters(2);
        if parameters[0] == 0  pc = parameters[1];
        else                   pc += 3;      

      case OpCode.LessThan;
        parameters := read_parameters(2);
        address := Program[pc + 3];
        if parameters[0] < parameters[1]  Program[address] = 1;
        else                              Program[address] = 0;
        pc += 4;

      case OpCode.Equals;
        parameters := read_parameters(2);
        address := Program[pc + 3];
        if parameters[0] == parameters[1]  Program[address] = 1;
        else                               Program[address] = 0;
        pc += 4;

      case OpCode.Halt;
        break;
      case;
        return 0, false;
    }
  }

  return Program[0], true;
}

read_parameters :: (n_parameters: int) -> []int {
  parameters : [..]int;
  parameters.allocator = __temporary_allocator;

  parameter_mode := Program[pc] / 100;
  for 1..n_parameters {
    param := Program[pc + it];
    mode := cast(ParameterMode) (parameter_mode % 10);
    parameter_mode = parameter_mode / 10;

    if (mode == ParameterMode.Position) && param >= Program.count {
      print("Encountered address outside program range: %", param);
    }
    value : int;
    if #complete mode == {
      case ParameterMode.Position;
        value = Program[param];
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

map :: (array: [] $T, func : (T) -> $R) -> [..] R {
  result : [..]R;
  result.allocator = __temporary_allocator;
  for array {
    array_add(*result, func(it));
  }
  return result;
}

// #run main();
