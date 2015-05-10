#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "malloc_api.h"

#define SBRK_INCREMENT 131072 // 128kb * 1024 b/kb

typedef int bool;
enum { false, true };

typedef struct tag {
	unsigned long length;
	bool free;
	struct tag *prev;
	struct tag *next;
} tag;

char *my_malloc_error;
bool initialized = false;
int alloc_policy = POLICY_FIRST_FIT;
void *root_ptr;
int sbrk_inc = 0;
int syscall_count = 0;

void *my_malloc(int size) {
	if (!initialized) {
		root_ptr = sbrk(SBRK_INCREMENT);
		syscall_count++;
		if ((long) &root_ptr != -1) {
			sbrk_inc++;
			tag *root_block = (tag *) root_ptr;
			root_block->length = SBRK_INCREMENT - sizeof(tag);
			root_block->free = true;
			root_block->prev = NULL;
			root_block->next = NULL;
			initialized = true;
		} else {
			my_malloc_error = "Could not allocate additional memory";
			return NULL;
		}
	}

	tag *cur_block = (tag *) root_ptr;
	bool alloc_found = false;

	// Find a free block using the correct policy
	if (alloc_policy == POLICY_FIRST_FIT) {
		// First fit
		while (true) {
			if (cur_block->free == true && cur_block->length >= size) {
				alloc_found = true;
				break;
			} else if (cur_block->next != NULL) {
				cur_block = cur_block->next;
			} else {
				alloc_found = false;
				break;
			}
		}
	} else if (alloc_policy == POLICY_BEST_FIT) {
		// Best fit
		tag *best_block = NULL;
		unsigned long best_length = LONG_MAX;
		while (true) {
			if (cur_block->free == true && cur_block->length >= size) {
				if (best_length > cur_block->length) { 
					// >= will bias later blocks for ties
					best_block = cur_block;
					best_length = cur_block->length;
				}
				alloc_found = true;
			}
			if (cur_block->next == NULL) {
				if (alloc_found) {
					cur_block = best_block;
				}
				break;
			} else {
				cur_block = cur_block->next;
			}
		}
	} else {
		my_malloc_error = "The specified allocation policy does not exist";
		return NULL;
	}

	// Extend program break if necessary
	if (alloc_found == false) {
		int inc_amt = (size / SBRK_INCREMENT) + 1;
		void *new_segment = sbrk(SBRK_INCREMENT * inc_amt);
		syscall_count++;
		if ((long) &new_segment != -1) {
			sbrk_inc += inc_amt;
			if (cur_block-> free == false) {
				tag *new_block = (tag *) new_segment;
				new_block->length = SBRK_INCREMENT - sizeof(tag);
				new_block->free = true;
				new_block->next = NULL;
				new_block->prev = cur_block;
				cur_block->next = new_block;
				cur_block = new_block;
			} else {
				cur_block->length += SBRK_INCREMENT * inc_amt;
			}
		} else {
			my_malloc_error = "Could not allocate additional memory";
			return NULL;
		}
	}

	// Split cur_block if necessary
	if (cur_block->length - size > sizeof(tag)) {
		void *cur_ptr = (void *) cur_block;
		cur_ptr += sizeof(tag) + size;
		tag *new_block = (tag *) cur_ptr;
		tag *next_block = cur_block->next;
		new_block->length = cur_block->length - size - sizeof(tag);
		new_block->free = true;
		new_block->prev = cur_block;
		new_block->next = next_block;
		cur_block->length = size;
		cur_block->next = new_block;
		if (new_block->next != NULL) {
			new_block->next->prev = new_block;
		}
	}

	// Prepare block and return address
	cur_block->free = false;
	void *ret = (void *) cur_block;
	ret += sizeof(tag);
	return ret;
}

void my_free(void *ptr) {
	// Check for improper uses of free
	if (ptr == NULL) {
		my_malloc_error = "Cannot free a null pointer";
		printf("Cannot free a null pointer\n");
		return;
	} else if (ptr < root_ptr + sizeof(tag)) {
		my_malloc_error = "Invalid address";
		printf("Invalid address\n");
		return;
	} else if (ptr > root_ptr + (sbrk_inc * SBRK_INCREMENT) - sizeof(tag) - 1) {
		my_malloc_error = "Invalid address";
		printf("Invalid address\n");
		return;
	}

	void *cur_ptr = ptr - sizeof(tag);
	tag *cur_block = (tag *) cur_ptr;

	if (cur_block->length > sbrk_inc * SBRK_INCREMENT - sizeof(tag)
		|| (cur_block->free != true && cur_block->free != false)) {
		my_malloc_error = "Address was not allocated";
		printf("Address was not allocated\n");
		return;
	}

	tag *mid_block = cur_block;
	tag *prev_block = mid_block->prev;
	tag *next_block = mid_block->next;

	// Update adjacent blocks if they are free
	if (prev_block != NULL && prev_block->free == true) {
		cur_block = prev_block;
		cur_block->length += mid_block->length + sizeof(tag);
		cur_block->next = next_block;
		if (next_block != NULL) {
			next_block->prev = cur_block;
		}
	}
	if (next_block != NULL && next_block->free == true) {
		cur_block->length += next_block->length + sizeof(tag);
		cur_block->next = next_block->next;
		if (next_block->next != NULL) {
			next_block->next->prev = cur_block;
		}
	}

	cur_block->free = true;
	//mid_block->length = 0xFFFFFFFFL;

	// Trim the program break if necessary
	if (cur_block->next == NULL && cur_block->length > SBRK_INCREMENT) {
		int dec_amt = cur_block->length;
		cur_block->length = cur_block->length % SBRK_INCREMENT;
		dec_amt -= cur_block->length;
		//sbrk(-1 * SBRK_INCREMENT);
		void *end_ptr = (void *) cur_block;
		end_ptr += sizeof(tag) + cur_block->length;
		brk(end_ptr);
		syscall_count++;
		sbrk_inc -= dec_amt / SBRK_INCREMENT;
	}
}

void my_mallopt(int policy) {
	if (policy != POLICY_FIRST_FIT && policy != POLICY_BEST_FIT) {
		return;
	} else {
		alloc_policy = policy;
	}
}

void my_mallinfo() {
  unsigned long blocks_allocated = 0;
	unsigned long bytes_allocated = 0;
	unsigned long blocks_free = 0;
	unsigned long bytes_free = 0;
	unsigned long largest_allocated = 0;
	unsigned long largest_free = 0;

	tag *cur_block = (tag *) root_ptr;
	while (cur_block != NULL) {
		if (cur_block->free) {
			blocks_free++;
			bytes_free+=cur_block->length;
			if (cur_block->length > largest_free)
				largest_free = cur_block->length;
		} else {
			blocks_allocated++;
			bytes_allocated+=cur_block->length;
			if (cur_block->length > largest_allocated)
				largest_allocated = cur_block->length;
		}
		cur_block = cur_block->next;
	}

	printf("\n****** Malloc statistics ******\n");
	printf("\t| Allocated \t Free \n------------------------------\n");
	printf("Blocks  | %-6lu \t %-6lu\n", blocks_allocated, blocks_free);
	printf("Bytes   | %-6lu \t %-6lu\n", bytes_allocated, bytes_free);
	printf("Largest | %-6lu \t %-6lu\n\n", largest_allocated, largest_free);
	printf("Total blocks :          %-6lu\n", blocks_allocated + blocks_free);
	printf("Total syscalls so far : %-6d\n", syscall_count);
}
