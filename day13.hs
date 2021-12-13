#!/usr/bin/runhaskell
import System.IO

main = do
    contents <- readFile "input.txt"
    putStr contents

{- (fmap read . words) <$> getLine :: Read b => IO [b] -}
