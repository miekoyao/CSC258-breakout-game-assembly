################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
# Easy features implemented: 4, 7, 9
# Hard features implemented: 1, 3
#
# Student 1: Samira Dang, 1006448275
# Student 2: Mieko Yao, 1007141932
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

# An array of colours 
MY_COLOURS:
	.word	0xff0000    # red
	.word	0x00ff00    # green
	.word	0x0000ff    # blue
	.word	0xa7a7a7    # gray for walls
	.word	0x692aa8    # purple for paddle
	.word	0x000000	# black for erasing
	.word	0xffffff	# white for ball
	.word	0xffff66	# yellow for unbreakable bricks
	.word	0x880000    # maroon red
	.word	0xaa0000    # dark red
	
BALL:
	.word 15			# x
	.word 27			# y 
	.word 0			# moving  
	
PADDLE:
	.word 13	
	
BRICKS_BROKEN:
	.word 0
	
LIVES:
	.word 2

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    jal draw_setup
    b game_loop 

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
	
	# 0 sleep
	# 1a check if key has been pressed, move paddle
	# 1b move ball
	
	li $v0, 32
	li $a0, 25
	syscall
	
	jal draw_score

    #5. Go back to 1
    jal keyboard_input
    
    lw $t0, BALL + 8		# get the direction of current ball movement
    
    beq $t0, 1, move_ball_up
    beq $t0, 2, move_ball_down
    beq $t0, 3, move_ball_right_up
    beq $t0, 4, move_ball_right_down
    beq $t0, 5, move_ball_left_up
    beq $t0, 6, move_ball_left_down
    
    lw $t1, BRICKS_BROKEN
    beq $t1, 15, win_game
    
    b game_loop
        
draw_setup:  # draw the walls, (initial score not implemented yet), and initial bricks
	# DRAW THE WALLS
	move $s0, $ra
    li $a0, 0
    li $a1, 7
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 12     # colour_address = &MY_COLOURS[3]
    li $a2, 32
    jal draw_line_horiz			 # Draw top grey wall

    li $a0, 0
    li $a1, 7
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 12     # colour_address = &MY_COLOURS[3]
    li $a2, 25                   
    jal draw_line_vert   		 # Draw left grey wall
    
    li $a0, 31
    li $a1, 7
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 12     # colour_address = &MY_COLOURS[3]
    li $a2, 25                   
    jal draw_line_vert   		 # Draw right grey wall
    
    # DRAW THE BRICKS
    
    li $a0, 2
    li $a1, 10
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS          # colour_address = &MY_COLOURS[0]
    li $a2, 3
    li $a3, 6                 
    jal draw_line_bricks		# Draw red bricks
    
    li $a0, 2
    li $a1, 12
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 4         # colour_address = &MY_COLOURS[1]
    li $a2, 3
    li $a3, 6                 
    jal draw_line_bricks		  # Draw green bricks
        
    li $a0, 2
    li $a1, 14
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 8      # colour_address = &MY_COLOURS[1]
    li $a2, 3
    li $a3, 6                 
    jal draw_line_bricks		  # Draw blue bricks
    
    
    # DRAW UNBREAKABLE BRICKS
    # 1st unbreakable brick on the 3rd row
    li $a0, 7
    li $a1, 10
    jal get_location_address
    
    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 28  	# get COLOUR Yellow
    li $a2, 3
    li $a3, 1                 
    jal draw_line_bricks		  # Draw yellow bricks
    
    # 2nd unbreakable brick on the 2nd row
    li $a0, 17
    li $a1, 12
    jal get_location_address
    
    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 28  	# get COLOUR Yellow
    li $a2, 3
    li $a3, 1                 
    jal draw_line_bricks		  # Draw yellow bricks
    
    
    # DRAW BRICKS THAT REQUIRES MULTIPLE HITS
    # 1st brick on the 1st row
    li $a0, 2
    li $a1, 10
    jal get_location_address
    
    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 32  	# get COLOUR Maroon Red
    li $a2, 3
    li $a3, 1                 
    jal draw_line_bricks		  # Draw Maroon Red bricks
    
    # 2nd brick on the 2nd row
    li $a0, 22
    li $a1, 14
    jal get_location_address
    
    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 32  	# get COLOUR Maroon Red
    li $a2, 3
    li $a3, 1                 
    jal draw_line_bricks		  # Draw Maroon Red bricks
    
    
    # DRAW PADDLE AND BALL
    la $a0, MY_COLOURS + 16    # colour_address = &MY_COLOURS[3]                  
    jal draw_paddle   		 # Draw paddle
    
    jal draw_ball
    
    move $ra, $s0
    jr $ra

	
