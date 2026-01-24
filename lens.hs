{-# LANGUAGE LambdaCase #-}

data Lens a b = Lens {
    get :: a -> b,
    set :: b -> a -> a
}

data Prism a b = Prism {
    match :: a -> Maybe b,
    build :: b -> a -> a
}

class LensComposable f where
    (>->) :: Lens a b -> f b c -> f a c

instance LensComposable Lens where
    (Lens get1 set1) >-> (Lens get2 set2) = Lens {
        get = get2 . get1,
        set = \c a -> set1 (set2 c (get1 a)) a
    }

instance LensComposable Prism where
    (Lens get1 set1) >-> (Prism match2 build2) = Prism {
        match = match2 . get1,
        build = \b a -> set1 (build2 b (get1 a)) a
    }

head' :: Prism [a] a
head' = Prism {
    match = \case
        (x:_) -> Just x
        []    -> Nothing,
    build = \b xs -> case xs of
        (_:xs') -> b:xs'
        []      -> [b]
}

data Person = Person {
    name :: String,
    age  :: Int
}

name' :: Lens Person String
name' = Lens {
    get = name,
    set = \newName person -> person { name = newName }
}

nameFirstLetter :: Prism Person Char
nameFirstLetter = name' >-> head'
