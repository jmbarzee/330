

import Data.Array

isPrime :: Int -> Bool
isPrime n = null [tmp | tmp <- [2..(iSqrt n)], n `mod` tmp == 0]

primes :: [Int]
primes = filter isPrime [2..]


isPrimeFast :: Int -> Bool
isPrimeFast n
    | n == 2 = True
    | otherwise = null [tmp | tmp <- (takeWhile (<=(iSqrt n)) primesFast), n `mod` tmp == 0]

primesFast :: [Int]
primesFast = filter isPrimeFast [2..]


iSqrt :: Int-> Int
iSqrt n = floor(sqrt(fromIntegral n))

lcsLength :: String -> String -> Int
lcsLength string1 string2  = a ! (0,0) where
    n = length string1
    m = length string2
    a = array ((0,0), (n,m)) (l1 ++ l2 ++ l3)
    l1 = [((i,m), 0) | i <- [0..n]]
    l2 = [((n,j), 0) | j <- [0..m]]
    l3 = [((i,j), fun char1 char2 i j) | (char1,i) <- zip string1 [0..], (char2,j) <- zip string2 [0..]]
    fun char1 char2 i j
        | char1 == char2 = 1 + (a!(i+1,j+1))
        | otherwise = max (a!(i,j+1)) (a!(i+1,j))
{-
main = do
    print (lcsLength "abcd" "abcd")
    print "expected 4"
    print (lcsLength "abc" "abcd")
    print "expected 3"
    print (lcsLength "ab" "abcd")
    print "expected 2"
    print (lcsLength "a" "abcd")
    print "expected 1"
    print (lcsLength "ad" "abcd")
    print "expected 2"
    print (lcsLength "abcd" "bc")
    print "expected 2"
    print (lcsLength "abcd" "addddddddd")
    print "expected 2"

    -- print (take 10000 primesFast)
    print (take 10000 primes)-}