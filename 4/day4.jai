#import "Basic";

main :: () {
  lower_range :: 356261;
  upper_range :: 846303;

  count := 0;
  for lower_range..upper_range {
    number := tprint("%", it);

    if !has_adjacent_digits(number)  continue;
    if !has_monotonic_digits(number)  continue;
  
    print("%\n", it);
    count = count + 1;
  }

  print("Number of passwords: %\n", count);
}

has_adjacent_digits :: (number : string) -> bool {
  digit := 0;
  count := 0;
  for i : 0..number.count-1 {
    it := number[i];
    if it == digit {
      count = count + 1;
    }
    else {
      if count == 2  return true;

      digit = it;
      count = 1;
    }
  }

  if count == 2  return true;
  else return false;
}

has_monotonic_digits :: (number : string) -> bool {
  for i : 0..number.count-2 {
    if number[i] > number[i+1]  return false;
  }
  return true;
}

#run main();
