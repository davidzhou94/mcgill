#include "malloc_api.h"

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	// TEST CASE: Try allocating, freeing, and allocating again.
	printf("MEMORY ALLOCATION TEST:       ");

	void *ptrs[256];
	int i;
	for (i = 0; i < 64; i++) { // my_malloc 64 x 1024 bytes
		ptrs[i] = my_malloc(1024);
	}
	for(i = 28; i < 32; i++) { // my_free 24 - 32
		my_free(ptrs[i]);
	}

	// my_malloc (32-24) x 1024 bytes, this should go in the
	// blocks we just my_free'd
	void *new_ptr = my_malloc( (32-28) * 1024);
	
	if (new_ptr == ptrs[28]) {
		printf(" SUCCEEDED\n");
	}	else {
		printf(" FAILED\n");
	}

	// TEST CASE: Try expanding and shrinking the program break.
	printf("PROGRAM BREAK EXPANSION TEST: ");

	void *init_break, *cur_break, *final_break;
	int failed = 0;

	init_break = sbrk(0);
	for (i = 64; i < 256; i++) {
		ptrs[i] = my_malloc(1024);
	}
	cur_break = sbrk(0);
	failed += (cur_break > init_break) ? 0 : 1;
	if (failed)
		printf("\n\tPROGRAM BREAK DID NOT EXPAND... ");
	failed += (((cur_break - init_break) % (128 * 1024)) == 0) ? 0 : 1;
	if (failed) 
		printf("\n\tEXPANSION WAS NOT IN MULTIPLE OF 128KB... ");
	for (i = 64; i < 128; i++) {
		my_free(ptrs[i]);
	}
	for (i = 255; i >= 128; i--) {
		my_free(ptrs[i]);
	}
	final_break = sbrk(0);

	failed += (init_break == final_break) ? 0 : 1;
	if (failed)
		printf("\n\tPROGRAM BREAK WAS NOT REDUCED... ");

	if (!failed) {
		printf(" SUCCEEDED\n");
	}	else {
		printf(" FAILED\n");
	}

	// TEST CASE: switch to best fit and verify the policy
	// is correctly implemented
	printf("BEST FIT POLICY TEST:         ");
	my_mallopt(POLICY_BEST_FIT);
	for (i = 64; i < 256; i++) {
		ptrs[i] = my_malloc(1024);
	}
	my_free(ptrs[128]);
	my_free(ptrs[129]);
	my_free(ptrs[130]);
	my_free(ptrs[131]);
	// skip 132, previous chunk is ~ 4 * 1024 bytes
	my_free(ptrs[133]);
	my_free(ptrs[134]);
	my_free(ptrs[135]);
	// skip 136, previous chunk is ~ 3 * 1024 bytes
	my_free(ptrs[137]);
	my_free(ptrs[138]);
	// skip 139, previous chunk is ~ 2 * 1024 bytes
	my_free(ptrs[140]);
	// the chunk where 140 was is about 1024 bytes

	void *new_ptr2 = my_malloc(2 * 1024);
	if (new_ptr2 == ptrs[137]) {
		printf(" SUCCEEDED\n");
	} else {
		printf(" FAILED\n");
	}

	// TEST CASE: switch to first fit and verify the policy
	// is correctly implemented
	printf("FIRST FIT POLICY TEST:        ");
	my_mallopt(POLICY_FIRST_FIT);

	// re-use allocation configuration from previous test
	my_free(new_ptr2);

	void *new_ptr3 = my_malloc(2 * 1024);

	if (new_ptr3 == ptrs[128]) {
		printf(" SUCCEEDED\n");
	} else {
		printf(" FAILED\n");
	}

	printf("PRINT STATISTICS: \n");
	my_mallinfo();

	return 0;
}
