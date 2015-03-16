import Data.MarkovChain
import System.Random

markov gen s = take 100 $ run 3 s 0 gen

main = do
    gen <- newStdGen
    s   <- getContents
    (putStrLn . unwords) (markov gen (words s))
