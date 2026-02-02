///|
using @list {type List}

///|
test "Lens::new get set" {
  let lens : Lens[(Int, Int), Int] = Lens::new(
    fn(pair) { pair.0 },
    fn(pair, v) { (v, pair.1) },
  )
  let pair = (1, 2)
  inspect(lens.get(pair), content="1")
  inspect(lens.set(pair, 3), content="(3, 2)")
}

///|
test "Lens::compose" {
  let l1 : Lens[((Int, Int), Int), (Int, Int)] = Lens::fst()
  let l2 : Lens[(Int, Int), Int] = Lens::snd()
  let composed = l1.compose(l2)
  let data = ((1, 2), 3)
  inspect(composed.get(data), content="2")
  inspect(composed.set(data, 4), content="((1, 4), 3)")
}

///|
test "Lens::to_prism" {
  let lens = Lens::fst()
  let prism = lens.to_prism()
  let data = (1, 2)
  inspect(prism.get(data), content="Some(1)")
  inspect(prism.set(data, 3), content="(3, 2)")
}

///|
test "Lens::from_iso" {
  let iso = Iso::new(fn(x) { x + 1 }, fn(x) { x - 1 })
  let lens = Lens::from_iso(iso)
  inspect(lens.get(1), content="2")
  inspect(lens.set(1, 4), content="3") // iso.from(4) = 3
}

///|
test "Prism::some" {
  let prism = Prism::some()
  inspect(prism.get(Some(1)), content="Some(1)")
  inspect(prism.get(None), content="None")
  inspect(prism.set(Some(1), 2), content="Some(2)")
  inspect(prism.set(None, 2), content="Some(2)")
}

///|
test "Prism::ok" {
  let prism : Prism[Result[Int, String], Int] = Prism::ok()
  inspect(prism.get(Ok(1)), content="Some(1)")
  inspect(prism.get(Err("error")), content="None")
  inspect(prism.set(Ok(1), 2), content="Ok(2)")
  inspect(prism.set(Err("error"), 2), content="Ok(2)")
}

///|
test "Prism::err" {
  let prism : Prism[Result[Int, String], String] = Prism::err()
  inspect(prism.get(Err("error")), content="Some(\"error\")")
  inspect(prism.get(Ok(1)), content="None")
  inspect(prism.set(Err("error"), "new error"), content="Err(\"new error\")")
}

///|
test "Prism::from_epi" {
  let epi = Epi::new(
    fn(x : Int) { if x > 0 { Some(x) } else { None } }, // to: only positive
    fn(x : Int) { x }, // from: identity
  )
  let prism = Prism::from_epi(epi)
  inspect(prism.get(1), content="Some(1)")
  inspect(prism.get(-1), content="None")
  inspect(prism.set(-1, 5), content="5")
}

///|
test "Iso::invert" {
  let iso = Iso::new(fn(x) { x + 1 }, fn(x) { x - 1 })
  inspect(iso.to(1), content="2")
  inspect(iso.from(2), content="1")
  let inverted = iso.invert()
  inspect(inverted.to(2), content="1")
  inspect(inverted.from(1), content="2")
}

///|
test "Iso::compose" {
  let i1 = Iso::new(fn(x) { x + 1 }, fn(x) { x - 1 })
  let i2 = Iso::new(fn(x) { x * 2 }, fn(x) { x / 2 })
  let composed = i1.compose(i2)
  // (x + 1) * 2
  inspect(composed.to(1), content="4")
  // (4 / 2) - 1 = 1
  inspect(composed.from(4), content="1")
}

///|
test "Iso::to_epi" {
  let iso = Iso::new(fn(x) { x + 1 }, fn(x) { x - 1 })
  let epi = iso.to_epi()
  inspect(epi.to(1), content="Some(2)")
  inspect(epi.from(2), content="1")
}

///|
test "Prism::array_nth" {
  let arr = [1, 2, 3]
  let prism = Prism::array_nth(1)
  inspect(prism.get(arr), content="Some(2)")
  inspect(prism.set(arr, 4), content="[1, 4, 3]")

  let oob = Prism::array_nth(5)
  inspect(oob.get(arr), content="None")
}

///|
test "Prism::list_head" {
  let list = @list.from_array([1, 2, 3])
  let prism = Prism::list_head()
  inspect(prism.get(list), content="Some(1)")
  inspect(prism.set(list, 0), content="@list.from_array([0, 2, 3])")

  inspect(prism.get(@list.empty()), content="None")
}

///|
test "Prism::list_tail" {
  let list = @list.from_array([1, 2, 3])
  let prism = Prism::list_tail()
  inspect(prism.get(list), content="Some(@list.from_array([2, 3]))")
  inspect(prism.set(list, @list.from_array([4, 5])), content="@list.from_array([1, 4, 5])")
}

///|
test "Prism::list_nth" {
  let list = @list.from_array([1, 2, 3])
  let prism = Prism::list_nth(1)
  inspect(prism.get(list), content="Some(2)")
  inspect(prism.set(list, 5), content="@list.from_array([1, 5, 3])")

  let oob = Prism::list_nth(5)
  inspect(oob.get(list), content="None")
  // Check set on oob - implementation returns reversed accumulator (the whole list if index not found)
  inspect(oob.set(list, 9), content="@list.from_array([1, 2, 3])")
}