# get_location_address(x, y) -> address
#   Return the address of the unit on the display at location (x,y)
#
#   Preconditions:
#       - x is between 0 and 31, inclusive
#       - y is between 0 and 31, inclusive
get_location_address:
    # Each unit is 4 bytes. Each row has 32 units (128 bytes)
	sll 	$a0, $a0, 2				# x = x * 4
	sll 	$a1, $a1, 7             # y = y * 128

    # Calculate return value
	la 		$v0, ADDR_DSPL 			# res = address of ADDR_DSPL
    lw      $v0, 0($v0)             # res = address of (0, 0)
	add 	$v0, $v0, $a0			# res = address of (x, 0)
	add 	$v0, $v0, $a1           # res = address of (x, y)

    jr $ra

# draw_line_horiz(start, colour_address, width) -> void
#   Draw a line with width units horizontally across the display using the
#   colour at colour_address and starting from the start address.
#
#   Preconditions:
#       - The start address can "accommodate" a line of width units
draw_line_horiz:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
    
draw_line_horiz_loop:
    slt $t2, $t1, $a2           # i < width ?
    beq $t2, $0, draw_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 4        # Go to next unit

    addi $t1, $t1, 1            # i = i + 1
    b draw_line_horiz_loop

draw_line_epi:
    jr $ra


# draw_line_vert(start, colour_address, height) -> void
#   Draw a line with height units vertically down the display using the
#   colour at colour_address and starting from the start address.
#
#   Preconditions:
#       - The start address can "accommodate" a line of height units
draw_line_vert:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_line_vert_loop:
    slt $t2, $t1, $a2           # i < height ?
    beq $t2, $0, draw_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 128        # Go to next unit

    addi $t1, $t1, 	1            # i = i + 1
    b draw_line_vert_loop
    
   
# draw_line_bricks(start, colour_address, length_bricks, num_bricks) -> void
#   Draw a line of num_bricks bricks with width length_bricks across the display using the
#   colour at colour_address, starting from the start address, and spaced by 2.
#
#   Preconditions:
#       - The start address can "accommodate" at least num_bricks *(length_bricks+ 2) units
draw_line_bricks:
	# Iterate $a2 times, drawing a brick each time
    li $t3, 0                   # i = 0
    
draw_line_bricks_loop:
    slt $t4, $t3, $a3           # i < num_bricks ?
    beq $t4, $0, draw_bricks_epi  # if not, then done
    
    # draw a line length_bricks units long
		move $s1, $ra					# store instruction location of caller, because we will overwrite ra
    	jal draw_line_horiz    
		move $ra, $s1
	
	addi $a0, $a0, 8        	# add spacing of 2
    addi $t3, $t3, 1            # i = i + 1
    b draw_line_bricks_loop
 
draw_bricks_epi:
	jr $ra
    
	
	
	
# draw_paddle(colour) -> void
#   Draw the paddle at PADDLE 0 with colour
draw_paddle:
	# Retrieve the colour
    la $t0, 0($a0)              # colour = *colour_address
	lw $a0, PADDLE              # x = PADDLE[0]
    li $a1, 28			#  y = BALL[1]
    
    move $s1, $ra 	# store instruction location of caller, because we will overwrite ra
    jal get_location_address
    addi $a0, $v0, 0            # Put return value in $a0
    move $ra, $s1
    
    
    la $a1, 0($t0)             # colour = *colour_address
    li $a2, 5 	# width = 5
    move $s1, $ra 	# store instruction location of caller, because we will overwrite ra
    jal draw_line_horiz
    addi $a0, $v0, 0            # Put return value in $a0
    move $ra, $s1   
	jr $ra
	

	
