module Sudoku.Strategy.NakedPairs where

import Data.Char
import Data.List
import Sudoku
import Sudoku.Strategy

type Candidates = [(Int, Int, String)]

haveUnitInCommon :: Sudoku -> (Int, Int) -> (Int, Int) -> Bool
haveUnitInCommon rs (i, j) (i', j') = i == i' || j == j' || findBlock rs i j == findBlock rs i' j'

nakedPairs :: Sudoku -> [(String, (Int, Int), (Int, Int))]
nakedPairs rs = map (\[(a, b, cs), (c, d, _)] -> (cs, (a, b), (c, d))) (filter (\x -> length x == 2) css)
    where
      f (i, j, cs)                = length cs == 2
      s (_, _, c) (_, _, c')      = compare c c'
      g (i, j, cs) (i', j', cs')  = cs == cs' && haveUnitInCommon rs (i, j) (i', j')
      css = groupBy g $ sortBy s $ filter f $ allCandidates rs

findExcludableCandidates :: Sudoku -> Int -> Int -> [Char]
findExcludableCandidates rs i j = concat (map (\(cs, _, _) -> cs) es)
                                  where
                                    es = filter (\(_, ab, cd) -> haveUnitInCommon rs (i, j) ab &&  haveUnitInCommon rs (i, j) cd) (nakedPairs rs)

candidatePairs :: Sudoku -> Candidates
candidatePairs rs = filter (\(i, j, cs) -> length cs == 2) $ allCandidates rs

allCandidates :: Sudoku -> Candidates
allCandidates rs  = [ (i, j, findCandidates rs i j) | i<-[0..8], j<-[0..8] ]

resolveCandidates :: Sudoku -> Int -> Int -> (Char, String)
resolveCandidates rs i j  | cs /= es = (s, cs \\ es)
                          | otherwise = (rs !! i !! j, cs)
                          where
                            s   = rs !! i !! j
                            cs  = findCandidates rs i j
                            es  = findExcludableCandidates rs i j

resolveAllCandidates :: Sudoku -> [[(Char, String)]]
resolveAllCandidates rs = mapWithIndeces rs (\rs i j -> resolveCandidates rs i j)

solve :: Sudoku -> Sudoku
solve rs = run rs resolveAllCandidates

-- TODO: Alleen candidates elimeneren die beide nakedPairs inCommon hebben.
-- Dus niet maar één naked pair in common zoals nu het geval is.
-- nakedPairs kan in principe weer zonder concat geschreven worden.
-- TODO: Cellen vinden met 2 twee nakedPairs inCommon ???

