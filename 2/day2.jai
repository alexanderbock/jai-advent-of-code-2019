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

  result := run_intcode_program(program, 12, 2);
  print("Value at position 0: %\n", result);

  for noun : 0..99 {
    for verb : 0..99 {
      res, success := run_intcode_program(program, noun, verb);
      if success && res == 19690720 {
        print("Found combination. Noun: %. Verb: %. Solution: %\n", noun, verb, 100 * noun + verb);
      }
    }
  }
}

run_intcode_program :: (orig_program: []int, noun: int, verb: int) -> int, success: bool {
  program : [..]int;
  array_copy(*program, orig_program);

  program[1] = noun;
  program[2] = verb;

  pc := 0;
  while true {
    OpCode :: enum u32 {
      Addition :: 1;
      Multiplication :: 2;
      Halt :: 99;
    }

    op := cast(OpCode) program[pc];

    if op == {
      case OpCode.Addition;
        address_op1 := program[pc + 1];
        if address_op1 >= program.count return 0, false;

        address_op2 := program[pc + 2];
        if address_op2 >= program.count return 0, false;

        address_res := program[pc + 3];
        if address_res >= program.count return 0, false;

        program[address_res] = program[address_op1] + program[address_op2];

      case OpCode.Multiplication;
        address_op1 := program[pc + 1];
        if address_op1 >= program.count return 0, false;

        address_op2 := program[pc + 2];
        if address_op2 >= program.count return 0, false;
        
        address_res := program[pc + 3];
        if address_res >= program.count return 0, false;
        
        program[address_res] = program[address_op1] * program[address_op2];

      case OpCode.Halt;
        break;
      case;
        return 0, false;
    }

    pc += 4;
  }

  return program[0], true;
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
