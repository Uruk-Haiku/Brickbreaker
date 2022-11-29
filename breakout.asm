################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Omar, Alshawa, 1007198186
# Student 2: Benjamin Panet, 1008121417
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       16
# - Unit height in pixels:      16
# - Display width in pixels:    512
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
# Play Notes
##############################################################################
# Only play using 1 finger at a time. If you do inputs to frequently (>1 every
# 20 milliseconds) MARS will completely lock up and need to be task-ended.
# This is a known MARS bug and not our fault. If you play with a single finger,
# it should be impossible to exceed this limit. Just to be clear, this is a 
# MARS bug and there is nothing we can do about it other than avoid it.

##############################################################################
# Design Notes
##############################################################################
# Bricks of the same colour must never be placed touching side-to-side. Up and
# down is fine. This is due to how the algorithm for breaking bricks works.

##############################################################################
# Plan:
##############################################################################
#
#SECTION 1: EASY FFEATURES:
#1. Game over screen with retry option 
#2. Allow user to pause with p
#3. Unbreakable bricks.
#
#SECTION 2: hARD FREATURES:
#1. REQUIRE BRICKS TO BE HIT MULTIPLE TIMES
#2. Animation for bricks when they dissappear/get damaged.	


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
BLUE:
    .word 0x0000ff
RED:
    .word 0xff0000
GREEN:
    .word 0x00ff00
ERROR_OUT:
    .asciiz "ERROR! SOMETHING BROKE!"
GAME_OVER:
    .asciiz "GAME OVER!"



##############################################################################
# Mutable Data
##############################################################################
PADDLE:
BALL:

##############################################################################
# Register conventions:
#s1: Stores memory address of keyboard.
#s2: Stores paddle left endpoint.
#s3: Stores ball location
#s4: Stores ball direction. Ball only moves up or down, or 45 degrees left or right, up or down.
#s5: Stores next ball position. Largely only used for detecting collisions.
# The 6 values $s4 can take on:
# Straight up = -128
STRAIGHT_UP:
	.word -128
# Straight down = 128
STRAIGHT_DOWN:
	.word 128
# Up Left = -132
UP_LEFT:
	.word -132
# Up Right = -124
UP_RIGHT:
	.word -124
# Down Left = 124
DOWN_LEFT:
	.word 124
# Down Right = 128
DOWN_RIGHT:
	.word 132

#t0: Always used as loop variable i.
#t5: Always used as number of iterations for loop.
#t1: Stores color whenever needed to paint a pixel.
#t2: Stores location of pixel when needed to color it.
#t3: May be used to store location of pixel when coloring, and then used to
# help check pixel colour when computing collisions.
#t4: Stores the colour of the ball's next location

# Argument registers are so far used only during the brickbreak function
#a0: Used for storing position of first pixel broken during a brickbreak
#a1: Used for storing COLOUR of LEFT pixel during a brickbreak
#a2: Used for storing COLOUR of RIGHT pixel during a brickbreak
##############################################################################


##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
        lw $gp, ADDR_DSPL
        lw $s1, ADDR_KBRD
        #lw $s2, PADDLE:
        #lw $s3, BALL:
        addi $t0, $t0, 1 #i = 1
        addi $t5, $t5, 27
        addi $t2, $gp, 768 #offset gp by 768 to reach the start of the grey lne.
        addi $t3, $gp, 892 #offset to reach the right side of the screen on the same line. 892-768= 124. Screen is 128 memory addresses wide.
        li $t1, 0x808080 #use t1 to store grey.
    
vwall_loop:
	beq $t0, $t5, hwall_loop_setup
    	sw $t1, 0($t2) #store grey in t2
    	sw $t1, 0($t3) #store grey in t3
    	addi $t2, $t2, 128
    	addi $t3 $t3, 128
    	addi $t0, $t0, 1 #i + 1
    	j vwall_loop 
hwall_loop_setup:
	addi $t2, $gp, 768 #set up horizontal line. t2 keeps track of pixels.
	li $t0, 0 #reset t0 to be counter for hwall_loop
	li $t5, 32 #limit for hwall_loop
	
