{-# LANGUAGE NoMonomorphismRestriction #-}
import Diagrams.Prelude
import Diagrams.Backend.Cairo.CmdLine

fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

thick = 0.15

grid x y = frame <> lattice
  where s       = unitSquare # lw 0.02 # freeze
        frame   = rect (fromIntegral x) (fromIntegral y)
                # lw thick # freeze
        lattice = centerXY . vcat . map hcat . replicate y . replicate x $ s

trap s1 s2 = fromOffsets [(0,-s2), (s2,0), (0,s1)]
             # close # stroke # lw 0
tri s1 s2  = fromOffsets [(s1,0), (0,s1+s2)]
             # close # stroke # lw 0

paradox n drawDiags = sq ||| strutX s2 ||| rect
  where f1 = fibs !! n
        f2 = fibs !! (n+1)
        s1 = fromIntegral f1
        s2 = fromIntegral f2

        trap1 = trap s1 s2 # fc yellow
        trap2 = trap s1 s2 # fc green
                           # rotateBy (1/2)

        tri1  = tri s1 s2  # fc red
        tri2  = tri s1 s2  # fc blue

        sq = (if drawDiags then sqDiags else mempty)
             <> grid (f1+f2) (f1+f2)
             <> sqShapes
        sqDiags = (P (0,s2) ~~ P (s2,s1)       <>
                   P (s2,0) ~~ P (s2,s1+s2)    <>
                   P (s2,0) ~~ P (s1+s2,s1+s2))
                # stroke
                # lw thick
                # freeze
                # centerXY

        sqShapes = (traps # centerY ||| tris # centerY)
                 # centerXY
        traps = trap2 # alignL
                      # translateY (s1 - s2)
             <> trap1
        tris  = tri1 # alignBL
             <> tri2 # rotateBy (1/2)
                     # alignBL

        rect = (if drawDiags then rDiags else mempty)
               <> grid (2*f2 + f1) f2
               <> rShapes

        rShapes = (bot # alignTL <> top # alignTL) # centerXY
        bot = trap1 # alignB ||| rotateBy (-1/4) tri1 # alignB
        top = rotateBy (1/4) tri2 # alignT ||| trap2 # alignT

        rDiags = (P (0,s2)        ~~ P (2*s2+s1, 0)      <>
                  P (s2,0)        ~~ P (s2,s1)           <>
                  P (s1+s2,s2-s1) ~~ P (s1+s2,s2)
                  )
                 # stroke
                 # lw thick
                 # lineCap LineCapRound
                 # freeze
                 # centerXY

dia = paradox 4 True # centerXY

main = defaultMain (pad 1.1 dia)