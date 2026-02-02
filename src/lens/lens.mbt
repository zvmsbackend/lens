///|
using @list {type List}

///|
using @hashmap {type HashMap}

///|
using @sorted_map {type SortedMap}

///|
/// Create a new Lens from get and set functions
pub fn[A, B] Lens::new(get : (A) -> B, set : (A, B) -> A) -> Lens[A, B] {
  { get, set }
}

///|
/// Create a Lens from an Iso
pub fn[A, B] Lens::from_iso(iso : Iso[A, B]) -> Lens[A, B] {
  { get: iso.to, set: (_, b) => (iso.from)(b) }
}

///|
/// Get the value focused by the Lens
pub fn[A, B] Lens::get(self : Lens[A, B], a : A) -> B {
  (self.get)(a)
}

///|
/// Set the value focused by the Lens
pub fn[A, B] Lens::set(self : Lens[A, B], a : A, b : B) -> A {
  (self.set)(a, b)
}

///|
/// Identity Lens
pub fn[A] Lens::id() -> Lens[A, A] {
  { get: a => a, set: (_, a) => a }
}

///|
/// Compose two Lenses
pub fn[A, B, C] Lens::compose(
  self : Lens[A, B],
  other : Lens[B, C],
) -> Lens[A, C] {
  {
    get: a => other.get(self.get(a)),
    set: (a, c) => self.set(a, other.set(self.get(a), c)),
  }
}

///|
/// Convert a Lens to a Prism
pub fn[A, B] Lens::to_prism(self : Lens[A, B]) -> Prism[A, B] {
  { get: a => Some(self.get(a)), set: self.set }
}

///|
/// Create a new Prism from get and set functions
pub fn[A, B] Prism::new(get : (A) -> B?, set : (A, B) -> A) -> Prism[A, B] {
  { get, set }
}

///|
/// Create a Prism from an Epi
pub fn[A, B] Prism::from_epi(epi : Epi[A, B]) -> Prism[A, B] {
  { get: epi.to, set: (_, b) => (epi.from)(b) }
}

///|
/// Get the value focused by the Prism
pub fn[A, B] Prism::get(self : Prism[A, B], a : A) -> B? {
  (self.get)(a)
}

///|
/// Set the value focused by the Prism
pub fn[A, B] Prism::set(self : Prism[A, B], a : A, b : B) -> A {
  (self.set)(a, b)
}

///|
/// Compose two Prisms
pub fn[A, B, C] Prism::compose(
  self : Prism[A, B],
  other : Prism[B, C],
) -> Prism[A, C] {
  {
    get: a => self.get(a).bind(other.get),
    set: (a, c) => self
      .get(a)
      .map(other.set(_, c))
      .map(self.set(a, _))
      .unwrap_or(a),
  }
}

///|
/// Create a new Iso from to and from functions
pub fn[A, B] Iso::new(to : (A) -> B, from : (B) -> A) -> Iso[A, B] {
  { to, from }
}

///|
/// Get the value converted by the Iso
pub fn[A, B] Iso::to(self : Iso[A, B], a : A) -> B {
  (self.to)(a)
}

///|
/// Get the value converted by the Iso
pub fn[A, B] Iso::from(self : Iso[A, B], b : B) -> A {
  (self.from)(b)
}

///|
/// Invert an Iso
pub fn[A, B] Iso::invert(self : Iso[A, B]) -> Iso[B, A] {
  { to: self.from, from: self.to }
}

///|
/// Compose two Isos
pub fn[A, B, C] Iso::compose(
  self : Iso[A, B],
  other : Iso[B, C],
) -> Iso[A, C] {
  { to: a => other.to(self.to(a)), from: c => self.from(other.from(c)) }
}

///|
/// Convert an Iso to an Epi
pub fn[A, B] Iso::to_epi(self : Iso[A, B]) -> Epi[A, B] {
  { to: a => Some(self.to(a)), from: self.from }
}

///|
/// Create a new Epi from to and from functions
pub fn[A, B] Epi::new(to : (A) -> B?, from : (B) -> A) -> Epi[A, B] {
  { to, from }
}

///|
/// Get the value converted by the Epi
pub fn[A, B] Epi::to(self : Epi[A, B], a : A) -> B? {
  (self.to)(a)
}

///|
/// Get the value converted by the Epi
pub fn[A, B] Epi::from(self : Epi[A, B], b : B) -> A {
  (self.from)(b)
}