hwall_loop:
 	beq $t0, $t5, paddle_loop_setup
 	sw $t1, 0($t2) #make pixel grey
 	addi $t2, $t2, 4 #update pixel position
 	addi $t0, $t0, 1
 	j hwall_loop 	

paddle_loop_setup:
	addi $t2, $gp, 4020 #next to midpoint of last line
	li $s2, 0x10008fb4 #location of the left pixel of the paddle.
	li $t0, 0 #setup loop variable i
	li $t5, 5 #loop limit.
	li $t1, 0x008000 #color green.
draw_paddle:
	beq $t0, $t5, brick_setup1
 	sw $t1, 0($t2) #make pixel green
 	addi $t2, $t2, 4 #update pixel position
 	addi $t0, $t0, 1 
 	j draw_paddle
 
brick_setup1:
	li $t3, 0 #setup variable so we can go through each brick color/line. Saves lines.
brick_setup:
	addi $t3, $t3, 1
	beq $t3, 1, red_brick_setup
	beq $t3, 2, orange_brick_setup
	beq $t3, 3, yellow_brick_setup
	j ball_setup
 
red_brick_setup:
	li $t1, 0x800000
 	li $t7, 0x000000
 	addi $t2, $gp, 900
 	li $t0, 0
 	li $t5, 7
 	j draw_brick
 
orange_brick_setup:
	li $t1, 0xffa5000
 	li $t7, 0x000000
 	addi $t2, $gp, 1028
 	li $t0, 0
 	li $t5, 7
 	j draw_brick
 
yellow_brick_setup:
	li $t1, 0xffff000
 	li $t7, 0x000000
 	addi $t2, $gp, 1156
 	li $t0, 0
 	li $t5, 7
 	j draw_brick	
 		
draw_brick:
	beq $t0, $t5, brick_setup #choose the color of the brick, set up location of the row to draw it.
	sw $t7, 0($t2)
	sw $t1, 4($t2)
	sw $t1, 8($t2)
	sw $t1, 12($t2)
	addi $t0, $t0, 1
	addi $t2, $t2, 16
 	j draw_brick
	 
 
ball_setup:
	li $t1, 0xffffff #color white for the ball
	sw $t1, 3900($gp) #draw ball at starting location
	addi $s3, $gp, 3900 #write ball starting location into the tracking register
	li $s4, -128 #Set ball default direction to straight up
	
game_loop:
	# Check to see if player has lost
	bge $s3, 0x10008FFC player_lost
	# Check for keyboard input
	lw $t7, 0($s1) # Pull address of keyboard input
	beq $t7, 1, keyboard_input # Has input happened?
    	# Check for collisions
    	j collision_check #run check collisions
update_location:
	# Handle breaks if they occur
	
	# Redraw ball
	li $t1, 0x000000 #make $t1 black
	sw $t1, 0($s3) #draw black in old spot of ball
	add $s3, $s3, $s4 #increment position with direction
	li $t1, 0xffffff #make $t1 white
	sw $t1, 0($s3) #draw white in new spot of ball
	# Sleep
	li $v0, 32 # Set operation to sleep
	li $a0, 40 # Set length of sleep in milliseconds
	syscall # Actually go to sleep

    	# Jump back to the top of the loop
   	 j game_loop

keyboard_input:
	lw $t7, 4($s1) #get input from keyboard.
	beq $t7, 0x61, respond_to_a
	beq $t7, 0x64, respond_to_d
	beq $t7, 0x1B, respond_to_esc
	beq $t7, 0x70, respond_to_p
	j game_loop
	
respond_to_a:
	beq $s2, 0x10008f84, game_loop #location of left grey wall. If equal, branch to game_loop and dont move the paddle.
	li $t1, 0x000000 #color black to recolor the right side of the paddle.
	sw $t1, 16($s2) #color right side of paddle black.
	addi $s2, $s2, -4 #move s0 to be on the left of the paddle.
	li $t1, 0x008000 #color dark green.
	sw $t1, 0($s2) #color new position of paddle pixel green.
	j game_loop
	
