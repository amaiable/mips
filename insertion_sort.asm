# in insertion_sort:
# $sp is here
# key is at       -16($fp)
# j is at         -12($fp)
# i is at         -8($fp)
# length is at    -4($fp)
# saved $fp ($fp is also currently here)
# saved $ra
# the_list  is at +8($fp)

# in main:
# $sp is here
# i         is at -8($fp) (note that i doesn't get its value stored until after function call, but the allocation happens at the start)
# arr       is at -4($fp)
# $fp is here


.globl  insertion_sort

        .data
space:          .asciiz " "
newline:        .asciiz "\n"

        .text
main:
        # copy $sp to $fp
        addi $fp, $sp, 0

        # allocate space for local vars (pointer to arr size and i)
        addi $sp, $sp, -8

        # initialise arr = [6, -2, 7, 4, -10]
        # make space for 6 (size + 5 elements) * 4 bytes
        addi $v0, $0, 9
        addi $a0, $0, 6  # size + 5 = $t1
        sll $a0, $a0, 2  # multiply by 4 (shift left 2 bytes)
        syscall  # 24 bytes allocated

        # store list head in first local var position
        sw $v0, -4($fp)

        # store values of array
        # head (size) is 5
        addi $t0, $0, 5
        sw $t0, ($v0)
        # first element is 6
        addi $t0, $0, 6
        sw $t0, 4($v0)
        # second element is -2
        addi $t0, $0, -2
        sw $t0, 8($v0)
        # third element is 7
        addi $t0, $0, 7
        sw $t0, 12($v0)
        # fourth element is 4
        addi $t0, $0, 4
        sw $t0, 16($v0)
        # fifth element is -10
        addi $t0, $0, -10
        sw $t0, 20($v0)

        # passes arr ptr in as an argument
        addi $sp, $sp, -4
        lw $t0, -4($fp)
        sw $t0, ($sp)

        jal insertion_sort

        # clear arguments off stack
        addi $sp, $sp, 4

        # printing element with spaces in between sequence
        # initialise local variable i = 0
        sw $0, -8($fp)

        # loop over list
print_loop:
        lw $t0, -8($fp)
        lw $t1, -4($fp)  # we want to get the size of the array, so we need to grab what's at the head of the array
        lw $t1, ($t1)  # dereference the pointer to size of array
        slt $t0, $t0, $t1
        beq $t0, $0, end_print_loop  # leave loop if we've iterated over entire list

        # print element
        lw $t0, -8($fp)  # load i
        addi $t0, $t0, 1  # i + 1
        sll $t0, $t0, 2  # 4(i + 1)
        lw $t1, -4($fp)  # array ptr in $t1
        add $t0, $t1, $t0  # add array ptr to 4(i + 1)
        addi $v0, $0, 1  # print number
        lw $a0, ($t0)  # argument is at array ptr + 4(i + 1)
        syscall

        # print space
        addi $v0, $0, 4
        la $a0, space
        syscall

        # increment i
        lw $t0, -8($fp)
        addi $t0, $t0, 1
        sw $t0, -8($fp)

        j print_loop

end_print_loop:

        # print trailing newline
        addi $v0, $0, 4
        la $a0, newline
        syscall

        # exit
        addi $v0, $0, 10
        syscall


insertion_sort:
        # arguments: the_list
        # local variables: length, i, j, key
        # save value of $ra on stack
        addi $sp, $sp, -4
        sw $ra, ($sp)

        # save value of $fp on stack
        addi $sp, $sp, -4
        sw $fp, ($sp)

        # copy $sp to $fp
        addi $fp, $sp, 0

        # allocate space for local variables (length, i, j, key)
        addi $sp, $sp, -16

        # initialise local variable length
        lw $t0, 8($fp)  # grabs pointer to size of the_list
        lw $t0, ($t0)  # dereference the pointer
        sw $t0, -4($fp)  # stores size of list into length local variable

        # for loop
        # initialise i = 1
        addi $t0, $0, 1
        sw $t0, -8($fp)
