#import "Basic";
CMD :: #import "Command_Line";
File :: #import "File";
String :: #import "String";

Configuration :: struct {
  file : string = "input";
  input : int = 0;
}
conf : Configuration;

read_input :: (count: int) -> int {
  return conf.input;
}

main :: () {
  success : bool;
  success, conf = CMD.parse_arguments(Configuration);
  if !success {
    print("Error parsing commandline\n");
  }
  program := read_program(conf.file);

  run_intcode_program(*program, read_input);
  print("\n");
}

#run main();
