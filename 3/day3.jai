#import "Basic";
File :: #import "File";
String :: #import "String";
Math :: #import "Math";

Wire :: struct {
  steps : [..]Step;
  visited_points : [..]Point;
}

Step :: struct {
    Direction :: enum u8 {
        Up;
        Down;
        Left;
        Right;
    }

    direction : Direction;
    steps : int;
}

Point :: struct {
  x : int;
  y : int;

  distance : int;
}

main :: () {
  content, success := File.read_entire_file("input");
  if !success {
    print("Error loading file\n");
  }

  string_values := String.split(content, "\n");
  first_wire := handle_wire(string_values[0]);
  second_wire := handle_wire(string_values[1]);

  intersections := compute_intersections(first_wire, second_wire);

  closest_intersection_manhattan_distance : s64 = Math.S64_MAX;
  for intersections {
    if it.x == 0 && it.y == 0  continue;
    d := Math.abs(it.x) + Math.abs(it.y);
    if d < closest_intersection_manhattan_distance  closest_intersection_manhattan_distance = d;
  }
  print("Closest intersection manhattan distance: %\n\n", closest_intersection_manhattan_distance);


  closest_intersection_wire_distance : s64 = Math.S64_MAX;
  for intersections {
    print("Intersection\n");
    if it.x == 0 && it.y == 0  continue;

    first_distance : s64 = Math.S64_MAX;
    found_first_distance := false;
    for p : first_wire.visited_points {
      if it.x == p.x && it.y == p.y && p.distance < first_distance {
        first_distance = p.distance;
        found_first_distance = true;
        print("%: % -> %\n", p, it, first_distance);
      }
    }
    print("Found first: %\n", found_first_distance);

    second_distance : s64 = Math.S64_MAX;
    found_second_distance := false;
    for p : second_wire.visited_points {
      if it.x == p.x && it.y == p.y  && p.distance < second_distance {
        second_distance = p.distance;
        found_second_distance = true;
      }
    }
    print("Found second: %\n", found_second_distance);

    distance := first_distance + second_distance;
    if distance < closest_intersection_wire_distance {
      closest_intersection_wire_distance = distance;
    }
  }
  print("Closest intersection wire distance: %\n\n", closest_intersection_wire_distance);
}

compute_intersections :: (first: Wire, second: Wire) -> []Point {
  res : [..]Point;
  res.allocator = __temporary_allocator;

  min_x, min_y : s64 = Math.S64_MAX, Math.S64_MAX;
  max_x, max_y : s64 = Math.S64_MIN, Math.S64_MIN;
  for first.visited_points {
    if it.x < min_x  min_x = it.x;
    if it.x > max_x  max_x = it.x;
    if it.y < min_y  min_y = it.y;
    if it.y > max_y  max_y = it.y;
  }
  for second.visited_points {
    if it.x < min_x  min_x = it.x;
    if it.x > max_x  max_x = it.x;
    if it.y < min_y  min_y = it.y;
    if it.y > max_y  max_y = it.y;
  }

  size_x := max_x - min_x;
  size_y := max_y - min_y;

  area : [..]bool;
  area.allocator = __temporary_allocator;
  array_resize(*area, (size_x + 1) * (size_y + 1));

  for first.visited_points {
    idx_x := it.x + Math.abs(min_x);
    idx_y := it.y + Math.abs(min_y);
    idx := idx_x + idx_y * size_x;

    area[idx] = true;
  }

  for second.visited_points {
    idx_x := it.x + Math.abs(min_x);
    idx_y := it.y + Math.abs(min_y);    
    idx := idx_x + idx_y * size_x;

    if area[idx] {
      p : Point;
      p.x = it.x;
      p.y = it.y;
      p.distance = 0;
      array_add(*res, p);
    }
  }

  return res;
}


handle_wire :: (text : string) -> Wire {
  wire : Wire;
  wire.steps.allocator = __temporary_allocator;
  wire.visited_points.allocator = __temporary_allocator;

  values := String.split(text, ",");
  for (values)  {
    direction_string := String.slice(it, 0, 1);
    steps_string := String.slice(it, 1, it.count);

    step : Step;
    step.steps = string_to_int(steps_string);
    if direction_string == {
        case "U"; step.direction = Step.Direction.Up;
        case "D"; step.direction = Step.Direction.Down;
        case "L"; step.direction = Step.Direction.Left;
        case "R"; step.direction = Step.Direction.Right;
        case; print("Unknown direction %\n", direction_string);
    }

    array_add(*wire.steps, step);
  }

  current_point : Point;
  for wire.steps {
    delta_x, delta_y : int;

    if #complete it.direction == {
      case Step.Direction.Up;    delta_y = -1;
      case Step.Direction.Down;  delta_y =  1;
      case Step.Direction.Left;  delta_x = -1;
      case Step.Direction.Right; delta_x =  1;
    }

    for 0..it.steps-1 {
      array_add(*wire.visited_points, current_point);
      current_point.x = current_point.x + delta_x;
      current_point.y = current_point.y + delta_y;
      current_point.distance = current_point.distance + 1;
    }
  }

  return wire;
}

#run main();