# draw_ball() -> void
#   Draw the ball at (BALL[0], BALL[1])
#
#   Preconditions:
#       - Previous ball has already been erased
draw_ball:
    # Retrieve the colour
    lw $t0, MY_COLOURS + 24             # colour = *colour_address
    
    # Retrieve the coordinates
    lw $a0, BALL              # x = BALL[0]
    lw $a1, BALL + 4			#  y = BALL[1]
    
    move $s1, $ra 				# store instruction location of caller, because we will overwrite ra
    jal get_location_address
    addi $a0, $v0, 0            # Put return value in $a0
    move $ra, $s1
    
    sw $t0, 0($a0)          # Paint unit with colour    
	jr $ra
	

# erase_unit(address) -> void
#   Erase the unit at address
#
#   Preconditions:
#       - address is a valid location on the display
erase_unit:
    lw $t0, MY_COLOURS + 20 # Retrieve black colour
    sw $t0, 0($a0)          # Paint unit with colour    
	jr $ra
	
	
# draw_unit(address, colour) -> void
#   Draw a unit with colour at address#
#   Preconditions:
#       - address is a valid location on the display
draw_unit:
    sw $s5, 0($a0)          # Paint unit with colour    
	jr $ra



# move the paddle using keyboard input
# move the ball in any directions (no collisions)
# repaint the screen in a loop to visualize movement
# allow the player to quit the game
keyboard_input:
    lw $t0, ADDR_KBRD
    lw $t8, 0($t0)
    beq $t8, 1, move_on_keyboard
    jr $ra
    
    move_on_keyboard: #a key is pressed
    lw $a0, 4($t0)
    lw $t8, 4($t0)
    beq $t8, 0x61, press_a_left	# a is pressed
    beq $t8, 0x64, press_d_right	# d is pressed
    beq $t8, 0x71, quit_game	# q is pressed
    # add key to move the ball
    beq $t8, 0x20, move_ball_up
    beq $t8, 0x62, move_ball_down
    beq $t8, 0x63, move_ball_left_up
    beq $t8, 0x6e, move_ball_right_up
    beq $t8, 0x78, move_ball_left_down
    beq $t8, 0x6d, move_ball_right_down
    jr $ra
    
    press_a_left:
    move $s0, $ra
    li $v0, 1
    syscall
    
    lw $t8, PADDLE
    beq $t8, 1, end_move    # check if paddle[0] > 1
   
    addi $t8, $t8, -1
    # erase paddle completely
    la $a0, MY_COLOURS + 20 	# colour = black
    jal draw_paddle
    #jal draw_paddle 
    sw $t8 PADDLE
    # draw paddle at new 
    la $a0, MY_COLOURS + 16
    jal draw_paddle
    
    lw $t7, BALL + 8
    
    move $ra, $s0
    beq $t7, 0, paddle_ball_left
    jr $ra
    
    press_d_right:
    move $s0, $ra
    li $v0, 1
    syscall
    
    lw $t8, PADDLE
    beq $t8, 26, end_move
    addi $t8, $t8, 1
    # erase paddle completely
    la $a0, MY_COLOURS + 20 	# colour = black
    jal draw_paddle
    #jal draw_paddle 
    sw $t8, PADDLE
    # draw paddle at new 
    la $a0, MY_COLOURS + 16
    jal draw_paddle
    
    lw $t7, BALL + 8
    
    move $ra, $s0
    beq $t7, 0, paddle_ball_right
    jr $ra
    
    quit_game:
    j end_game
    
paddle_ball_left:
	move $s3, $ra
	jal erase_ball
	lw $t0, BALL
	addi $t0, $t0, -1
	sw $t0, BALL
	
	jal draw_ball
	
	move $ra, $s3
	jr $ra
	
paddle_ball_right:
	move $s3, $ra
	jal erase_ball
	lw $t0, BALL
	addi $t0, $t0, 1
	sw $t0, BALL
	
	jal draw_ball
	
	move $ra, $s3
	jr $ra
	
    
move_ball_up:		# when space is pressed
	addi $t0, $zero, 1	
	sw $t0, BALL + 8 	# change ball movement direction to up
	
    lw $t8, BALL + 4            # y = BALL[1]
    addi $t8, $t8, -1
    # erase ball
    jal erase_ball
    
    lw $a0, BALL	#x= BALL[0]
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_down		# ball has hit something, move in opposite dir
   
    sw $t8, BALL + 4
    jal draw_ball
    
    j game_loop
    #move $ra, $s0  
    #jr $ra
    
    
