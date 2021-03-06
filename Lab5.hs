{-# LANGUAGE DeriveFunctor #-}

getLine' :: IO String
getLine' = do
        x <- getChar
        if x == '\n'
        then return []
        else do
            xs <- getLine'
            return (x:xs)


main = do
    line <- getLine'
    putStrLn line

actSeq = putChar 'A' >> putChar 'G' >> putChar 'H' >>  putChar '\n'

doActSeq = do
    putChar 'A'
    putChar 'G'
    putChar 'H'
    putChar '\n'

echo1 = getLine >>= putStrLn

doEcho1 = do
  variable <- getLine
  putStrLn (reverse variable)

echo2 = getLine >>= \line -> putStrLn $ line ++ "!"

doEcho2 = do
  line <- getLine
  putStrLn $ line ++ "!"

echo3 :: IO ()
echo3 =  getLine >>= \l1 -> getLine >>= \l2 -> putStrLn $ l1 ++ l2

dialog :: IO ()
dialog = putStr "What is your happy number? "
         >> getLine
         >>= \n -> let num = read n :: Int in
                   if num == 7
                   then putStrLn "Ah, lucky 7!"
                   else if odd num
                        then putStrLn "Odd number! That's most people's choice..."
                        else putStrLn "Hm, even number? Unusual!"

echo3' :: IO ()
echo3' = do
    firstPart <- getLine
    secondPart <- getLine
    putStrLn $firstPart ++ " " ++ secondPart

dialog' :: IO ()
dialog' = do
    putStrLn "What is your happy number? "
    line <- getLine
    let num = read line :: Int in
        if num == 7
        then putStrLn "Ah, lucky 7!"
        else if odd num
             then putStrLn "Odd number! That's most people's choice..."
             else putStrLn "Hm, even number? Unusual!"


twoQuestions :: IO ()
twoQuestions = do
  putStr "What is your name? "
  name <- getLine
  putStr "How old are you? "
  age <- getLine
  print (name,age)

twoQuestions' :: IO ()
twoQuestions' = putStrLn "What is your name? "
                >> getLine
                >>= \l1 -> putStrLn "How old are you? "
                >> getLine
                >>= \l2 -> print (l1,l2)


nTimes :: Int -> IO () -> IO ()
nTimes 0 action = return ()
nTimes n action = do
  action
  nTimes (n-1) action

ioActionFactory :: Int -> String -> IO ()
ioActionFactory n = case n of
  1 -> \name -> putStrLn ("Good morning, " ++ name)
  2 -> \name -> putStrLn ("Good afternoon, " ++ name)
  3 -> \name -> putStrLn ("Good night, " ++ name)
  _ -> \name -> putStrLn ("Hello, " ++ name)

actionList :: [IO ()]
actionList = [ioActionFactory 1 "Ben",
              ioActionFactory 2 "Joe",
              ioActionFactory 3 "Ally"]

sequence'        :: [IO ()] -> IO ()
sequence' []     =  return ()
sequence' (a:as) =  do a
                       sequence' as


-- >>= is like Scala's flatMap. It takes a function,
-- maps it over an instance of a monad and then flattens the result.
-- For this to work, the function has to return an instance of the monad itself!
--[1,2,3,4] >>= \ x -> [x - 1, x + 1]
--[0,2,1,3,2,4,3,5]
--(>>=) :: Monad m => m a -> (a -> m b) -> m b

--The >> is just a hand specialized version of >>=. It's equivalent to using >>= with a "constant function"
--a function that ignores its argument and always returns the same value. So a >> b is always the same as a >>= \ _ -> b

-- <$> is similar to fmap.
-- *Main Data.Char> (+2) <$> (Right 3)
-- Right 5
-- *Main Data.Char> (+2) <$> (Left 3)
-- Left 3
-- *Main Data.Char> (*2) <$> (Just 3)
-- Just 6
-- *Main Data.Char> (*2) <$> [1..5]
-- [2,4,6,8,10]
-- *Main Data.Char> fmap (*2) [1..5]
-- [2,4,6,8,10]
-- *Main Data.Char> fmap (*2) (Just 3)
-- Just 6
-- *Main Data.Char> fmap (*2) [1..5]
-- [2,4,6,8,10]
-- *Main Data.Char> toUpper <$> getChar
-- 3'3'
-- *Main Data.Char>
-- *Main Data.Char> toUpper <$> getChar
-- a'A'
-- *Main Data.Char>
-- *Main Data.Char> (map toUpper) <$> getLine
-- asdf
-- "ASDF"

-- <$ takes a value from left and inserts it into Right
-- *Main Data.Char> 1 <$ Right 2
-- Right 1
-- *Main Data.Char> 'a' <$ [1..5]
-- "aaaaa"

newtype Box a = MkBox a deriving (Show, Functor)


data MyList a = EmptyList
              | Cons a (MyList a) deriving Show

instance Functor MyList where
  fmap _ EmptyList    = EmptyList
  fmap f (Cons x mxs) = Cons (f x) (fmap f mxs)

data BinTree a = EmptyBT | NodeBT a (BinTree a) (BinTree a) deriving (Show)

instance Functor BinTree where
  fmap _ EmptyBT = EmptyBT
  fmap f (NodeBT a b c) = NodeBT (f a) (fmap f b) (fmap f c)

newtype Pair b a = Pair { getPair :: (a,b) } deriving Show-- fmap should change the first element

data Tree2 a = EmptyT2 | Leaf a | Node (Tree2 a) a (Tree2 a) deriving Show

instance Functor Tree2 where
  fmap _ EmptyT2 = EmptyT2
  fmap f (Leaf a)  = Leaf (f a)
  fmap f (Node b a c) = Node (fmap f b) (f a) (fmap f c)

data GTree a = LeafG a | GNode [GTree a] deriving Show

-- instance Functor GTree where
--     fmap f (LeafG a) = LeafG (f a)
--     fmap f (GNode (x:xs)) = GNode ((f x):(fmap f xs))


-- As it is already implemeted in GHC i have to comment it:
-- instance Functor ((->) r) where
--   fmap = (.)


newtype Box' a = MkBox' a deriving Show

instance Functor Box' where
  fmap f (MkBox' x) = MkBox' (f x)

newtype MyTriple a = MyTriple (a,a,a) deriving Show

instance Functor MyTriple where
  fmap f (MyTriple (a,b,c)) = MyTriple (f a, f b, f c)


--1. Napisac krotki program z do, ktory wczytuje imie i wiek i wypisuje czesc/dzien dobry + imie w zaleznosci od wieku

ageAndName :: IO ()
ageAndName = do
  putStrLn "Pass your name: "
  name <- getLine
  putStrLn "Pass your age "
  age <- getLine
  putStrLn $ "Age is " ++ age ++ " Name is " ++ name

ageAndName' :: IO ()
ageAndName' = putStrLn "name" >> getLine >>= \line -> putStrLn "age" >> getLine >>= \line2 -> putStrLn $"Age is " ++ line ++ " Name is " ++ line2

--2. Napisac instancje dla funktora chyba
--instance Functor Box' where
--  fmap f (MkBox' x) = MkBox' (f x)

--3. Definicja monady, dokladnie to dopisac definicje tego znaczka ==>
--(>>=) :: Monad m => m a -> (a -> m b) -> m b
--(>>) :: Monad m => m a -> m b -> m b

-- 1.Przepisać poniższy kod w użyciem >>, >>=
--
-- fun = do
--     putStrLn "Podaj imie: "
--     s <- geLine
--     putStrln $ "Witaj " ++ s

fun :: IO ()
fun = putStrLn "Podaj imie: " >> getLine >>= \line -> putStrLn $ "Witaj " ++ line

-- 2.Do czego ewaluuje się:
--
-- foldr (+) 0 ((*)<$>ZipList[1,2,3]<*>((+1)ZipList[4,5,6]))

--[5,6,7] -> [1,12,21] -> 34

--Main Control.Applicative> pure (+) <*> ZipList [1,2,3] <*> ZipList [100,100,100]
--ZipList {getZipList = [101,102,103]}

--Main Control.Applicative> [1..2] *> [11..15]
--[11,12,13,14,15,11,12,13,14,15]



-- 3.Napisać Functor i Foldable (kolejność pre-order) dla:
--
data Tree' a = Node' (Tree' a) (Tree' a) | Leaf' a

instance Functor Tree' where
    fmap f (Leaf' a) = Leaf' (f a)
    fmap f (Node' lt rt) = Node' (fmap f lt) (fmap f rt)
