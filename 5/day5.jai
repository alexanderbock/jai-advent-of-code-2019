#import "Basic";
File :: #import "File";
String :: #import "String";

main :: () {
  content, success := File.read_entire_file("input");
  if !success {
    print("Error loading file\n");
  }

  string_values := String.split(content, ",");
  program := map(string_values, unsafe_string_to_int);

  result := run_intcode_program(program, -1, -1, 1);
}

OpCode :: enum u32 {
  Addition :: 1;
  Multiplication :: 2;
  Input :: 3;
  Output :: 4;
  Halt :: 99;
}

ParameterMode :: enum u32 {
  Position :: 0;
  Immediate :: 1;
}

run_intcode_program :: (orig_program: []int, noun: int, verb: int, input: int) -> int, success: bool {
  program : [..]int;
  array_copy(*program, orig_program);

  if noun != -1  program[1] = noun;
  if verb != -1  program[2] = verb;

  pc := 0;
  counter := 0;
  while true {
    // OpCode is in the last two digits
    op := cast(OpCode) (program[pc] % 100);
    parameter_mode := program[pc] / 100;


    // if counter == 5 break;
    // counter += 1;

    // print("% % %  ", pc, op, parameter_mode);

    if #complete op == {
      case OpCode.Addition;
        success := two_parameter_op(program, pc, parameter_mode, (l: int, r: int) -> int { return l + r; });
        if !success  return 0, false;
        pc += 4;

      case OpCode.Multiplication;
        success := two_parameter_op(program, pc, parameter_mode, (l: int, r: int) -> int { return l * r; });
        if !success  return 0, false;
        pc += 4;

      case OpCode.Input;
        assert(parameter_mode == 0);
        op1 := program[pc + 1];
        // print("op1: %  ", op1);
        program[op1] = input;
        // print("program[op1]: %", program[op1]);
        pc += 2;

      case OpCode.Output;
        op1 := program[pc + 1];
        op1_mode := cast(ParameterMode) (parameter_mode % 10);
        parameter_mode = parameter_mode / 10;

        if (op1_mode == ParameterMode.Position) && op1 >= program.count {
          return 0, false;
        }
        op1_value : int;
        if #complete op1_mode == {
          case ParameterMode.Position;
            op1_value = program[op1];
          case ParameterMode.Immediate;
            op1_value = op1;
        }

        print("Output: %\n", op1_value);
        pc += 2;

      case OpCode.Halt;
        break;
      case;
        return 0, false;
    }

    // print("\n");
  }

  return program[0], true;
}

two_parameter_op :: (program: [..]int, pc: int, parameter_mode: int, func: (int, int) -> int) -> bool {
    op1 := program[pc + 1];
    // print("op1: %  ", op1);
    op1_mode := cast(ParameterMode) (parameter_mode % 10);
    // print("op1_mode: %  ", op1_mode);
    parameter_mode = parameter_mode / 10;

    if (op1_mode == ParameterMode.Position) && op1 >= program.count {
      return false;
    }
    op1_value : int;
    if #complete op1_mode == {
      case ParameterMode.Position;
        op1_value = program[op1];
      case ParameterMode.Immediate;
        op1_value = op1;
    }


    op2 := program[pc + 2];
    // print("op2: %  ", op2);
    op2_mode :=  cast(ParameterMode) (parameter_mode % 10);
    // print("op2_mode: %  ", op2_mode);
    parameter_mode = parameter_mode / 10;

    if (op2_mode == ParameterMode.Position) && op2 >= program.count {
      return false;
    }
    op2_value : int;
    if #complete op2_mode == {
      case ParameterMode.Position;
        op2_value = program[op2];
      case ParameterMode.Immediate;
        op2_value = op2;
    }        

    res := program[pc + 3];
    // print("res: %  ", res);
    assert(parameter_mode == 0);
    if res >= program.count  return false;

    program[res] = func(op1_value, op2_value);
    return true;
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

#run main();
