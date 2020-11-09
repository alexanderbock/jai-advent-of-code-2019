#import "Basic";

PhaseSetting :: struct {
  a : int;
  b : int;
  c : int;
  d : int;
  e : int;
}
current_setting : PhaseSetting;

input_signal :: 0;
Output :: struct {
  a : [..]int;
  b : [..]int;
  c : [..]int;
  d : [..]int;
  e : [..]int;
}
output_storage : Output;


main :: () {
  orig_program, success := read_program("input");
  if !success  print("Failed program\n");
  orig_program.do_debug_print = false;
  orig_program.do_print = false;

  Result :: struct {
    thruster_setting: int;
    phase_setting: PhaseSetting;
  }
  thruster_settings : [..]Result;
  thruster_settings.allocator = __temporary_allocator;

  for PhaseSettings {
    res : Result;
    res.thruster_setting = run_program(orig_program, it);
    res.phase_setting = it;
    array_add(*thruster_settings, res);
  }

  max_thruster_setting : Result;
  for thruster_settings {
    if it.thruster_setting > max_thruster_setting.thruster_setting  max_thruster_setting = it;
  }
  print("Max thruster settings: %\n", max_thruster_setting);
}

run_program :: (orig_program: Program, setting: PhaseSetting) -> int {
  current_setting = setting;
  array_reset(*output_storage.a);
  array_reset(*output_storage.b);
  array_reset(*output_storage.c);
  array_reset(*output_storage.d);
  array_reset(*output_storage.e);

  array_add(*output_storage.e, 0);

  amplifier_a := copy_program(orig_program);
  amplifier_a.name = "A";
  defer free_program(amplifier_a);

  amplifier_b := copy_program(orig_program);
  amplifier_b.name = "B";
  defer free_program(amplifier_b);

  amplifier_c := copy_program(orig_program);
  amplifier_c.name = "C";
  defer free_program(amplifier_c);

  amplifier_d := copy_program(orig_program);
  amplifier_d.name = "D";
  defer free_program(amplifier_d);  

  amplifier_e := copy_program(orig_program);
  amplifier_e.name = "E";
  defer free_program(amplifier_e);  

  while true {
    run_intcode_program(*amplifier_a, #bake_arguments provide_input(amplifier = "A"), #bake_arguments consume_output(amplifier = "A"));
    run_intcode_program(*amplifier_b, #bake_arguments provide_input(amplifier = "B"), #bake_arguments consume_output(amplifier = "B"));
    run_intcode_program(*amplifier_c, #bake_arguments provide_input(amplifier = "C"), #bake_arguments consume_output(amplifier = "C"));
    run_intcode_program(*amplifier_d, #bake_arguments provide_input(amplifier = "D"), #bake_arguments consume_output(amplifier = "D"));
    v, terminated := run_intcode_program(*amplifier_e, #bake_arguments provide_input(amplifier = "E"), #bake_arguments consume_output(amplifier = "E"));
    if terminated  break;
  }

  return output_storage.e[output_storage.e.count - 1];
}

provide_input :: (count: int, amplifier: string) -> (int, bool) {
  c := count - 1;

  values : []int;
  if amplifier == {
    case "A";
      if count == 0  return current_setting.a, true;
      else        values = output_storage.e;
    case "B";
      if count == 0  return current_setting.b, true;
      else        values = output_storage.a;
    case "C";
      if count == 0  return current_setting.c, true;
      else        values = output_storage.b;
    case "D";
      if count == 0  return current_setting.d, true;
      else        values = output_storage.c;
    case "E";
      if count == 0  return current_setting.e, true;
      else        values = output_storage.d;
    case;
      assert(false);
      return -1, false;
  }

  assert(count >= 1, tprint("%", count));
  if values.count < count  return -1, false;
  else                     return values[count - 1], true;
}

consume_output :: (value: int, amplifier: string) {
  if amplifier == {
    case "A";  array_add(*output_storage.a, value);
    case "B";  array_add(*output_storage.b, value);
    case "C";  array_add(*output_storage.c, value);
    case "D";  array_add(*output_storage.d, value);
    case "E";  array_add(*output_storage.e, value);
    case;      assert(false);
  }
}


#insert #run (name: string, low: int, high: int) -> string {
  builder: String_Builder;
  defer free_buffers(*builder);

  print_to_builder(*builder, "% :: PhaseSetting.[\n", name);

  for a : low..high {
    for b : low..high {
      if b == a  continue;

      for c : low..high {
        if c == a || c == b  continue;

        for d : low..high {
          if d == a || d == b || d == c  continue;

          for e : low..high {
            if e == a || e == b || e == c || e == d  continue;

            print_to_builder(*builder, "  .{%, %, %, %, %},\n", a, b, c, d, e);
          }
        }
      }
    }
  }

  print_to_builder(*builder, "];");
  return builder_to_string(*builder);
// }("PhaseSettings", 0, 4);
}("PhaseSettings", 5, 9);

#run main();
