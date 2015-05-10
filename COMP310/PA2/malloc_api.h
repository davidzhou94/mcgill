#define POLICY_FIRST_FIT 0
#define POLICY_BEST_FIT 1

void *my_malloc(int size);
extern char *my_malloc_error;
void my_free(void *ptr);
void my_mallopt(int policy);
void my_mallinfo();
