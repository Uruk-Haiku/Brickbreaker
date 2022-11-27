################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
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
BLUE:
    .word 0x0000ff
RED:
    .word 0xff0000
GREEN:
    .word 0x00ff00


##############################################################################
# Mutable Data
##############################################################################
PADDLE:
    .word 0x10
BALL:


##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
        lw $s0, ADDR_DSPL
        lw $s1, ADDR_KBRD
        #lw $s2, PADDLE:
        #lw $s3, BALL:
        addi $t0, $t0, 1 #i = 1
        addi $t5, $t5, 300
        addi $t2, $s0, 768 #2048
        addi $t3, $s0, 892 #2300 
        li $t1, 0x808080 #use t1 to store grey.
    
vwall_loop:
	beq $t0, $t5, hwall_loop_setup
    	#lw $t4, 256($t2)
    	#lw $t6, 256($t3)
    	#lw $t2, 0($t4) #use t2 to store position of first wall
    	#lw $t3, 0($t6) #use t3 to store position of second wall
    	# addi $t3, $t3, 252 #move t3 to other side of screen.
    	sw $t1, 0($t2) #store grey in t2
    	sw $t1, 0($t3) #store grey in t3
    	addi $t2, $t2, 128
    	addi $t3 $t3, 128
    	addi $t0, $t0, 1 #i + 1
    	j vwall_loop 
hwall_loop_setup:
	addi $t2, $s0, 768 #set up horizontal line. t2 keeps track of pixels.
	li $t0, 0 #reset t0 to be counter for hwall_loop
	li $t5, 32 #limit for hwall_loop
	
hwall_loop:
 	beq $t0, $t5, paddle_loop_setup
 	sw $t1, 0($t2) #make pixel grey
 	addi $t2, $t2, 4 #update pixel position
 	addi $t0, $t0, 1
 	j hwall_loop 	

paddle_loop_setup:
	addi $t2, $s0, 4024 #next to midpoint of last line
	li $s2, 0x10008fb8
	li $t0, 0 #setup loop variable i
	li $t5, 4 #loop limit.
	li $t1, 0x008000 #color green.
draw_paddle:
	beq $t0, $t5, brick_setup1
 	sw $t1, 0($t2) #make pixel gren
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
 	addi $t2, $s0, 900
 	li $t0, 0
 	li $t5, 7
 	j draw_brick
 
orange_brick_setup:
	li $t1, 0xffa5000
 	li $t7, 0x000000
 	addi $t2, $s0, 1028
 	li $t0, 0
 	li $t5, 7
 	j draw_brick
 
yellow_brick_setup:
	li $t1, 0xffff000
 	li $t7, 0x000000
 	addi $t2, $s0, 1156
 	li $t0, 0
 	li $t5, 7
 	j draw_brick	
 		
draw_brick:
	beq $t0, $t5, brick_setup
	sw $t7, 0($t2)
	sw $t1, 4($t2)
	sw $t1, 8($t2)
	sw $t1, 12($t2)
	addi $t0, $t0, 1
	addi $t2, $t2, 16
 	j draw_brick
	 
 
ball_setup:
	li $t1, 0xffffff
	sw $t1, 3900($s0)
game_loop:
	lw $t7, 0($s1)
	beq $t7, 1, keyboard_input
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

keyboard_input:
	lw $t7, 4($s1)
	beq $t7, 0x61, respond_to_a
	beq $t7, 0x64, respond_to_d
	j game_loop
	
respond_to_a:
	beq $s2, 0x10008f84, game_loop
	li $t1, 0x000000
	sw $t1, 16($s2)
	addi $s2, $s2, -4
	li $t1, 0x008000
	sw $t1, 0($s2)
	j game_loop
	
respond_to_d:
	beq $s2, 0x10008fe8, game_loop
	li $t1, 0x000000 
	sw $t1, 0($s2)
	addi $s2, $s2, 4
	li $t1, 0x008000
	sw $t1, 16($s2)
	j game_loop
	
