        identification division.
        program-id. game.

        data division.
        working-storage section.

        01 WS-IsClosing-BOOL        pic 9       value 0.
        01 WS-Index-INT             pic 9(4)    value 0.
        01 WS-DrawX-INT             pic 9(3)    value 0.
        01 WS-DrawY-INT             pic 9(3)    value 0.
        01 WS-DrawI-INT             pic 9(4)    value 0.
        01 WS-Coords.
            05 WS-CX-INT            pic 9(4)    value 0.
            05 WS-CY-INT            pic 9(4)    value 0.
        01 WS-Board.
            05 WS-BSize-INT         pic 9(4)    value 0.
            05 WS-BWidth-INT        pic 9(3)    value 32.
            05 WS-BHeight-INT       pic 9(3)    value 32.
            05 WS-BTiles-INT        pic 9       occurs 1024 times.
            05 WS-BOffX-INT         pic 9(3)    value 144.
            05 WS-BOffY-INT         pic 9(3)    value 44.
        01 WS-Snake.
            05 WS-SnakePos.
                10 WS-SnakeX-INT    pic 9(3)    value 16.
                10 WS-SnakeY-INT    pic 9(3)    value 16.
            05 WS-SnakePartX-INT    pic 9(3)    occurs 1024 times.
            05 WS-SnakePartY-INT    pic 9(3)    occurs 1024 times.
            05 WS-SnakeLen-INT      pic 9(3)    value 1.
            05 WS-SnakeDir-INT      pic 9       value 0.
        01 WS-FoodAmount-INT        pic 9(2)    value 4.
        01 WS-FoodX-INT             pic 9(3)    occurs 1024 times.
        01 WS-FoodY-INT             pic 9(3)    occurs 1024 times.
        01 WS-FoodTotal-INT         pic 9(4)    value 0.
        01 WS-Debounce-INT          pic 9(2)    value 0.
        01 WS-CMD-BOOL              pic 9       value 0.
        01 WS-GameOver-BOOL         pic 9       value 0.
        01 WS-Score-String          pic x(24)   value " ".
        01 WS-EndScore-String       pic x(24)   value " ".
        01 WS-CanFail-Bool          pic 9       value 1.

        copy rl-keys.
        copy rl-bool.
        copy rl-def.

        procedure division.
        main-procedure.

        perform init.
        perform init-data.

        perform until WS-IsClosing-BOOL = rl-true
            call "WindowShouldClose"
                returning WS-IsClosing-BOOL
            end-call

            perform events
            perform draw
        end-perform

        perform dispose.

        init section.
            display function module-id " Running"
            call "SetTraceLogLevel" using
                by value rl-log-error
            end-call

            call "InitWindow" using
                by value 800 600
                by reference "CobSnake"
            end-call

            call "SetTargetFPS" using
                by value 60
            end-call
        .

        init-data section.
            multiply 
                WS-BHeight-INT by WS-BWidth-INT 
                giving WS-BSize-INT

            move WS-SnakeX-INT to WS-SnakePartX-INT(1)
            move WS-SnakeY-INT to WS-SnakePartY-INT(1)

            *> Create border
            perform until WS-DrawI-INT = WS-BSize-INT
                if WS-DrawX-INT = 0 or 
                    WS-DrawY-INT = 0 or
                    WS-DrawX-INT = WS-BWidth-INT - 1 or 
                    WS-DrawY-INT = WS-BHeight-INT then
                    move 1 to WS-BTiles-INT(WS-DrawI-INT)
                else
                    move 0 to WS-BTiles-INT(WS-DrawI-INT)
                end-if

                add 1 to WS-DrawX-INT
                if WS-DrawX-INT = WS-BWidth-INT then
                    add 1 to WS-DrawY-INT
                    move 0 to WS-DrawX-INT
                end-if

                add 1 to WS-DrawI-INT
            end-perform
            move 0 to WS-DrawI-INT
            move 0 to WS-DrawX-INT
            move 0 to WS-DrawY-INT

            *> Generate initial food
            move 1 to WS-Index-INT
            perform until WS-Index-INT = WS-FoodAmount-INT + 1
                call "b_RandomRange" using
                    by value 2 30
                    returning WS-FoodX-INT(WS-Index-INT)
                end-call
                call "b_RandomRange" using
                    by value 2 30
                    returning WS-FoodY-INT(WS-Index-INT)
                end-call
                add 1 to WS-FoodTotal-INT
                add 1 to WS-Index-INT
            end-perform
            move 0 to WS-Index-INT
        .

        events section.
            *> Update
            if WS-Debounce-INT = 1 and 
                WS-GameOver-BOOL = rl-false then
                move 1 to WS-CanFail-Bool
                *> Update snake position
                move WS-SnakeLen-INT to WS-Index-INT
                perform until WS-Index-INT = 1
                    move WS-SnakePartX-INT(WS-Index-INT - 1) to
                            WS-SnakePartX-INT(WS-Index-INT)
                    move WS-SnakePartY-INT(WS-Index-INT - 1) to
                            WS-SnakePartY-INT(WS-Index-INT)
                    subtract 1 from WS-Index-INT
                end-perform
                if WS-SnakeDir-INT = 0 then
                    add 1 to WS-SnakePartX-INT(1)
                end-if
                if WS-SnakeDir-INT = 1 then
                    add 1 to WS-SnakePartY-INT(1)
                end-if
                if WS-SnakeDir-INT = 2 then
                    subtract 1 from WS-SnakePartX-INT(1)
                end-if
                if WS-SnakeDir-INT = 3 then
                    subtract 1 from WS-SnakePartY-INT(1)
                end-if

                *> Check food collision
                move 1 to WS-Index-INT
                perform until WS-Index-INT = WS-FoodTotal-INT + 1
                    if WS-SnakePartX-INT(1) = 
                        WS-FoodX-INT(WS-Index-INT) and
                        WS-SnakePartY-INT(1) = 
                        WS-FoodY-INT(WS-Index-INT) then
                        add 1 to WS-SnakeLen-INT
                        move 0 to WS-CanFail-Bool *> Make a brief period player cannot fail
                        
                        call "b_RandomRange" using
                            by value 2 30
                            returning WS-FoodX-INT(WS-Index-INT)
                        end-call
                        call "b_RandomRange" using
                            by value 2 30
                            returning WS-FoodY-INT(WS-Index-INT)
                        end-call
                    end-if
                    add 1 to WS-Index-INT
                end-perform

                *> Check border collision
                if WS-SnakePartX-INT(1) = 1 or
                    WS-SnakePartY-INT(1) = 1 or
                    WS-SnakePartX-INT(1) = WS-BWidth-INT - 2 or
                    WS-SnakePartY-INT(1) = WS-BHeight-INT - 1 then
                    move 1 to WS-GameOver-BOOL
                end-if

                *> Check if self collision
                move 2 to WS-Index-INT
                perform until WS-Index-INT = WS-SnakeLen-INT + 1
                    if WS-SnakePartX-INT(1) = 
                        WS-SnakePartX-INT(WS-Index-INT) and
                        WS-SnakePartY-INT(1) =
                        WS-SnakePartY-INT(WS-Index-INT) and
                        WS-SnakeLen-INT > 3 and 
                        WS-CanFail-Bool = 1 then
                        display "Hit self"
                        move 1 to WS-GameOver-BOOL
                    end-if
                    add 1 to WS-Index-INT
                end-perform
            end-if
            if WS-Debounce-INT = 10 then
                move 0 to WS-Debounce-INT
            end-if
            add 1 to WS-Debounce-INT

            *> Keyboard controls
            call "b_IsKeyDown" using
                by value rl-key-left
                returning WS-CMD-BOOL
            end-call
            if WS-CMD-BOOL = rl-true then
                if WS-SnakeDir-INT = 1 or WS-SnakeDir-INT = 3 then
                    move 2 to WS-SnakeDir-INT
                end-if
            end-if

            call "b_IsKeyDown" using
                by value rl-key-right
                returning WS-CMD-BOOL
            end-call
            if WS-CMD-BOOL = rl-true then
                if WS-SnakeDir-INT = 1 or WS-SnakeDir-INT = 3 then
                    move 0 to WS-SnakeDir-INT
                end-if
            end-if

            call "b_IsKeyDown" using
                by value rl-key-up
                returning WS-CMD-BOOL
            end-call
            if WS-CMD-BOOL = rl-true then
                if WS-SnakeDir-INT = 0 or WS-SnakeDir-INT = 2 then
                    move 3 to WS-SnakeDir-INT
                end-if
            end-if

            call "b_IsKeyDown" using
                by value rl-key-down
                returning WS-CMD-BOOL
            end-call
            if WS-CMD-BOOL = rl-true then
                if WS-SnakeDir-INT = 0 or WS-SnakeDir-INT = 2 then
                    move 1 to WS-SnakeDir-INT
                end-if
            end-if

            if WS-GameOver-BOOL = 1
                call "b_IsKeyDown" using
                    by value rl-key-space
                    returning WS-CMD-BOOL
                end-call
                if WS-CMD-BOOL = rl-true then
                    move 1 to WS-SnakeLen-INT
                    move 16 to WS-SnakePartX-INT(1)
                    move 16 to WS-SnakePartY-INT(1)

                    move 1 to WS-Index-INT
                    move 0 to WS-FoodTotal-INT
                    perform until WS-Index-INT = 
                                    WS-FoodAmount-INT + 1
                        call "b_RandomRange" using
                            by value 2 30
                            returning WS-FoodX-INT(WS-Index-INT)
                        end-call
                        call "b_RandomRange" using
                            by value 2 30
                            returning WS-FoodY-INT(WS-Index-INT)
                        end-call
                        add 1 to WS-FoodTotal-INT
                        add 1 to WS-Index-INT
                    end-perform
                    move 0 to WS-Index-INT

                    move 20 to WS-Debounce-INT *> Horrible way to give player a little time to get ready after reset
                    move 0 to WS-GameOver-BOOL
                end-if
            end-if
        .

        draw section.
            *> Draw Loop
            call "BeginDrawing" end-call
            call "b_ClearBackground" using
                by value 0 0 0 255
            end-call

            *> Draw Snake
            move 1 to WS-Index-INT
            perform until WS-Index-INT = WS-SnakeLen-INT + 1
                move WS-SnakePartX-INT(WS-Index-INT) to WS-DrawX-INT
                move WS-SnakePartY-INT(WS-Index-INT) to WS-DrawY-INT

                multiply WS-DrawX-INT by 16 giving WS-CX-INT
                multiply WS-DrawY-INT by 16 giving WS-CY-INT
                add WS-BOffX-INT to WS-CX-INT
                add WS-BOffY-INT to WS-CY-INT

                call "b_DrawRectangle" using
                    by value WS-CX-INT WS-CY-INT 16 16
                    0 255 0 255
                end-call

                add 1 to WS-Index-INT
            end-perform
            move 0 to WS-DrawX-INT
            move 0 to WS-DrawY-INT
            
            *> Draw food
            move 1 to WS-Index-INT
            perform until WS-Index-INT = WS-FoodTotal-INT + 1
                move WS-FoodX-INT(WS-Index-INT) to WS-DrawX-INT
                move WS-FoodY-INT(WS-Index-INT) to WS-DrawY-INT

                multiply WS-DrawX-INT by 16 giving WS-CX-INT
                multiply WS-DrawY-INT by 16 giving WS-CY-INT
                add WS-BOffX-INT to WS-CX-INT
                add WS-BOffY-INT to WS-CY-INT

                call "b_DrawRectangle" using
                    by value WS-CX-INT WS-CY-INT 16 16
                    255 0 0 255
                end-call

                add 1 to WS-Index-INT
            end-perform
            move 0 to WS-DrawX-INT
            move 0 to WS-DrawY-INT
            move 0 to WS-Index-INT
            
            *> Draw Board
            perform until WS-DrawI-INT = WS-BSize-INT
                *> Set CX values to where we want to draw the gfx
                multiply WS-DrawX-INT by 16 giving WS-CX-INT        *> Scale by size of tiles
                multiply WS-DrawY-INT by 16 giving WS-CY-INT        
                add WS-BOffX-INT to WS-CX-INT                       *> Offset so board is center
                add WS-BOffY-INT to WS-CY-INT

                if WS-BTiles-INT(WS-DrawI-INT) = 1 then
                    call "b_DrawRectangle" using
                        by value WS-CX-INT WS-CY-INT 16 16
                        255 255 255 255
                    end-call
                end-if

                add 1 to WS-DrawX-INT
                if WS-DrawX-INT = WS-BWidth-INT then
                    add 1 to WS-DrawY-INT
                    move 0 to WS-DrawX-INT
                end-if

                add 1 to WS-DrawI-INT
            end-perform
            move 0 to WS-DrawI-INT
            move 0 to WS-DrawX-INT
            move 0 to WS-DrawY-INT

            *> Display score
            string
                "Score: " delimited by space
                " " delimited by size
                WS-SnakeLen-INT
                into WS-Score-String
            end-string

            call "b_DrawText" using
                by reference WS-Score-String
                by value 8 8 24
                255 255 255 255
            end-call

            *> Game Over
            if WS-GameOver-BOOL = 1 then
                string
                    "Final Score: " delimited by space
                    " " delimited by size
                    WS-SnakeLen-INT
                    into WS-EndScore-String
                end-string

                call "b_DrawText" using
                    by reference "GAME OVER"
                    by value 280 200 40
                    255 255 255 255
                end-call
                call "b_DrawText" using
                    by reference WS-EndScore-String
                    by value 340 250 30
                    255 255 255 255
                end-call
                call "b_DrawText" using
                    by reference "Press [SPACE] to restart!"
                    by value 200 560 30
                    255 255 255 255
                end-call
            end-if

            call "EndDrawing" end-call
        .

        dispose section.
            call "CloseWindow" end-call
            display function module-id " Ending"
        .
