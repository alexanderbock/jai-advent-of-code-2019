#import "Basic";
File :: #import "File";
String :: #import "String";

main :: () {
  orig_program, success := read_program("input");

  program := copy_program(orig_program);
  program.memory[1] = 12;
  program.memory[2] = 2;
  result := run_intcode_program(*program);
  print("Value at position 0: %\n", result);

  for noun : 0..99 {
    for verb : 0..99 {
      program := copy_program(orig_program);
      defer free_program(program);
      program.memory[1] = noun;
      program.memory[2] = verb;
      program.do_debug_print = false;      
      res, success := run_intcode_program(*program);
      if success && res == 19690720 {
        print("Found combination. Noun: %. Verb: %. Solution: %\n", noun, verb, 100 * noun + verb);
      }
    }
  }
}

#run main();
