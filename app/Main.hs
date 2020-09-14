{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Lib

import Numeric.AD
import Numeric.AD.Internal.Forward
import Numeric.AD.Rank1.Tower(Tower)
import Numeric.SpecFunctions
import Data.Csv
import qualified Data.ByteString.Lazy.Char8 as C

--c :: Num a => (a -> a) -> a -> a -> a
difference :: Fractional a => (forall s. AD s (Tower a) -> AD s (Tower a)) -> a -> (forall s. AD s (Tower a) -> AD s (Tower a))
difference v base = \x -> v x - v (auto base)

difference' :: Num a => (t -> a) -> t -> t -> a
difference' v base x = v x - v base

optValLin :: Num a => a -> a
optValLin r = 1000 * r

optValQuad :: Num a => a -> a
--optValQuad r = 1000 * (r + r*r)
optValQuad r = 10000 * (r*r) + 10* r

-- Truncate a taylor exapansion
-- If nothing don't take a taylor expansion just evaluate the 0th derivative a.k.a zero
trunTay :: Fractional a => Maybe Int -> (forall s. AD s (Tower a) -> AD s (Tower a)) -> a -> a -> a
trunTay Nothing  f centre x =  (diffs f x)!!0
trunTay (Just n) f centre x = foldr (+) 0 $ take (n+1) $ (taylor0 f centre (x-centre))

-- create convexity correction function
-- takes a function and two points and calculates the adjustment needed for the difference
convexityAdj :: Fractional a => (forall s. AD s (Tower a) -> AD s (Tower a)) -> a -> a -> a
convexityAdj f centre b = difference' (\x -> trunTay (Just x) (difference f centre) centre b ) 1 2

main :: IO ()
main = do
    --tr (Just 1) (c d 0.02) 0.02 0.04
    print $ trunTay (Just 0) (difference optValLin 0.02) 0.02 0.04
    --print $ trunTay (Just 1) (difference optionVal 0.02) 0.02 0.04
    --print $ trunTay (Just 2) (difference optionVal 0.02) 0.02 0.04
    --print $ trunTay Nothing (difference optionVal 0.02) 0.02 0.04

    print $ "convexity"
    print $ convexityAdj optValLin 0.02 0.04
    print $ convexityAdj optValQuad 0.02 0.04
    -- just get the second derivative of the adjustment

    -- plot a function trunTay for a range from like 0 -> 0.1 for examples with Nothing
    let xFunValues = [ x*0.001 | x <- [1..100] ]
        linValues = map (\x -> trunTay Nothing optValLin 0.02 x) xFunValues
        quadValues = map (\x -> trunTay Nothing optValQuad 0.02 x) xFunValues

--    print $ (linValues :: [(Double,Double)])
    C.writeFile "./plotting/funVals.csv" $ encode (zip3 xFunValues linValues quadValues :: [(Double,Double,Double)])

    -- Then plot first order derivaitve trunTay (Just 1) centred at 0.02 up to 0.04 to get straight line
    let xApproxValues = [ x*0.001 + 0.02 | x <- [0..60] ]
        quadApproxVals1 = map (\x -> trunTay (Just 1) optValQuad  0.02 x) xApproxValues
        quadApproxVals2 = map (\x -> trunTay (Just 2) optValQuad  0.02 x) xApproxValues

    C.writeFile "./plotting/approxVals.csv" $ encode (zip3 xApproxValues quadApproxVals1 quadApproxVals2 :: [(Double,Double,Double)])

    -- Now plot the convexity adustment as a constant values starting at 0.8
    let sPoint = trunTay (Just 1) optValQuad  0.02 0.08
        convexAdj = (convexityAdj optValQuad 0.02 0.08)
    writeFile "./plotting/convexAdj.csv" $ "0.08," ++ show sPoint ++ ",0," ++ show convexAdj


    print "done"