move_ball_down:		# when key b is pressed
	addi $t0, $zero, 2	
	sw $t0, BALL + 8 	# change ball movement direction to down
    lw $t8, BALL + 4            # y = BALL[1]
    addi $t8, $t8, 1
    # erase ball
    jal erase_ball
    
    lw $a0, BALL	#x= BALL[0]
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_up		# ball has hit something, move in opposite dir
   	
    sw $t8, BALL + 4
    jal draw_ball 
     
	
    j game_loop
    #move $ra, $s0  
    #jr $ra

    
move_ball_right_up:		# when key n is pressed
	addi $t0, $zero, 3	
	sw $t0, BALL + 8 	# change ball movement direction to right_up
    lw $t7, BALL              # x = BALL[0]
    lw $t8, BALL + 4		#  y = BALL[1]
    addi $t7, $t7, 1
    addi $t8, $t8, -1
    
    jal erase_ball	# erase ball
    
    addi $a0, $t7, 0		#x= $t7
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_left_up		# ball has hit something, move in opposite dir
   	
    sw $t7, BALL     
    sw $t8, BALL + 4
    jal draw_ball 
    
   	li $v0, 32
	li $a0, 15
	syscall
   	
    j game_loop

move_ball_right_down:	# when key m is pressed
	addi $t0, $zero, 4	
	sw $t0, BALL + 8 	# change ball movement direction to right_down
    lw $t7, BALL              # x = BALL[0]
    lw $t8, BALL + 4		#  y = BALL[1]
    addi $t7, $t7, 1
    addi $t8, $t8, 1
    
    jal erase_ball	# erase ball
    
    addi $a0, $t7, 0		#x= $t7
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_left_up		# ball has hit something, move in opposite dir
   	
    sw $t7, BALL     
    sw $t8, BALL + 4
    jal draw_ball 
    
   	li $v0, 32
	li $a0, 15
	syscall
	
    j game_loop
    
move_ball_left_up:	# when key c is pressed
	addi $t0, $zero, 5	
	sw $t0, BALL + 8 	# change ball movement direction to left_up
    lw $t7, BALL              # x = BALL[0]
    lw $t8, BALL + 4		#  y = BALL[1]
    addi $t7, $t7, -1
    addi $t8, $t8, -1
    
    jal erase_ball	# erase ball
    
    addi $a0, $t7, 0		#x= $t7
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_left_down		# ball has hit something, move in opposite dir
   		
    sw $t7, BALL     
    sw $t8, BALL + 4
    jal draw_ball 
    
   	li $v0, 32
	li $a0, 15
	syscall
	
    j game_loop

    
move_ball_left_down:	# when key x is pressed
	addi $t0, $zero, 6	
	sw $t0, BALL + 8 	# change ball movement direction to left_down
    lw $t7, BALL              # x = BALL[0]
    lw $t8, BALL + 4		#  y = BALL[1]
    addi $t7, $t7, -1
    addi $t8, $t8, 1
    
    jal erase_ball	# erase ball
    
    addi $a0, $t7, 0		#x= $t7
    addi $a1, $t8, 0		#y = $t8
    
    jal check_filled
    addi $t4, $v0, 0	# put return value in $t4
    
    beq $t4, 1, move_ball_right_down		# ball has hit something, move in opposite dir
   	
   	sw $t7, BALL     
    sw $t8, BALL + 4
    jal draw_ball 
    
   	li $v0, 32
	li $a0, 15
	syscall
    
    j game_loop
            
erase_ball:
    lw $a0, BALL              # x = BALL[0]
    lw $a1, BALL + 4		#  y = BALL[1]
    lw $t0, MY_COLOURS + 20              
    
    move $s1, $ra 		# store instruction location of caller, because we will overwrite ra
    jal get_location_address
    addi $a0, $v0, 0            # Put return value in $a0
    move $ra, $s1
    
    sw $t0, 0($a0)          # Paint unit with colour    
	jr $ra


end_move:
    j game_loop
    
