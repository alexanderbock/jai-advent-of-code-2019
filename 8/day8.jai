#import "Basic";
File :: #import "File";
Math :: #import "Math";
String :: #import "String";

// WIDTH :: 3;
// HEIGHT :: 2;
// FILE :: "test1";

WIDTH :: 25;
HEIGHT :: 6;
FILE :: "input";

full_data : [..]u8;

main :: () {
  file_content, success := File.read_entire_file(FILE);
  if !success  print("Error reading file\n");

  array_resize(*full_data, file_content.count);
  for 0..file_content.count-1 {
    full_data[it] = cast(u8) string_to_int(String.slice(file_content, it, 1));
  }

  print("Number of layers: %\n", number_of_layers());

  layer_with_fewest_0s := -1;
  fewest_0s_found := Math.S64_MAX;
  for 0..number_of_layers()-1 {
    layer := extract_layer(it);
    number_of_0s := number_of_digits_in_layer(layer, 0);
    if number_of_0s < fewest_0s_found {
      fewest_0s_found = number_of_0s;
      layer_with_fewest_0s = it;
    }
  }

  print("Layer with fewest 0s: %  (% of em)\n", layer_with_fewest_0s, fewest_0s_found);
  number_of_1s := number_of_digits_in_layer(extract_layer(layer_with_fewest_0s), 1);
  number_of_2s := number_of_digits_in_layer(extract_layer(layer_with_fewest_0s), 2);
  print("Number of 1s in layer: %\n", number_of_1s);
  print("Number of 2s in layer: %\n", number_of_2s);

  print("\nSolution Part 1: %\n\n", number_of_1s * number_of_2s);

  image := create_combined_image();
  for y : 0..HEIGHT-1 {
    for x : 0..WIDTH-1 {
      v := image[y * WIDTH + x];
      if v == 0  print(" ");
      else       print("X"); 
    }
    print("\n");
  }
}

number_of_layers :: () -> int {
  return full_data.count / (WIDTH * HEIGHT);
}

number_of_digits_in_layer :: (layer: []u8, digit: int) -> int {
  number := 0;
  for layer {
    if it == digit  number += 1;
  }
  return number;
}

extract_layer :: (layer: int) -> []u8 {
  res : []u8;
  res.count = WIDTH*HEIGHT;
  res.data = full_data.data + (layer * WIDTH * HEIGHT);
  return res;
}

create_combined_image :: () -> []u8 {
  res : [..]u8;
  res.allocator = __temporary_allocator;
  array_resize(*res, WIDTH * HEIGHT);
  for 0..(WIDTH*HEIGHT)-1  res[it] = 2;

  for l : 0..number_of_layers()-1 {
    layer := extract_layer(l);
    for y : 0..HEIGHT-1 {
      for x : 0..WIDTH-1 {
        idx := y * WIDTH + x;
        if res[idx] == 2  res[idx] = layer[idx];
      }
    }
  }

  return res;
}

#run main();
