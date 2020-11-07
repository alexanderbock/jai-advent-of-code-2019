#import "Basic";
Math :: #import "Math";
File :: #import "File";
String :: #import "String";


main :: () {
  content, success := File.read_entire_file("input");
  if !success {
    print("Error loading file\n");
  }

  string_values := split_by_newline(content);

  total_fuel := 0;
  total_recursive_fuel := 0;
  for string_values {
    mass := string_to_int(it);

    fuel := fuel_for_mass(mass);
    total_fuel += fuel;

    recursive_fuel := fuel_for_mass_recursive(mass);
    total_recursive_fuel += recursive_fuel;
  }

  print("Total Fuel: %\n", total_fuel);
  print("Total Recursive Fuel: %\n", total_recursive_fuel);
}

split_by_newline :: #bake_arguments String.split(separator = "\n");

fuel_for_mass :: (mass: int) -> int {
  m := cast(float) mass;
  return cast(int) Math.floor(m / 3.0) - 2;
}

fuel_for_mass_recursive :: (mass: int) -> int {
  f := fuel_for_mass(mass);
  if f <= 0 {
    return 0;
  }
  else {
    return f + fuel_for_mass_recursive(f);
  }
}

// First version
/*
main :: () {
  content, success := File.read_entire_file("input");
  if !success {
    print("Error loading file\n");
  }

  string_values := split_by_newline(content);
  mass_values := map(string_values, unsafe_string_to_int);
  fuel_values := map(mass_values, fuel_for_mass);
  total_fuel := accumulate(fuel_values, 0);
  print("Total Fuel: %\n", total_fuel);

  recursive_fuel_values := map(mass_values, fuel_for_mass_recursive);
  recursive_total_fuel := accumulate(recursive_fuel_values, 0);
  print("Total recursive Fuel: %\n", recursive_total_fuel);
}



unsafe_string_to_int :: (content: string) -> int {
  return string_to_int(content);
}

accumulate :: (array: [] $T, initial_value: T) -> T {
  res := initial_value;
  for array {
    res += it;
  }
  return res;
}

map :: (array: [] $T, func : (T) -> $R) -> [] R {
  result : [..]R;
  result.allocator = __temporary_allocator;
  for array {
    array_add(*result, func(it));
  }
  return result;
}

// Actual way using the std
// split_by_newline :: #bake_arguments String.split(separator = "\n");
split_by_newline :: (content: string) -> [] string {
  result : [..]string;
  result.allocator = __temporary_allocator;

  cnt := content;
  idx, found := String.index_of_string(cnt, "\n");
  while found {
    str := String.slice(cnt, 0, idx);
    array_add(*result, str);

    cnt = String.slice(cnt, idx + 1, cnt.count - (idx + 1));

    idx, found = String.index_of_string(cnt, "\n");
  }

  return result;
}
*/

#run main();
