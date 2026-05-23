Setq  RTPort,  $R0       ; Assume RastPort is in Register 0
        Setq  X1,      $R1       ; Start X
        Setq  Y1,      $R2       ; Start Y
        Setq  X2,      $R3       ; End X
        Setq  Y2,      $R4       ; End Y

DrawALine:
        ; --- Setup for Graphics LVO Call ---
        Move.l  Graphics,  A0       ; Target LVO: Graphics
        Move.l  DrawLine, A1       ; Message: DrawLine
        Move.l  RTPort,  A2       ; Argument 1: RastPort
        Move.l  X1,      A3       ; Argument 2: Start X
        Move.l  Y1,      A4       ; Argument 3: Start Y
        Move.l  X2,      A5       ; Argument 4: End X
        Move.l  Y2,      A6       ; Argument 5: End Y
        Move.l  $Nil,    A7       ; Argument 6: Not used for DrawLine

        ; Execute the library call and wait for it to return
        Move.l  Cross,   A7       ; Return address for the call
        Call    Routine

        ; Execution continues here once the line is drawn.
        Ret