# check_filled(x, y) -> bool
# 	Check if square (x, y) is filled. 
#	End game if at bottom of board
#	change direction if hit paddle
# 	delete brick if hit brick
# 	Return 1 if filled, 0 if unfilled
check_filled:
	beq $a1, 32, end_game	# end game if ball is at bottom
	addi $t3, $a0, 0		# store x coord of ball
	
	move $s0, $ra
	jal get_location_address # get location address of x, y
	move $ra, $s0
	
	#la $a0, 0($v0)				# store address in $a0
    lw $a0, 0($v0)            # Put colour at address in $a0
    
    
 	beq $a0, 0, not_filled
 	beq $a0, 0x692aa8, hit_paddle
 	beq $a0, 0x0000ff, hit_brick
 	beq $a0, 0x00ff00, hit_brick
 	beq $a0, 0xff0000, hit_brick
 	beq $a0, 0x880000, change_colour
	beq $a0, 0xaa0000, change_colour 	
 	beq $a0, 0xa7a7a7, hit_wall
 	
	hit_wall:
		li $v0, 1
		jr $ra
	
	not_filled:
		li $v0, 0
		jr $ra
	
	hit_paddle:
		lw $t4, PADDLE
		beq $t4, $t3, move_ball_left_up
		
		addi $t4, $t4, 1
		beq $t4, $t3, move_ball_left_up
		
		addi $t4, $t4, 1
		beq $t4, $t3, move_ball_up
		
		addi $t4, $t4, 1
		beq $t4, $t3, move_ball_right_up
		
		addi $t4, $t4, 1
		beq $t4, $t3, move_ball_right_up
		
		b end_game
	
	hit_brick:
		move $s0, $ra
		lw $t0, BRICKS_BROKEN
		addi $t0, $t0, 1
		sw $t0, BRICKS_BROKEN	# increase BRICKS_BROKEN by 1
		
		addi $a0, $v0, 0
		
		# check if left side of hit brick is black
		addi $t1, $a0, -4		# get left brick
		lw $t2, 0($t1)			# get colour of left brick
		beq $t2, 0, delete_left
		
		
		# check if right side of hit brick is black
		addi $t1, $a0, 4			# get right brick
		lw $t2, 0($t1)			# get colour of right brick
		beq $t2, 0, delete_right
		
		
		# brick has been hit in middle
		b delete_middle
		
		
		# add sound effect when a brick is broken
		sound_effect:
			li  $v0, 33
			addi $a0, $zero, 50
			addi $a1, $zero, 100
			addi $a2, $zero, 121
			addi $a3, $zero, 127
			syscall 
			jr $ra
		
		delete_left:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal erase_unit
			addi $a0, $a0, 4
			jal erase_unit
			addi $a0, $a0, 4
			jal erase_unit
			move $ra, $s0
			li $v0, 1
			jr $ra
			
			
		delete_right:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal erase_unit
			addi $a0, $a0, -4
			jal erase_unit
			addi $a0, $a0, -4
			jal erase_unit
			move $ra, $s0
			li $v0, 1
			jr $ra
		
		delete_middle:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal erase_unit
			addi $a0, $a0, 4
			jal erase_unit
			addi $a0, $a0, -8
			jal erase_unit
			move $ra, $s0
			li $v0, 1
			jr $ra
			
	change_colour:
		### set a register to be the colour to change to depending on brick colou
		
		move $s0, $ra
		beq $a0, 0x880000, maroon_red
		beq $a0, 0xaa0000, dark_red
		
		recolour:
			addi $a0, $v0, 0
		
			# check if left side of hit brick is black
			addi $t1, $a0, -4		# get left brick
			lw $t2, 0($t1)			# get colour of left brick
			beq $t2, 0, change_left
		
		
			# check if right side of hit brick is black
			addi $t1, $a0, 4			# get right brick
			lw $t2, 0($t1)			# get colour of right brick
			beq $t2, 0, change_right
		
			# brick has been hit in middle
			b change_middle
		
		
		maroon_red:
    			lw $s5, MY_COLOURS + 36  	# get COLOUR dark red
    			b recolour
		
		dark_red:          
    			lw $s5, MY_COLOURS		  	# get COLOUR red
   			b recolour
    			
    		change_left:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal draw_unit
			addi $a0, $a0, 4
			jal draw_unit
			addi $a0, $a0, 4
			jal draw_unit
			
			move $ra, $s0
			li $v0, 1
			jr $ra
			
			
		change_right:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal draw_unit
			addi $a0, $a0, -4
			jal draw_unit
			addi $a0, $a0, -4
			jal draw_unit
			
			move $ra, $s0
			li $v0, 1
			jr $ra
		
		change_middle:
			add $t1, $a0, $zero
			jal sound_effect
			add $a0, $t1, $zero
			jal draw_unit
			addi $a0, $a0, 4
			jal draw_unit
			addi $a0, $a0, -8
			jal draw_unit
			
			move $ra, $s0
			li $v0, 1
			jr $ra
		
		
	

