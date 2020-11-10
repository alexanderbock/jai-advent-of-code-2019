#import "Basic";

FILE :: "input";

main :: () {
  orig_program, success := read_program(FILE);
  if !success  print("Failed program\n");
  orig_program.do_debug_print = false;

  print("Part 1:\n");
  program_1 := copy_program(orig_program);
  run_intcode_program(*program_1, (c : int) -> (int, bool) { return 1, true; });

  print("Part 2:\n");
  program_2 := copy_program(orig_program);
  run_intcode_program(*program_2, (c : int) -> (int, bool) { return 2, true; });
}

#run main();