respond_to_d:#same as respond_to_a but for the right side.
	beq $s2, 0x10008fe8, game_loop
	li $t1, 0x000000 
	sw $t1, 0($s2)
	addi $s2, $s2, 4
	li $t1, 0x008000
	sw $t1, 16($s2)
	j game_loop
	
respond_to_esc: #stop the game once escape is clicked. Should be updated if we want an EXIT screen.
	li $v0, 10
	syscall

respond_to_p: #pause the game
	lw $t7, 0($s1)
	beq $t7, 1, unpause_game
	j respond_to_p
	
unpause_game:
	lw $t7, 4($s1)
	beq $t7, 0x70, game_loop
	j respond_to_p
	
player_lost:
	# Test of boundaries
	# TODO delete this
	li $t1, 0xaa00aa
	sw $t1, 0x10008FFC # Draw pixel at largest acceptable memory address in $gp
	# Test over
	li $v0, 4 # Set operation to print string
	la $a0, GAME_OVER # String to print
	syscall # Actually print the string
	li $v0, 10 # Set operation to close game
	syscall # Actually close game
	






collision_check:
	beq $s4, -128, collision_check_up # handle collision check if ball is going straight up
	beq $s4, 128, collision_check_down # handle collision check if ball is going straight down
	beq $s4, -132, collision_check_ul # handle collision check if ball is going diagonally up and left
	beq $s4, -124, collision_check_ur # handle collision check if ball is going diagonally up and right
	beq $s4, 124, collision_check_dl # handle collision check if ball is going diagonally down and left
	beq $s4, 132, collision_check_dr # handle collision check if ball is going diagonally down and right
	j error # Never should be reached
	
	
	
collision_check_up: # DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	li $s4, 128 # Ball bounces, new direction is always straight down.
	# Breaking the brick
	add $a0, $s3, -128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check # Ball has bounced, now go move. Ball will NEVER hit paddle on upwards motion.



collision_check_down: # DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	li $s4, -128 # Ball bounces, new direction is always straight up.
	# Breaking the brick
	add $a0, $s3, 128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler



collision_check_ul: # PROBABLY DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	# We have just confirmed corner is not black. Something is there.
	# Check wall
	lw $t1, -4($s3) # Set $t1 to the colour of the pixel to the left of the ball's CURRENT position
	beq $t1, 0x000000, ul_q_ceiling_no_wall # If no wall, jump to "Questioning ceiling, no wall"
	# Wall is confirmed
	lw $t1, -128($s3) # Set $t1 to the colour of the pixel directly above the ball's CURRENT position
	beq $t1, 0x000000, ul_no_ceiling_yes_wall # If no ceiling, jump to "No ceiling, yes wall"
	# Wall AND ceiling are confirmed
ul_corner_or_edge: # For hitting a corner (wall and ceiling) or edge (no wall, no ceiling)
	# Bounce is therefore inverting direction, so ball goes down and right
	li $s4, 132 # Set direction to down and right
	# Breaking the brick
	add $a0, $s3, -132 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check # Ball has bounced, go move and confirm no further collisions.
ul_q_ceiling_no_wall:
	lw $t1, -128($s3) # Set $t1 to the colour of the pixel directly above the ball
	beq $t1, 0x000000, ul_corner_or_edge # There is no ceiling or wall, so this is an edge
	# Ceiling confirmed, no wall
	# So therefore, bounce is now down and left
	li $s4, 124 # Set direction to down and left
	# Breaking the brick
	add $a0, $s3, -128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check
ul_no_ceiling_yes_wall:
	# No ceiling, yes wall, so new direction is up and right
	li $s4, -124
	# Breaking the brick
	add $a0, $s3, -4 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check
	
	

collision_check_ur: # PROBABLY DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	# We have just confirmed corner is not black. Something else is there.
	# Check wall
	lw $t1, 4($s3) # Set $t1 to the colour of the pixel to the right of the ball's CURRENT position
	beq $t1, 0x000000, ur_q_ceiling_no_wall # If no wall, jump to "Questioning ceiling, no wall"
	# Wall is confirmed
	lw $t1, -128($s3) # set $t1 to the colour of the pixel directly above the ball's CURRENT position
	beq $t1, 0x000000, ur_no_ceiling_yes_wall # If no ceiling, jump to "No ceiling, yes wall"
	# Wall AND ceiling are confirmed
