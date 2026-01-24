///|
/// Lens between A and B
struct Lens[A, B] {
  get : (A) -> B
  set : (A, B) -> A
}

///|
/// Prism between A and B
struct Prism[A, B] {
  get : (A) -> B?
  set : (A, B) -> A
}

///|
/// Isomorphism between A and B
struct Iso[A, B] {
  to : (A) -> B
  from : (B) -> A
}

///|
/// Epimorphism between A and B
struct Epi[A, B] {
  to : (A) -> B?
  from : (B) -> A
}
