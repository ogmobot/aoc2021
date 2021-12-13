#!/usr/bin/runhaskell
import System.IO
import Data.List.Split
import Data.List

data PaperFold = FoldX Int | FoldY Int | NoFold
data Point     = Point Int Int deriving Eq

foldPoint :: PaperFold -> Point -> Point
foldPoint (FoldX coord) (Point x y)
    | coord >= x = Point x y
    | coord <  x = Point ((2 * coord) - x) y
foldPoint (FoldY coord) (Point x y)
    | coord >= y = Point x y
    | coord <  y = Point x ((2 * coord) - y)
foldPoint NoFold p = p

part1 :: [Point] -> [PaperFold] -> Int
part1 xs (f:fs) = length . nub $ map (foldPoint f) xs

part2 :: [Point] -> [PaperFold] -> [Point]
part2 xs (f:fs) = part2 (map (foldPoint f) xs) fs
part2 xs []     = xs

parseCoord :: String -> Point
parseCoord line = Point x y
    where x:y:_ = map read $ splitOn "," line

parseFold :: String -> PaperFold
parseFold line
    | axis == ['x'] = FoldX num
    | axis == ['y'] = FoldY num
    | otherwise     = NoFold
    where num  = read $ drop 13 line
          axis = take 1 (drop 11 line)

extractPoints :: String -> [Point]
extractPoints s = map parseCoord (splitOn "\n" upper)
    where upper:_ = splitOn "\n\n" s

extractFolds :: String -> [PaperFold]
extractFolds s = map parseFold (splitOn "\n" lower)
    where _:lower:_ = splitOn "\n\n" s

makeStrings :: [Point] -> [String] -> [String]
makeStrings [] buffer = buffer
makeStrings ((Point x y):ps) buffer =
    makeStrings ps (upper ++ [altered] ++ lower)
    where upper = take y buffer
          lower = drop (y+1) buffer
          left = take x (buffer !! y)
          right = drop (x+1) (buffer !! y)
          altered = left ++ "#" ++ right

newBuffer :: [Point] -> [String]
newBuffer [] = ["."]
newBuffer ps = (map (\x -> (map (\x -> ' ') [0..maxx])) [0..maxy])
    where maxx = maximum (map (\(Point x y) -> x) ps)
          maxy = maximum (map (\(Point x y) -> y) ps)

main = do
    contents <- readFile "input13.txt"
    let
        points  = extractPoints contents
        folds   = extractFolds contents
        result1 = part1 points folds
        result2 = part2 points folds
    print result1
    mapM_ putStrLn (makeStrings result2 (newBuffer result2))

{-
Oh man. I forgot how fussy Haskell is. The core logic of this program (i.e. the
`foldPoint` function) was done in minutes, and Haskell's type system ensured it
was safe; but it took over an hour to organise the input and output of the
program. (To be fair, if I had used the language at all in the last few months,
I probably would have found it a lot easier.)
-}