///|
/// Compose two Epis
pub fn[A, B, C] Epi::compose(
  self : Epi[A, B],
  other : Epi[B, C],
) -> Epi[A, C] {
  {
    to: a => self.to(a).bind(other.to),
    from: c => self.from(other.from(c)),
  }
}

///|
/// Focus on the first element of a tuple
pub fn[A, B] Lens::fst() -> Lens[(A, B), A] {
  { get: p => p.0, set: (p, a) => (a, p.1) }
}

///|
/// Focus on the second element of a tuple
pub fn[A, B] Lens::snd() -> Lens[(A, B), B] {
  { get: p => p.1, set: (p, b) => (p.0, b) }
}

///|
/// Focus on the value of a Some variant
pub fn[A] Prism::some() -> Prism[A?, A] {
  { get: oa => oa, set: (_, a) => Some(a) }
}

///|
/// Focus on the Ok variant of a Result
pub fn[E, A] Prism::ok() -> Prism[Result[A, E], A] {
  { get: _.to_option(), set: (_, a) => Ok(a) }
}

///|
/// Focus on the Err variant of a Result
pub fn[E, A] Prism::err() -> Prism[Result[A, E], E] {
  {
    get: ra => match ra {
      Err(e) => Some(e)
      Ok(_) => None
    },
    set: (_, e) => Err(e),
  }
}

///|
/// Focus on the element at the given index in an Array
pub fn[A] Prism::array_nth(index : Int) -> Prism[Array[A], A] {
  {
    get: arr => arr.get(index),
    set: (arr, a) => {
      let new_arr = arr.copy()
      new_arr[index] = a
      new_arr
    },
  }
}

///|
/// Focus on the element at the given index in an immutable array
pub fn[A] Prism::immut_array_nth(index : Int) -> Prism[@array.T[A], A] {
  { get: arr => arr.get(index), set: (arr, a) => arr.set(index, a) }
}

///|
/// Iso between Array and List
pub fn[A] Iso::array_list() -> Iso[Array[A], List[A]] {
  { to: arr => @list.from_array(arr), from: List::to_array }
}

///|
/// Focus on the head of a List
pub fn[A] Prism::list_head() -> Prism[List[A], A] {
  {
    get: lst => lst.head(),
    set: (lst, a) => match lst {
      Empty => @list.empty()
      More(_, tail~) => tail.prepend(a)
    },
  }
}

///|
/// Focus on the tail of a List
pub fn[A] Prism::list_tail() -> Prism[List[A], List[A]] {
  {
    get: lst => match lst {
      Empty => None
      More(_, tail~) => Some(tail)
    },
    set: (lst, tail) => match lst {
      Empty => lst
      More(head, ..) => tail.prepend(head)
    },
  }
}

///|
/// Focus on the element at the given index in a List
pub fn[A] Prism::list_nth(index : Int) -> Prism[List[A], A] {
  {
    get: lst => lst.nth(index),
    set: (lst, a) =>
      loop (@list.empty(), lst, 0) {
        (acc, Empty, _) => acc.rev()
        (acc, More(_, tail~), i) if i == index => {
          loop (acc, tail.prepend(a)) {
            (Empty, rest) => rest
            (More(h, tail=t), rest) => continue (t, rest.prepend(h))
          }
        }
        (acc, More(head, tail~), i) => continue (acc.prepend(head), tail, i + 1)
      }
  }
}

///|
/// Focus on the value at the given key in a Map.
/// Returns None if the key is missing.
pub fn[K : Eq + Hash, V] Prism::map(key : K) -> Prism[Map[K, V], V] {
  {
    get: m => m.get(key),
    set: (m, a) => {
      let new_map = m.copy()
      new_map[key] = a
      new_map
    },
  }
}

///|
/// Focus on the value at the given key in an Immutable HashMap.
pub fn[K : Eq + Hash, V] Prism::immut_hashmap(
  key : K,
) -> Prism[HashMap[K, V], V] {
  { get: m => m.get(key), set: (m, a) => m.add(key, a) }
}

///|
/// Focus on the value at the given key in an Immutable SortedMap.
pub fn[K : Compare, V] Prism::immut_sorted_map(
  key : K,
) -> Prism[SortedMap[K, V], V] {
  { get: m => m.get(key), set: (m, a) => m.add(key, a) }
}
