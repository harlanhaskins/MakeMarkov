module MakeMarkov where

import Control.Monad

import Data.MarkovChain
import System.Random
import Control.Monad.IO.Class

newMarkov :: (Ord a) => Int -> [a] -> IO [a]
newMarkov n s = liftM (take n . ((flip markov) s)) newStdGen

markov :: (Ord a, RandomGen g) => g -> [a] -> [a]
markov gen s = run 3 s 0 gen

--main = getContents >>= putStrLn . liftIO . newMarkov 100
