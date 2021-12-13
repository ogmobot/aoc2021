#!/usr/bin/runhaskell
import System.IO
import Data.List.Split
import Data.List

data PaperFold = FoldX Int | FoldY Int deriving Show
data Point     = Point Int Int deriving (Show, Eq)

foldPoint :: PaperFold -> Point -> Point
foldPoint (FoldX coord) (Point x y)
    | coord >= x = Point x y
    | coord <  x = Point ((2 * coord) - x) y
foldPoint (FoldY coord) (Point x y)
    | coord >= y = Point x y
    | coord <  y = Point x ((2 * coord) - y)

part1 :: [Point] -> [PaperFold] -> Int
part1 xs (f:fs) = length (nub (map (foldPoint f) xs))

solve :: [Point] -> [PaperFold] -> [Point]
solve xs (f:fs) = solve (map (foldPoint f) xs) fs
solve xs []     = xs

parseCoord :: String -> Point
parseCoord line = Point x y
    where x:y:_ = (map read $ splitOn "," line)

parseFold :: String -> PaperFold
parseFold line
    | axis == ['x'] = FoldX num
    | axis == ['y'] = FoldY num
    | otherwise     = FoldX 999999 --won't change any points
    where num  = read (drop 13 line)
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
newBuffer ps = (map (\x -> (map (\x -> ' ') [1..maxx+1])) [1..maxy+1])
    where maxx = maximum (map (\(Point x y) -> x) ps)
          maxy = maximum (map (\(Point x y) -> y) ps)

main = do
    contents <- readFile "input13.txt"
    let
        points = extractPoints contents
        folds  = extractFolds contents
        resultOne = part1 points folds
        resultTwo = solve points folds
    print resultOne
    mapM_ putStrLn (makeStrings resultTwo (newBuffer resultTwo))
