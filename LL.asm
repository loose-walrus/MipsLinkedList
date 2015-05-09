######################################################################################################################################

# Luke A. Weber
 
# This program creates a linkedlist of strings that a user can manipulate in several ways.
# A reoccuring menu states the "current node" that user is on as well as a list of options for the user to select:
#"1", terminates the program
#"2", allows the user to input a string of max 16 characters. The inserted string will come after whatever the "current node" is.
	#if the linkedlist is empty, then the inserted string will be at the beginning. The current node is updated as the new string.
#"3", redefines the current node as the next node in the list, if one exists.
#"4", redefines the current node as the previous node in the list, if one exists.
#"5", deletes the current node (if one exists). Redefines the current node as the previous node in the list, unless the node being deleted
	#is the first node in the list, in which is case current will be defined as the next node in the list.
#"6", resets the current node as the first node in the list (if one exists).
#"7", traverses the entire linkedlist outputing all strings to the console. Maintains the value of the current node.

#####################################################################################################################################

.data

 	curr:		.asciiz	"\nCurrent Node: "
 	options:	.asciiz	"\nMenu:\n 1 - quit\n 2 - insert\n 3 - next\n 4 - previous\n 5 - delete\n 6 - reset\n 7 - printall\n"
 	insertprompt:	.asciiz	"\nPlease enter a string that is less than 16 characters\n"
 	quitprompt: 	.asciiz "\nGoodbye!\n"
 	empty: 		.asciiz	"THE LIST IS EMPTY"
 	inv:		.asciiz	"\nInvalid input, try again\n"
 	toolong:	.asciiz "\nThat string is too long, try again\n"
 	end:		.asciiz	"\nCan not get next, you are at the end of the list\n"
 	beg:		.asciiz	"\nCan not get previous, you are at the beginning of the list\n"

.text

current:				#####################printing the value of the current node##########################

	li	$v0, 4			#printing the current node prompt.
	la	$a0, curr
	syscall

	beqz	$s1, emptylist  	#if value of current node is null, then the list is empty. Jump to emptylist function.

	li	$v0, 4			#print the string in currentNode
	lw	$a0, ($s1)
	syscall

menu: 					##################menu that the user continues continously sees#######################

 	li	$v0, 4			#menu prompt
 	la	$a0, options
 	syscall

 	li	$v0, 5			#read chosen option from user
 	syscall

 	beq	$v0, 1, quit		#if user input is "1" jump to quit label
 	beq	$v0, 2, insert		#if user input is "2" jump to insert label
 	beq 	$v0, 3, nextNode	#if user input is "3" jump to nextNode label
 	beq 	$v0, 4, previousNode	#if user input is "4" jump to previosNode label
 	beq	$v0, 5, delete		#if user input is "5" jump to delete label
 	beq	$v0, 6, reset		#if user input is "6" jump to reset label
 	beq	$v0, 7, traverse	#if user input is "7" jump to traverse label
 	bgt	$v0, 7, invalid		#if user input is invalid
 	blt	$v0, 1, invalid		#if user input is invalid

quit: 					######################ending the program####################

 	li	$v0, 4			#printing goodbye to user
 	la 	$a0, quitprompt
 	syscall


 	li 	$v0, 10			#quit the program
	syscall

insert:					#######################inserting new node####################

	li	$v0, 9			#making a new node that is 8 bytes.
	la	$a0, 8			#$v0 <--- address of memory for new node
	syscall

	move 	$t1, $v0 		#set $t1 to the address of the new node

	li	$v0, 4			#print insert prompt
	la	$a0, insertprompt
	syscall

	li	$v0, 9			#grabbing 17 bytes for user's string
	la	$a0, 17			#v0 <-- address of memory
	syscall

	move 	$a0, $v0		#pass users string memory address to $a0 argument
	li	$v0, 8			#read user's string
	li	$a1, 16
	syscall				#$a0 <-- user's string

	sw	$a0, ($t1)		#pass user's string to address of new node at $t1


	beq	$s1, 0, emptys		#if the current node ($s1) is empty, then the list is empty. Do a special insert at emtys

	lw	$t3, 4($s1)		#load the value of the current's next in $t3
	sw	$t1, 4($s1)		#making the current node point to the new node
	sw	$t3, 4($t1)		#make new node point to current's next.

	move	$s1, $t1		#update the current node to be the new node

	j 	current 		#start menu over


emptys:
	move $s1, $t1			#inserting into an empty list, make the value of $s1 (currentNode) == $t2 which is the value of the new node
	move $s2, $t1			#make the value of $s2 (head) == $t2 which is the value of the new node

	j	current