iteration_loop:
        # should iterate from 1 to length
        lw $t0, -8($fp)  # getting value of i
        lw $t1, -4($fp)  # getting value of length
        slt $t0, $t0, $t1
        beq $t0, $0, end_iteration_loop  # break if we've iterated over the list n - 1 times (n is length of list)

        # key = the_list[i]
        lw $t0, -8($fp)  # $t0 contains i
        addi $t0, $t0, 1  # skip size element
        sll $t0, $t0, 2
        lw $t1, 8($fp)  # array ptr in $t1
        add $t0, $t1, $t0  # add array ptr to 4(i + 1)
        lw $t2, ($t0)  # $t2 stores the value of the element
        sw $t2, -16($fp)

        # j = i - 1
        addi $t0, $0, 1
        lw $t1, -8($fp)  # getting value of i
        sub $t2, $t1, $t0
        sw $t2, -12($fp)  # store in stack location for j

swap_loop:
        # while loop conditions
        # while j >= 0 and key < the_list[j]
        lw $t0, -12($fp)
        slt $t0, $t0, $0  # $t0 is 1 if j < 0, is 0 if j >= 0
        bne $t0, $0, end_swap_loop
        lw $t3, -16($fp)  # load key
        # we need to load the_list[j]
        lw $t0, -12($fp)  # $t0 contains j
        addi $t0, $t0, 1  # skip size element (j + 1)
        sll $t0, $t0, 2  # $t0 = 4(j + 1)
        lw $t1, 8($fp)  # the_list head ptr in $t1
        add $t0, $t1, $t0  # add the_list head ptr to 4(j + 1)
        lw $t2, ($t0)  # $t2 stores the value of the element
        slt $t1, $t3, $t2  # if key < the_list, $t1 will be 1
        beq $t1, $0, end_swap_loop  # if $t1 is 0, we want to get out, otherwise, we can stay in the loop

        # the_list[j + 1] = the_list[j]
        # find the_list[j]
        lw $t0, -12($fp)  # $t0 contains j
        addi $t0, $t0, 1  # skip size element
        sll $t0, $t0, 2
        lw $t1, 8($fp)  # the_list ptr in $t1
        add $t0, $t1, $t0  # add the_list ptr to 4(j + 1)
        lw $t2, ($t0)  # $t2 stores the value of the element

        # set the_list[j + 1] to $t2
        lw $t0, -12($fp)  # $t0 contains j
        addi $t0, $t0, 1  # skip size element
        addi $t0, $t0, 1  # j + 1
        sll $t0, $t0, 2
        lw $t1, 8($fp)  # array ptr in $t1
        add $t0, $t1, $t0  # add array ptr to 4(j + 1 + 1)
        sw $t2, ($t0)  # set location of $t0 to what we had at the_list[j]

        # decrement j
        lw $t0, -12($fp)
        addi $t1, $0, 1
        sub $t0, $t0, $t1
        sw $t0, -12($fp)

        j swap_loop

end_swap_loop:
        # the_list[j + 1] = key
        lw $t0, -12($fp)  # $t0 contains j
        addi $t0, $t0, 1  # skip size element
        addi $t0, $t0, 1  # j + 1
        sll $t0, $t0, 2
        lw $t1, 8($fp)  # array ptr in $t1
        add $t0, $t1, $t0  # add array ptr to 4(j + 1 + 1)
        lw $t2, -16($fp)
        sw $t2, ($t0)

        # increment i
        lw $t0, -8($fp)
        addi $t0, $t0, 1
        sw $t0, -8($fp)

        j iteration_loop

end_iteration_loop:
        # clear local variables off stack
        addi $sp, $sp, 16

        # restore saved $fp
        lw $fp, ($sp)
        addi $sp, $sp, 4

        # restore saved $ra
        lw $ra, ($sp)
        addi $sp, $sp, 4

        # jump back
        jr $ra