///|
test "Prism::map" {
  let map : Map[String, Int] = {"a": 1, "b": 2}
  let prism = Prism::map("a")
  inspect(prism.get(map), content="Some(1)")
  inspect(prism.set(map, 3), content="{\"a\": 3, \"b\": 2}")
  
  let prism_missing = Prism::map("c")
  inspect(prism_missing.get(map), content="None")
  // Setting a missing key adds it because implementation uses new_map[key] = a
  inspect(prism_missing.set(map, 4), content="{\"a\": 1, \"b\": 2, \"c\": 4}")
}

///|
test "Prism::immut_hashmap" {
  let hm = @hashmap.new().add("key", "value")
  let prism = Prism::immut_hashmap("key")
  
  inspect(prism.get(hm), content="Some(\"value\")")
  let updated = prism.set(hm, "new_value")
  inspect(updated.get("key"), content="Some(\"new_value\")")
  
  let prism_missing = Prism::immut_hashmap("missing")
  inspect(prism_missing.get(hm), content="None")
  let added = prism_missing.set(hm, "added")
  inspect(added.get("missing"), content="Some(\"added\")")
}

///|
test "Prism::immut_sorted_map" {
  let sm = @sorted_map.new().add(1, "one")
  let prism = Prism::immut_sorted_map(1)
  
  inspect(prism.get(sm), content="Some(\"one\")")
  let updated = prism.set(sm, "ONE")
  inspect(updated.get(1), content="Some(\"ONE\")")
  
  let prism_missing = Prism::immut_sorted_map(2)
  inspect(prism_missing.get(sm), content="None")
  let added = prism_missing.set(sm, "two")
  inspect(added.get(2), content="Some(\"two\")")
}

///|
test "Lens::id" {
  let lens : Lens[Int, Int] = Lens::id()
  inspect(lens.get(1), content="1")
  inspect(lens.set(1, 2), content="2")
}

///|
test "Prism::new" {
  let prism = Prism::new(
    fn(x : Int) { if x > 0 { Some(x) } else { None } },
    fn(_x, v) { v }
  )
  inspect(prism.get(1), content="Some(1)")
  inspect(prism.get(-1), content="None")
  inspect(prism.set(1, 2), content="2")
}

///|
test "Prism::compose" {
  let p1 = Prism::some()
  let p2 = Prism::ok() // Prism[Result[Int, E], Int]
  // We need distinct types to test composition properly or just reuse existing ones.
  // Let's compose Prism[Option[Result[Int, String]], Result[Int, String]] (p1)
  // with Prism[Result[Int, String], Int] (p2)
  // Resulting Prism[Option[Result[Int, String]], Int]
  
  let composed = p1.compose(p2)
  
  let data : Result[Int, String]? = Some(Ok(1))
  inspect(composed.get(data), content="Some(1)")
  
  let data_none : Result[Int, String]? = None
  inspect(composed.get(data_none), content="None")
  
  let data_err : Result[Int, String]? = Some(Err("err"))
  inspect(composed.get(data_err), content="None")
  
  inspect(composed.set(data, 2), content="Some(Ok(2))")
  inspect(composed.set(data_none, 2), content="None") // Prism law: if get fails, set does nothing usually, or here:
  // set(a, c) => self.get(a).map(...).unwrap_or(a)
  // self.get(None) is None, so returns None (a). Correct.
  
  inspect(composed.set(data_err, 2), content="Some(Ok(2))")
}

///|
test "Epi::compose" {
  let e1 = Epi::new(fn(x) { Some(x + 1) }, fn(x) { x - 1 })
  let e2 = Epi::new(fn(x) { Some(x * 2) }, fn(x) { x / 2 })
  let composed = e1.compose(e2)
  
  inspect(composed.to(1), content="Some(4)")
  inspect(composed.from(4), content="1")
}

///|
test "Prism::immut_array_nth" {
  let arr = @array.from_array([1, 2, 3])
  let prism = Prism::immut_array_nth(1)
  inspect(prism.get(arr), content="Some(2)")
  inspect(prism.set(arr, 4), content="@immut/array.from_array([1, 4, 3])")
  
  let oob = Prism::immut_array_nth(5)
  inspect(oob.get(arr), content="None")
}

///|
test "Prism::array_list" {
  let iso = Iso::array_list()
  let arr = [1, 2, 3]
  let lst = @list.from_array([1, 2, 3])
  inspect(iso.to(arr), content="@list.from_array([1, 2, 3])")
  inspect(iso.from(lst), content="[1, 2, 3]")
}

///|
test "Prism::list_head_empty_set" {
  let prism = Prism::list_head()
  let empty : @list.List[Int] = @list.empty()
  inspect(prism.set(empty, 1), content="@list.from_array([])")
}

///|
test "Prism::list_tail_empty" {
  let prism = Prism::list_tail()
  let empty : List[Int] = @list.empty()
  inspect(prism.get(empty), content="None")
  inspect(prism.set(empty, @list.from_array([1])), content="@list.from_array([])")
}