nextNode: 				######################redefine the currentNode to the node proceeding it################

	beqz	$s1, emptylist		#checking if the current node is null. If it is, then jump to empty list
	lw	$t3, 4($s1)		#load the value of current.next into $t3.
	beq	$t3, 0, endoflist	#also checking if the current node is the last node in the list. If it is, then jump to endoflist

	move	$s1, $t3		#make the current point to current.next at $t3

	j 	current			#start menu over


previousNode: 				################redefine the currentNode as the node preceeding it#####################

	beqz	$s1, emptylist		#checking if the current node is null. If it is, then jump to empty list
	beq	$s1, $s2, begoflist	#also checking if the current node is the first node in the list. If it is, then jump to beginoflist

	jal	findprev		#run findprev method for obtaining the previous node. $v0 <-- prev
	move	$s1, $v0		#update current node to previous node

	j	current 		#start menu over

delete: 				###############deleting the value of the current node. Redefines the currNode as proceeding node##########

	beqz	$s1, emptylist		#checking if the current node is null. If it is, then jump to empty list
	beq	$s1, $s2, specialdelete	#if there is only one node in the list or if current node is at head, then jump to specialdelete

	jal	findprev		#run findprev method for obtaining the node preceeding current. $v0 <-- prev
	lw	$t2, 4($s1)		#$t2 <-- curr.next
	sw	$t2, 4($v0)		#set $v0.next to $t2
	move	$s1, $v0		#update current node to be the previous node

	j	current 		#start the menu over


specialdelete:				##################if there is only one node in the list that user wants to delete#######
					#two cases: either there is only one node in the list or the user is trying to delete the head.
					#$s2 is the head. If head.next is 0 then, there is only one node the list, jump to singledelete
	lw	$t2, 4($s2)		#$t2 <-- head.next
	beqz	$t2, singledelete

					#if head.next isn't null, then the user is trying to delete the head.
	move	$s2, $t2		#make the new head to be oldhead.next.
	sw	$t7, 4($s1)		#break the link between old head and new head
	move	$s1, $s2		#make the current node and head the same

	j	current 		#start menu over

singledelete:

	li	$s1, 0			#setting both head and current node to null. Makes list empty and starts menu over.
	li	$s2, 0

	j 	current
reset:					##############resets the curreNode as the head (the first node in the list)###########

	beqz	$s1, emptylist		#if the value fo the currenot node is null, then it is an empty list. Jump to empty list
	move	$s1, $s2		#set the value of the current node to the value at the head.

	j	current			#start menu over

traverse: 				############prints all the nodes/strings in the list from beginning to end##############

	beqz	$s1, emptylist		#checking if the current node is null. If it is, then jump to empty list
	move	$t1, $s2		#using temp $t1 for traversal. Starting at head which is $s2. Start loop

Tloop:

	beqz	$t1, current		#if $t1 is 0/null then we are at the end of the list so break out of the loop and start menu over
	li	$v0, 4			#printing the string
	lw	$a0, ($t1)
	syscall

	lw	$t1, 4($t1)		#move $t1 to next node and start the loop over
	j 	Tloop


#################special labels###########################################

findprev:				########### finds the node that is preceeding current node. Returns previous in $v0 ###########

	move	$t1, $s2		#use $t1 and $t2 to traverse the list. Start the loop
	move	$t2, $s2

loop:
	lw	$t1, 4($t2)		#make $t1 = $t2.next
	beq	$t1, $s1, foundit	#if t1 is the current node then $t2 is at the previous node, break out of loop
	move	$t2, $t1		#if it's not, keep going through the list
	j	loop

foundit:				####################### helper method for findPrev ##############################################3
	move	$v0, $t2		#pass the previous node to $v0 (return value)
	jr	$ra			#go to the line after findprev method was called


invalid: 				############### telling the user that their input is invalid ###########################
	li	$v0, 4			#the user input a value at the menu that was invalid. Prompting them to try again.
	la	$a0, inv
	syscall

	j	current  		#start menu over

emptylist: 				################# printing to user "the list is empty"###################################
	li	$v0, 4			#telling the user that the list is empty
	la	$a0, empty
	syscall

	j 	menu  			#start menu over

endoflist:				######### telling the user that they are at the end of the list to avoid walking off the end############
	li	$v0, 4
	la	$a0, end
	syscall

	j	current 		#start menu over

begoflist:				######### telling the user that they are at the beginning of list to avoid walking off the beginning ########
	li	$v0, 4
	la	$a0, beg
	syscall

	j 	current			#start menu over
