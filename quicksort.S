.global main
.data
bad_input: .string "bad input"
scan_str: .string "%ld"
long_nl: .string "%ld\n"
new_line: .string "\n"
long_space: .string "%ld "
.text

// xs is in rbx
// ii is in r14
// jj is in r15
// swap(long* xs, long ii, long jj)
// swaps the ii-th elements of xs with the
// jj-th element
swap:
	/* Prologue */
    push %rbx
    push %r14
    push %r15
    enter $8, $0
	/* End of Prologue */

    mov %rdi, %rbx
    mov %rsi, %r14
    mov %rdx, %r15

	//if (ii != jj) 
    cmp %r14, %r15
    jne swap_cond

    jmp swap_end

// xs[ii] is in r9
// xs[jj] is in r10
swap_cond:
	/*
	long tmp = xs[ii];
    xs[ii] = xs[jj];
    xs[jj] = tmp;
	*/
    mov (%rbx, %r14, 8), %r9
    mov (%rbx, %r15, 8), %r10
    mov %r10, (%rbx, %r14, 8)
    mov %r9, (%rbx, %r15, 8)
    jmp swap_end


swap_end:
	/* Epilogue */
    leave
    pop %r15
    pop %r14
    pop %rbx
	/* End of Epilogue */
    ret

// lo is in r14
// hi is in r12
// pivot is in r13
// ii is in rcx
// jj is in r15
// xs is in rbx
// long partition(long* xs, long lo, long hi)
// partition two sides of the array and swaps
// elements on either side
partition:
	/* Prologue */
    push %r12
    push %r13
    push %r14
    push %r15
    push %rbx
    enter $8, $0
	/* End of Prologue */

    mov %rdi, %rbx // xs
    mov %rsi, %r14 // lo
    mov %rdx, %r12 // hi

	//long pivot = xs[hi - 1];
    dec %r12
    mov (%rbx, %r12, 8), %r13

	//long ii = lo;
    //long jj = lo;
    mov %r14, %rcx
    mov %r14, %r15

    jmp partition_loop_cond

// hi-1 is in r12
// jj is in r15
// xs[jj] is in r9
// pivot is in r13
partition_loop_cond:
	//jj < (hi - 1)
    cmp %r12, %r15
    jge partition_loop_end

	//if (xs[jj] < pivot) {
    mov (%rbx, %r15, 8), %r9
    cmp %r13, %r9
    jl partition_if_true

    jmp partition_ok

// xs is in rbx
// ii is in rcx
// jj is in r15
partition_if_true:

	//swap(xs, ii, jj);
    //++ii;
    mov %rbx, %rdi
    mov %rcx, %rsi
    mov %r15, %rdx
    call swap
    inc %rcx
    jmp partition_ok

// xs is in rbx
// ii is in rcx
// h-1 is in r12
partition_loop_end:
	//swap(xs, ii, hi - 1);
    mov %rbx, %rdi
    mov %rcx, %rsi
    mov %r12, %rdx
    call swap
    mov %rcx, %rax

	/* Epilogue */
    leave
    pop %rbx
    pop %r15
    pop %r14
    pop %r13
    pop %r12
	/* End of Epilogue */

    ret

// jj is in r15
partition_ok:
	//++jj
    inc %r15
    jmp partition_loop_cond

// xs is in r12
// lo is in r14
// hi is in r15
// hi - lo is in r13
// void quicksort(long* xs, long lo, long hi)
// sorts the given array
quicksort:
	/* Prologue: */
    push %r12
    push %r13
    push %r14
    push %r15
    enter $0, $0
	/* End of Prologue */

    mov %rdi, %r12
    mov %rsi, %r14
    mov %rdx, %r15

	//(hi - lo < 1)
    mov %r15, %r13
    sub %r14, %r13

    //if (hi - lo < 1) {
    //    return;
    //}

    cmp $1, %r13
    jl quicksort_end

	//long pp = partition(xs, lo, hi);
    mov %r12, %rdi
    mov %r14, %rsi
    mov %r15, %rdx
    call partition
    mov %rax, %r13

	//quicksort(xs, lo, pp);
    mov %r12, %rdi
    mov %r14, %rsi
    mov %r13, %rdx
    call quicksort

	//quicksort(xs, pp + 1, hi);
    inc %r13
    mov %r12, %rdi
    mov %r13, %rsi
    mov %r15, %rdx
    call quicksort

    jmp quicksort_end
    


quicksort_end:
	/* Epilogue */
    leave
    pop %r15
    pop %r14
    pop %r13
    pop %r12
	/* End of Epilogue */
    ret    

// nn is in r13
// xs is in r12
// ii is in r14
// int main(int _argc, char* _argv[])
// allows for a user to specify an array length,
// input numbers, and sort the array.
main:
	/* Prologue: */
    push %r12
    push %r13
    push %r14
    enter $8, $0
	/* End of Prologue */

	//read_int(&nn);
    lea (%r13), %rsi
    call read_int
    mov (%r13), %r13

	//nn * sizeof(long)
    mov %r13, %rax
    mov $8, %r14
    imul %r14

	//malloc(nn * sizeof(long))
    mov %rax, %rdi
    call malloc
    mov %rax, %r12

	//long ii = 0
    mov $0, %r14
    jmp read_loop_cond



main_end:
	/* Epilogue: */
    leave
    pop %r14
    pop %r13
    pop %r12
	/* End of Epilogue */
    ret


// ptr is in rsi
// void read_int(long* ptr)
read_int:
	/* Prologue: */
    enter $0, $0
	/* End of Prologue */

	//scanf("%ld", ptr)
    mov $scan_str, %rdi
    mov $0, %al
    call scanf

	//if (scanf("%ld", ptr) != 1)
    cmp $1, %rax
    jne bad_input_case

	/* Epilogue */
    leave
	/* End of Epilogue */
    ret

// ii is in r14
read_ok:
	//++ii
    inc %r14
    jmp read_loop_cond

// ii is in r14
// nn is in r13
read_loop_cond:
	//ii < nn
    cmp %r13, %r14
    jge read_loop_end

	//read_int(&(xs[ii]));
    lea (%r12, %r14, 8), %rsi
    call read_int

    jmp read_ok

// xs is in r12
// nn is in r13
// ii is in r14
read_loop_end:
	//quicksort(xs, 0, nn);
    mov %r12, %rdi
    mov $0, %rsi
    mov %r13, %rdx
    call quicksort

	//printf("%ld\n", nn);
    mov $long_nl, %rdi
    mov %r13, %rsi
    mov $0, %al
    call printf

	//long ii = 0
    mov $0, %r14
    jmp print_loop_cond

// nn is in r13
// ii is in r14
// xs is in r12
print_loop_cond:
	//ii < nn
    cmp %r13, %r14
    jge print_loop_end

	//printf("%ld ", xs[ii]);
    mov $long_space, %rdi
    mov (%r12, %r14, 8), %rsi
    mov $0, %al
    call printf


    jmp print_ok

// xs is in r12
print_loop_end:
	//printf("\n");
    mov $new_line, %rdi
    mov $0, %al
    call printf

	//free(xs);
    mov %r12, %rdi
    call free
    mov $0, %rax

    jmp main_end

// ii is in r14
print_ok:
	//++ii
    inc %r14
    jmp print_loop_cond


bad_input_case:
	//puts("bad input");
    mov $bad_input, %rdi
    call puts

	//exit(1);
    mov $1, %rdi
    mov $60, %rax
    syscall
    jmp main_end
