# sennenki/lens

A simple yet powerful optics library for MoonBit, providing Lens, Prism, Iso, and Epi.

## Installation

Add this package to your `moon.pkg.json`:

```json
{
  "deps": {
    "sennenki/lens": "0.1.0" 
  }
}
```

## Usage

### Lens

A `Lens[A, B]` focuses on a part `B` of a structure `A`. It allows getting and setting the focus.

```mbt test
let lens = Lens::fst() 
let pair = (1, 2)

// Get
lens.get(pair) // 1

// Set
lens.set(pair, 3) // (3, 2)
```

Compose lenses using `compose`:

```mbt test
let l1 = Lens::fst()
let l2 = Lens::snd()
// Focus on the second element of the first element of a nested pair
let composed = l1.compose(l2) // Lens[((Int, Int), Int), Int]

composed.get(((1, 2), 3)) // 2
```

### Prism

A `Prism[A, B]` focuses on a part `B` of a structure `A` that may or may not exist (like a sum type variant or an index in a list).

```mbt test
let prism = Prism::some()
prism.get(Some(42)) // Some(42)
prism.get(None)     // None

prism.set(Some(1), 2) // Some(2)
```

Useful built-in prisms:

*   `Prism::ok()`: Focuses on the `Ok` variant of a `Result`.
*   `Prism::err()`: Focuses on the `Err` variant of a `Result`.
*   `Prism::array_nth(index)`: Focuses on an index in an `Array`.
*   `Prism::list_nth(index)`: Focuses on an index in a `List`.
*   `Prism::map(key)`: Focuses on a key in a `Map`.

### Iso

An `Iso[A, B]` represents an isomorphism between `A` and `B` (conversions in both directions).

```mbt test
let iso = Iso::array_list()
iso.to([1, 2, 3]) // List::[1, 2, 3]
iso.from(@list.from_array([1, 2, 3])) // [1, 2, 3]
```

### Epi

An `Epi[A, B]` (Epimorphism) has a `to: (A) -> B?` which might fail, and a `from: (B) -> A` which is total.

## API Reference

### Lens

*   `Lens::new(get, set)`
*   `Lens::id()`
*   `Lens::fst()`
*   `Lens::snd()`
*   `Lens::from_iso(iso)`
*   `Lens::compose(other)`
*   `Lens::to_prism()`

### Prism

*   `Prism::new(get, set)`
*   `Prism::some()`
*   `Prism::ok()`
*   `Prism::err()`
*   `Prism::array_nth(index)`
*   `Prism::immut_array_nth(index)`
*   `Prism::list_head()`
*   `Prism::list_tail()`
*   `Prism::list_nth(index)`
*   `Prism::map(key)`
*   `Prism::immut_hashmap(key)`
*   `Prism::immut_sorted_map(key)`
*   `Prism::from_epi(epi)`
*   `Prism::compose(other)`

### Iso

*   `Iso::new(to, from)`
*   `Iso::invert()`
*   `Iso::compose(other)`
*   `Iso::to_epi()`
*   `Iso::array_list()`

### Epi

*   `Epi::new(to, from)`
*   `Epi::compose(other)`
