#import "Basic";
CMD :: #import "Command_Line";
File :: #import "File";
String :: #import "String";
Debug :: #import "Debug";

Node_Storage : [..]Node;

main :: () {
  Node_Storage.allocator = __temporary_allocator;
  // Debug.attach_to_debugger();

  Configuration :: struct {
    // file : string = "test1";
    file : string = "input";
  }

  success, conf := CMD.parse_arguments(Configuration);
  if !success {
    print("Error parsing commandline\n");
  }

  file_content, file_success := File.read_entire_file(conf.file);
  if !file_success {
    print("Error loading file\n");
  }

  orbits := String.split(file_content, "\n");

  // First create all the nodes
  for orbits {
    parent_name, child_name := split_nodes(it);
    if parent_name == "" || child_name == ""  continue;

    node_parent := find_node(parent_name);
    if !node_parent  create_new_node(parent_name);
    node_child := find_node(child_name);
    if !node_child  create_new_node(child_name);
  }

  // Now that all nodes exist, we connect them
  for orbits {
    parent_name, child_name := split_nodes(it);
    if parent_name == "" || child_name == ""  continue;

    node_parent := find_node(parent_name);
    node_child := find_node(child_name);

    array_add(*node_parent.nodes, node_child);
    node_child.parent = node_parent;
  }

  sum := 0;
  for Node_Storage {
    sum += node_depth(*it);
  }
  print("Total number of orbits: %\n", sum);

  if conf.file == "test1" {
    print("H->I: %\n", compute_number_of_transfers(find_node("H"), find_node("I")));
    print("K->I: %\n", compute_number_of_transfers(find_node("K"), find_node("I")));
  }

  if conf.file == "input" {
    you := find_node("YOU");
    san := find_node("SAN");

    print("YOU->SAN: %\n", compute_number_of_transfers(you.parent, san.parent));
  }
}

Node :: struct {
  name : string;
  parent : *Node;
  nodes : [..]*Node;
}

create_new_node :: (name : string) -> *Node {
  n : Node;
  n.name = name;
  array_add(*Node_Storage, n);
  return *Node_Storage[Node_Storage.count - 1];
}

find_node :: (name : string) -> *Node {
  for 0..Node_Storage.count-1 {
    if Node_Storage[it].name == name {
      return *Node_Storage[it];
    }
  }
  return null;
}

node_depth :: (node : *Node) -> int {
  res := 0;
  n := node;
  while n.parent {
    n = n.parent;
    res += 1;
  }

  return res;
}

compute_number_of_transfers :: (src: *Node, dst: *Node) -> int {
  root := find_common_root(src, dst);

  d1 := find_direct_transfer(src, root);
  d2 := find_direct_transfer(dst, root);

  return d1.count + d2.count + 2;
}

find_common_root :: (src: *Node, dst: *Node) -> *Node {
  src_path := find_direct_transfer(src);
  dst_path := find_direct_transfer(dst);

  larger_path : []*Node;
  smaller_path : []*Node;
  if src_path.count >= dst_path.count {
    larger_path = src_path;
    smaller_path = dst_path;
  }
  else {
    larger_path = dst_path;
    smaller_path = src_path;
  }

  larger_it := larger_path.count - 1;
  while true {
    larger_val := larger_path[larger_it];

    found := array_find(smaller_path, larger_val);
    if !found {
      larger_it += 1;
      break;
    }

    larger_it -= 1;
  }

  return larger_path[larger_it];

}

find_direct_transfer :: (src: *Node, dst: *Node = null) -> []*Node {
  res : [..]*Node;
  res.allocator = __temporary_allocator;
  n := src.parent;
  while n != dst {
    array_add(*res, n);
    n = n.parent;
  }
  return res;
}

split_nodes :: (line : string) -> (string, string) {
  components := String.split(line, ")");
  if components.count == 0  return "", "";

  return components[0], components[1];
}

node_list_to_name :: (nodes : []*Node) -> []string {
  res : [..]string;
  res.allocator = __temporary_allocator;
  for nodes {
    array_add(*res, it.name);
  }
  return res;
}

#run main();