end_game:
	la $t0, LIVES         # temp = &LIVES
    lw $t1, 0($t0)   
    addi $t1, $t1, -1		# update the remaining lives
    sw $t1, 0($t0)
	slt $t4, $t1, $zero		# set $t4 to 0 if LIVES < 0
	beqz $t4, draw_end_screen
	j main  

draw_end_screen:
    lw $a0, BALL


win_game:
    jal draw_win_screen    

draw_win_screen:
    lw $a0, BALL

draw_score:
	lw $s7, BRICKS_BROKEN		# get current score
	move $s4, $ra
	jal erase_score
    	
	blt $s7, 10, draw_ones		# draw ones digit if score is less than 10
	
	li $a0, 24
    li $a1, 1
    jal get_location_address
    
    addi $a0, $v0, 0            # Put return value in $a
	jal draw_1
	
	
	addi $s7, $s7, -10
	b draw_ones
	
    
# when draw_ones is called, $t0 is set to the score needed to be drawn
draw_ones:
	li $a0, 28
    li $a1, 1
    jal get_location_address
    addi $a0, $v0, 0            # Put return value in $a0
    
    move $ra, $s4
    
    beq $s7, 9, draw_9
    beq $s7, 8, draw_8
    beq $s7, 7, draw_7
    beq $s7, 6, draw_6
    beq $s7, 5, draw_5
    beq $s7, 4, draw_4
    beq $s7, 3, draw_3
    beq $s7, 2, draw_2
    beq $s7, 1, draw_1
    beq $s7, 0, draw_0
    
    
 
draw_9:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    
    move $s0, $ra
    jal draw_line_vert		# draw left line
    move $ra, $s0
    
    addi $a0, $a0, -128
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    addi $a0, $a0, -4
    sw $t3, 0($a0)
       
    addi $a0, $a0, -256
    sw $t3, 0($a0)
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    
    addi $a0, $a0, 256
    addi $a0, $a0, 4
    sw $t3, 0($a0)    
    
    jr $ra 
 
draw_8:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    move $s0, $ra
    jal draw_line_vert		# draw left line
    move $ra, $s0
    
    addi $a0, $a0, -128 
    addi $a0, $a0, 4
    sw $t3, 0($a0)			# draw bottom line
    addi $a0, $a0, 4			
    
    addi $a0, $a0, -512		# move address back to top of rect
    move $s0, $ra
    jal draw_line_vert		# draw right line
    move $ra, $s0
    
    addi $a0, $a0, -384
    addi $a0, $a0, -4
    
    sw $t3, 0($a0)	# draw middle line	
    addi $a0, $a0, -256
    sw $t3, 0($a0)	# draw top line	
    jr $ra
   
draw_7:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    
    move $s0, $ra
    jal draw_line_vert		# draw left line
    move $ra, $s0
    
    jr $ra  
  
draw_6:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    
    addi $a0, $a0, 256
    sw $t3, 0($a0)
    addi $a0, $a0, 128
    sw $t3, 0($a0)
    addi $a0, $a0, 128
    sw $t3, 0($a0)
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    
    addi $a0, $a0, 4
    addi $a0, $a0, -256 
    sw $t3, 0($a0)
    
    addi $a0, $a0, -4
    addi $a0, $a0, -256
    
    move $s0, $ra
    jal draw_line_vert		# draw left line
    move $ra, $s0
    
    jr $ra 
       

draw_5:
	lw $t3, MY_COLOURS + 24
    
    addi $a0, $a0, 512
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    addi $a0, $a0, -128
    sw $t3, 0($a0)
    
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    
    jr $ra 
    
   
draw_4:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    
    sw $t3, 0($a0)
    addi $a0, $a0, 128
    sw $t3, 0($a0)
    addi $a0, $a0, 128
    sw $t3, 0($a0)		# draw left line
    
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    addi $a0, $a0, -256
    
    move $s0, $ra
    jal draw_line_vert		# draw right line
    move $ra, $s0
    jr $ra   

