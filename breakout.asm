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
ERROR_OUT: .asciiz "ERROR! SOMETHING BROKE!"



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
#s5: Stores new ball position. Largely only used for detecting collisions.
# These are codified in the 6 values $s4 can take on:
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
#t3: may be used to store location of pixel when coloring.
#t4: Stores the colour of the ball's next location
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
	lw $t7, 0($s1)
	beq $t7, 1, keyboard_input
	# 1a. Check if key has been pressed
    	# 1b. Check which key has been pressed
    	# 2a. Check for collisions
    	j collision_check #run check collisions

	# 2b. Update locations (paddle, ball)
update_location:
	li $t1, 0x000000 #make $t1 black
	sw $t1, 0($s3) #draw black in old spot of ball
	add $s3, $s3, $s4 #increment position with direction
	li $t1, 0xffffff #make $t1 white
	sw $t1, 0($s3) #draw white in new spot of ball
	# 3. Draw the screen
	# 4. Sleep
	li $v0, 32
	li $a0, 20
	syscall

    #5. Go back to 1
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






collision_check:
	beq $s4, -128, collision_check_up # handle collision check if ball is going straight up
	beq $s4, 128, collision_check_down # handle collision check if ball is going straight down
	beq $s4, -132, collision_check_ul # handle collision check if ball is going diagonally up and left
	beq $s4, -124, collision_check_ur # handle collision check if ball is going diagonally up and right
	beq $s4, 124, collision_check_dl # handle collision check if ball is going diagonally down and left
	beq $s4, 132, collision_check_dr # handle collision check if ball is going diagonally down and right
	j error # Never should be reached
	
collision_check_up:
	add $s5, $s3, $s4 # Find the space the ball will be in next, write it to $s5
	lw $t4, 0($s5) # Load the colour of that pixel to $t5
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	li $s4, 128 # Ball bounces, new direction is always straight down.
	j update_location # Ball has bounced, now go move it

collision_check_down:
	add $s5, $s3, $s4 # Find the space the ball will be in next
	lw $t4, 0($s5) # Load the colour of that pixel to $t5
	beq $t4, 0x000000, update_location # Go update location iff nothing is there (colour is black)
	li $s4, -128 # Ball bounces, new direction is always straight up.
	bne $t4, 0x008000 update_location # Go update location if NOT bouncing off paddle's green. Paddle is special.
	j paddle_handler

collision_check_ul:
	

collision_check_ur:


collision_check_dl:


collision_check_dr:


paddle_handler:
	# Bouncing off leftmost pixel in paddle
	li $s4, -132
	add $t3, $s2, 0 # Set $t3 to the left endpoint of paddle
	beq $t4, $t3, update_location # Ball WILL bounce off this pixel, go update location
	# Bouncing off centre-left pixel in paddle
	li $s4, -132
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $t4, $t3, update_location # Ball WILL bounce off this pixel, go update location
	# Bouncing off centre pixel in paddle
	li $s4, -128
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $t4, $t3, update_location # Ball WILL bounce off this pixel, go update location
	# Bouncing off centre-right pixel in paddle
	li $s4, -124
	add $t3, $t3, 4 # Move to next pixel in paddle to the right
	beq $t4, $t3, update_location # Ball WILL bounce off this pixel, go update location
	# Bouncing off rightmost pixel in paddle
	li $s4, -124
	j update_location # Ball has bounced, now go move it
error:
	li $v0, 4
	la $a0, ERROR_OUT
	syscall