ur_corner_or_edge: # For hitting a corner (wall and ceiling) or edge (no wall, no ceiling)
	# Bounce is therefore inverting direction, so ball goes down and left
	li $s4, 124 # Set direction to down and left
	# Breaking the brick
	add $a0, $s3, -124 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check # Ball has bounced, go move and confirm no further collisions.
ur_q_ceiling_no_wall:
	lw $t1, -128($s3) # Set $t1 to the colour of the pixel directly above the ball
	beq $t1, 0x000000, ur_corner_or_edge # There is no ceiling or wall, so this is an edge
	# Ceiling confirmed, no wall
	# So therefore, bounce is now down and right
	li $s4, 132 # Set direction to down and right
	# Breaking the brick
	add $a0, $s3, -128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check
ur_no_ceiling_yes_wall:
	# No ceiling, yes wall, so new direction is up and left
	li $s4, -132
	# Breaking the brick
	add $a0, $s3, 4 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	j collision_check



collision_check_dl: # PROBABLY DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	# Check wall, we have just confirmed there is something else in the corner.
	lw $t1, -4($s3) # Set $t1 to the colour of the pixel to the left of the ball's CURRENT position
	beq $t1, 0x000000, dl_q_floor_no_wall # If no wall, jump to "Questioning floor, no wall"
	# Wall is confirmed
	lw $t1, 128($s3) # set $t1 to the colour of the pixel directly below the ball's CURRENT position
	beq $t1, 0x000000, dl_no_floor_yes_wall # If no floor, jump to "No floor, yes wall"
	# Wall AND floor are confirmed
dl_corner_or_edge: # For hitting a corner (wall and floor) or edge (no wall, no floor)
	# Bounce is therefore inverting direction, so ball goes up and right
	li $s4, -124 # Set direction to up and right
	# Breaking the brick
	add $a0, $s3, 124 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle
dl_q_floor_no_wall:
	lw $t1, 128($s3) # Set $t1 to the colour of the pixel directly below the ball
	beq $t1, 0x000000, dl_corner_or_edge # There is no ceiling or wall, so this is an edge
	# Floor confirmed, no wall. So therefore, bounce is now up and left
	li $s4, -132 # Set direction to up and left
	# Breaking the brick
	add $a0, $s3, 128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle
dl_no_floor_yes_wall:
	# No floor, yes wall, so new direction is down and right
	li $s4, 132
	# Breaking the brick
	add $a0, $s3, -4 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle
	
	
collision_check_dr: # PROBABLY DONE
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t4
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	# Check wall, we have just confirmed there is something else in the corner.
	lw $t1, 4($s3) # Set $t1 to the colour of the pixel to the right of the ball's CURRENT position
	beq $t1, 0x000000, dr_q_floor_no_wall # If no wall, jump to "Questioning floor, no wall"
	# Wall is confirmed
	lw $t1, 128($s3) # set $t1 to the colour of the pixel directly below the ball's CURRENT position
	beq $t1, 0x000000, dr_no_floor_yes_wall # If no floor, jump to "No floor, yes wall"
	# Wall AND floor are confirmed
dr_corner_or_edge: # For hitting a corner (wall and floor) or edge (no wall, no floor)
	# Bounce is therefore inverting direction, so ball goes up and left
	li $s4, -132 # Set direction to up and left
	# Breaking the brick
	add $a0, $s3, 132 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle
dr_q_floor_no_wall:
	lw $t1, 128($s3) # Set $t1 to the colour of the pixel directly below the ball
	beq $t1, 0x000000, dr_corner_or_edge # There is no ceiling or wall, so this is an edge
	# Floor confirmed, no wall. So therefore, bounce is now up and right
	li $s4, -124 # Set direction to up and right
	# Breaking the brick
	add $a0, $s3, 128 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle
dr_no_floor_yes_wall:
	# No floor, yes wall, so new direction is down and left
	li $s4, 124
	# Breaking the brick
	add $a0, $s3, 4 # Load pixel bounced off of in this case
	jal break_brick # Break the break that pixel is attached to, IFF it is a brick.
	bne $t4, 0x008000, collision_check # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler # Since it is bouncing off paddle, go handle



paddle_handler:
	# Bouncing off leftmost pixel in paddle
	li $s4, -132 # Set new ball direction IF this is the correct paddle pixel
	add $t3, $s2, 0 # Set $t3 to the left endpoint of paddle
	beq $s5, $t3, update_location # Ball next position WILL be this pixel
	# Bouncing off centre-left pixel in paddle
	li $s4, -132 # Set new ball direction IF this is the correct paddle pixel
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $s5, $t3, update_location # Ball next position WILL be this pixel
	# Bouncing off centre pixel in paddle
	li $s4, -128 # Set new ball direction IF this is the correct paddle pixel
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $s5, $t3, update_location # Ball next position WILL be this pixel
	# Bouncing off centre-right pixel in paddle
	li $s4, -124 # Set new ball direction IF this is the correct paddle pixel
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $s5, $t3, update_location # Ball next position WILL be this pixel
	# Bouncing off rightmost pixel in paddle
	li $s4, -124 # Set new ball direction since THIS IS the correct paddle pixel
	# No branch since it HAS to be this one if it wasn't one of the others
	j update_location # Ball has bounced, now go move it
	
	
	
break_brick: # This one is actually a function. Be careful.
	# This is invoked before every single "recollide check" to break the brick we leave from.
	# Expected Arguments:
	# $a0 = The pixel that is going to be broken first on this brick. Necessary
	# to avoid odd-looking breaks due to weird targeting.
	lw $t1, 0($a0) # Set $t1 to the colour in the brick that is getting broken.
	# Now, since our bricks are *** 3 *** pixels long, the break can start in the middle,
	# or on either side.
	
	# But first, we are not breaking the paddle or walls.
	beq $t1, 0x808080, stop_break # If the """brick""" is gray, do not break and go home. That is not a brick.
	beq $t1, 0x008000, stop_break # If the """brick""" is green, do not break and go home. That is not a brick.
	
	########## HORRIBLE CODE INCOMING!!!! REGISTER MISUSE INCOMING!!!! ##########
	lw $a1, -4($a0) # Set $a1 to the colour of the pixel to the LEFT of $a0
	lw $a2, 4($a0) # Set $a2 to the colour of the pixel to the RIGHT of $a0
	bne $t1, $a1, break_from_left # Colour of pixel to the left is not the same, so $a0 is the leftmost pixel
	# Pixel to the left of $a0 is the same colour, so same brick.
	# This means that $a0 is either the middle or rightmost pixel on a our standard 1 x 3 brick
	bne $t1, $a2, break_from_right # Colour of pixel to the right is not the same, so $a0 is the rightmost pixel
	# Pixel to the right of $a0 is the same colour, so same brick.
	# This means that $a0 is the middle pixel of our brick. It can now be broken.
	###################**** BRICK BREAKING ANIMATION HERE ****###################
	li $t1, 0x000000 # Set $t1 to black, prepare to paint over brick
	sw $t1, -4($a0) # Paint left
	sw $t1, 0($a0) # Paint middle
	sw $t1, 4($a0) # Paint right
	jr $ra # Leave
break_from_left:
	li $t1, 0x000000 # Set $t1 to black, prepare to paint over brick
	sw $t1, 0($a0) # Paint left
	sw $t1, 4($a0) # Paint middle
	sw $t1, 8($a0) # Paint right
	jr $ra # Leave
break_from_right:
	li $t1, 0x000000 # Set $t1 to black, prepare to paint over brick
	sw $t1, -8($a0) # Paint left
	sw $t1, -4($a0) # Paint middle
	sw $t1, 0($a0) # Paint right
	jr $ra # Leave
	###################**** BRICK BREAKING ANIMATION DONE ****###################
stop_break:
	jr $ra # Leave
	
	
	
error:
	li $v0, 4
	la $a0, ERROR_OUT
	syscall