draw_3:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    sw $t3, 0($a0)
    addi $a0, $a0, 4
    
    move $s0, $ra
    jal draw_line_vert		# draw right line
    move $ra, $s0
    
    addi $a0, $a0, -128
    addi $a0, $a0, -4
    sw $t3, 0($a0)
    addi $a0, $a0, -4
    sw $t3, 0($a0)			# draw bottom line
    
    addi $a0, $a0, -256
    sw $t3, 0($a0)	
    addi $a0, $a0, 4
    sw $t3, 0($a0)			# draw middle line
    
    jr $ra
    
   
# draw_2(address) -> void
# 	Draw a 2 at address	
# precondition: address can accomodate a 3x5 rectangle being drawn 
draw_2:
    lw $t0, MY_COLOURS + 24 # Retrieve white colour
    sw $t0, 0($a0)          
    addi $a0, $a0, 4
    sw $t0, 0($a0)         
    addi $a0, $a0, 4
    sw $t0, 0($a0)          # finish drawing top line
    addi $a0, $a0, 128
    sw $t0, 0($a0)          
    addi $a0, $a0, 128
    sw $t0, 0($a0)          # finish top right segment
    addi $a0, $a0, -4
    sw $t0, 0($a0)
    addi $a0, $a0, -4		# middle segment
	sw $t0, 0($a0)
	addi $a0, $a0, 128		
    sw $t0, 0($a0)
	addi $a0, $a0, 128		# bottom left segment
    sw $t0, 0($a0)
    addi $a0, $a0, 4	
    sw $t0, 0($a0)
    addi $a0, $a0, 4		# bottom segment
    sw $t0, 0($a0)
    
    jr $ra
    
# draw_1(address) -> void
# 	Draw a 1 at address	
# precondition: address can accomodate a 3x5 rectangle being drawn 
draw_1:
    addi $a0, $a0, 8
    la $a1, MY_COLOURS + 24
    li $a2, 5
    move $s0, $ra
    jal draw_line_vert
    move $ra, $s0
    jr $ra
    
# draw_0(address) -> void
# 	Draw a 0 at address	
# precondition: address can accomodate a 3x5 rectangle being drawn 
draw_0:
	lw $t3, MY_COLOURS + 24
    la $a1, MY_COLOURS + 24
    li $a2, 5
    move $s0, $ra
    jal draw_line_vert		# draw left line
    move $ra, $s0
    
    addi $a0, $a0, -128 
    addi $a0, $a0, 4
    sw $t3, 0($a0)			# draw bottom line
    addi $a0, $a0, 4			
    
    addi $a0, $a0, -512		# move address back to top of rect
    move $s0, $ra
    jal draw_line_vert		# draw right line
    move $ra, $s0
    
    addi $a0, $a0, -640
    addi $a0, $a0, -4
    
    sw $t3, 0($a0)	# draw top line			
    jr $ra
    
erase_score:
    li $a0, 24
    li $a1, 1
    move $s0, $ra
    jal get_location_address
    addi $a0, $v0, 0            # Put return value in $a0
    la $a1, MY_COLOURS + 20     # colour_address = &MY_COLOURS[3]
    li $a2, 7
    li $t3, 0                   # i = 0
    
erase_score_loop:
	li $t8, 5
    slt $t4, $t3, $t8           # i < 5 rows
    beq $t4, $0, erase_score_epi  # if not, then done
    
    # draw a line length_bricks units long
		jal draw_line_horiz  
	
	addi $a0, $a0, -28        	# move to next row down
	addi $a0, $a0, 128        	# move to next row down
    addi $t3, $t3, 1            # i = i + 1
    b erase_score_loop
 
erase_score_epi:
	move $ra, $s0
	jr $ra
	
	

## TODO:
# check y value when bouncing?
# unbreakable bricks -> +1 easy
# when moving paddle at beginning, if ball not launched yet, move ball left and right -> +1 easy
# bricks that change colours -> repurpose delete function to have redraw w diff colours and only log score if broken
	# -> +1 hard


##### FEATURES
## HARD 1: display score					DONE
## HARD 2: display highest score
## HARD 3: bricks need to be hit multiple times

## EASY 1: multiple lives 				
## EASY 2: game over screen
## EASY 4: sound effects				DONE
## EASY 5: pause game
## EASY 7: unbreakable bricks			
## EASY 9: launch ball at beginning of each attempt -> need to make ball at beginning move with paddle






