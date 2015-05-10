#define SFS_BK_SIZE 512
#define SFS_NUM_BKS 340
#define SFS_NUM_FREE_BKS 9
#define SFS_NUM_FREE_EYS 576 // 512 * 9 / 8 = 576
#define SFS_NUM_INODE_BKS 54
#define SFS_NUM_INODE_EYS 384 // 512 * 63 / 72 = 384
#define SFS_FILE_NAME_LEN 17
#define SFS_FILE_EXT_LEN 4
#define SFS_NUM_DIR_PTRS 12
#define MAX_OPEN 100

#include "disk_emu.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* For this definition, one sfs_super_block is 24 bytes (4 bytes * 4 fields + 8
 * bytes for one long int) */
typedef struct sfs_super {
  long magic;
  int block_size;
  int file_system_size;
  int free_desc_table_length;
  int inode_table_length;
  int root_dir_inode_num;
} sfs_super;

/* For this definition, one sfs_inode is 72 bytes (4 bytes * 18 fields) */
typedef struct sfs_inode {
  int mode;
  int link_cnt;
  int uid;
  int gid;
  int size;
  int block[SFS_NUM_DIR_PTRS];
  int ind;
} sfs_inode;

/* For this definition, one sfs_file_desc is 28 bytes (4 bytes for the int and 
 * 1byte per char rounded up to the nearest multiple of 4 bytes */
typedef struct sfs_file {
  int node;
  char name[SFS_FILE_NAME_LEN];
  char ext[SFS_FILE_EXT_LEN];
} sfs_file;

/* For this definition, one sfs_open_file_desc is 8 bytes (4b * 2 fields) */
typedef struct sfs_open {
  int node;
  int ptr;
} sfs_open;

/* For this definition, one sfs_free_block_desc is 8 bytes (4b * 2 fields) */
typedef struct sfs_free {
  int begin;
  int num_free;
} sfs_free;

sfs_inode *inode_table;
sfs_free *free_table;
sfs_open *open_table;
sfs_file *root_dir;

int BK_SIZE;
int NUM_BKS;
int NUM_FREE_BKS;
int NUM_FREE_EYS;
int NUM_INODE_BKS;
int NUM_INODE_EYS;
int NUM_IND_BK_EYS;
int NUM_DIR_BK_EYS;
int ROOT_INODE;
int MAX_FILE_SIZE;

int inode_unpack_file_index(int node, int * index);
int inode_repack_file_index(int node, int * index, int count);

int getBlockNumber(int offset) { return offset / BK_SIZE; }

int getBlockOffset(int offset) { return offset % BK_SIZE; }

void writeInodeTable() {
  write_blocks(NUM_FREE_BKS + 1, NUM_INODE_BKS, inode_table);
}

void writeFreeTable() {
  write_blocks(1, NUM_FREE_BKS, free_table);
}

void write_dir_bk() {
	int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
	int file_index_count = inode_unpack_file_index(ROOT_INODE, file_index);
	int i;
	for (i = 0; i < file_index_count; i++) {
		write_blocks(file_index[i], 1, ((char*)root_dir)+i*BK_SIZE);
	}
	free(file_index);
}

void free_table_reconcile() {
	int i, j;
	sfs_free swap;
	for (i = 0 ; i < NUM_FREE_EYS - 1 ; i++) {
		for (j = 0 ; j < NUM_FREE_EYS - i - 1; j++) {
		  if (free_table[j].begin > free_table[j+1].begin) {
		    swap = free_table[j];
		    free_table[j] = free_table[j+1];
		    free_table[j+1] = swap;
		  }
		}
	}
	for (i = 0; i < NUM_FREE_EYS; i++) {
		if (free_table[i].begin < 0) {
			continue;
		} else {
			for (j = i + 1; j < NUM_FREE_EYS; j++) {
				if (free_table[j].begin <= free_table[i].begin+free_table[i].num_free) {
					free_table[i].num_free=free_table[j].begin+free_table[j].num_free-free_table[i].begin;
					free_table[j].begin = -1;
				} else {
					break;
				}
			}
		}
	}
}

int allocateBlocks(int len) {
  int i, found_ptr = -1;
  for (i = 0; i < NUM_FREE_EYS ; i++) {
    if (free_table[i].begin != -1 && len <= free_table[i].num_free) {
      found_ptr = free_table[i].begin;
      if (free_table[i].num_free == len) {
        free_table[i].begin = -1;
        free_table[i].num_free = 0;
      } else {
        free_table[i].begin += len;
        free_table[i].num_free -= len;
      }
      break;
    }
  }
  writeFreeTable();
  return found_ptr;
}

int free_blocks(int begin, int len) {
	int i;  
	for (i = 0; i < NUM_FREE_EYS ; i++) {
    if (free_table[i].begin != -1) {
			free_table[i].begin = begin;
			free_table[i].num_free = len;
			free_table_reconcile();
      break;
    }
	}
	return 0;
}

int addInodeEntry() {
	int i = 0, j;

	for (i = 0; i < NUM_INODE_EYS && inode_table[i].mode != -1; i++);
	if (inode_table[i].mode < 0) {
		inode_table[i].mode = 0;
	} else {
		return -1;
	}
	for (j = 0; j < SFS_NUM_DIR_PTRS; j++) {
		inode_table[i].block[j] = -1;
	}
	inode_table[i].size = 0;
	inode_table[i].ind = -1;
	writeInodeTable();
	return i;
}
/* ADD A NEW ENTRY TO THE ROOT DIRECTORY */
int dir_add_entry(char *name, char *ext, int node) {
  int i = 0, j = 0;

  while (i < NUM_DIR_BK_EYS - 1 && root_dir[i].node != -1) {
		i++;
	}
	if (root_dir[i].node != -1) { // we have run out of directory entries
		int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
		int file_index_count = inode_unpack_file_index(ROOT_INODE, file_index);
		if (file_index_count >= SFS_NUM_DIR_PTRS + NUM_IND_BK_EYS) {
			free(file_index);
			return -1;
		}
		int new_block_begin = allocateBlocks(1);
		file_index[file_index_count] = new_block_begin;
		file_index_count++;
		root_dir = realloc(root_dir, (file_index_count * BK_SIZE));
		NUM_DIR_BK_EYS = ( file_index_count  * BK_SIZE ) / sizeof(sfs_file);
		inode_table[ROOT_INODE].size += BK_SIZE;
		inode_repack_file_index(ROOT_INODE, file_index, file_index_count);
		writeInodeTable();
		free(file_index);
		i++;
		for (j = i; j < NUM_DIR_BK_EYS; j++) {
			root_dir[j].node = -1;
		}
	}
  root_dir[i].node = node;
  strncpy(root_dir[i].name, name, SFS_FILE_NAME_LEN);
  strncpy(root_dir[i].ext, ext, SFS_FILE_EXT_LEN);
	write_dir_bk();
	return 0;
}

/* CREATE NEW FILE */
int createNewFile(char *name) {
	if (strlen(name) < 1) {
		return -1;
	}
	int inode = addInodeEntry();
	char *tmp = strdup(name);
	char *file_name = strtok(tmp, ".");
	char *file_ext;
	//file_ext[0] = '\0';
	file_ext = strtok(NULL, ".");
	if (file_ext == (char*)0) {
		if (dir_add_entry(file_name, "", inode) < 0) {
			free(file_ext);
			return -1;
		}
	} else {
		if (dir_add_entry(file_name, file_ext, inode) < 0) {
			free(file_ext);
			return -1;
		}
	}
	//free(file_ext);
  return inode;
}

/* ADD OPEN FILES ENTRY 
 * returns : FILE ID */
int addOpenEntry(int node) {
  int i;

  for (i = 0; i < MAX_OPEN; i++) {
    if (open_table[i].node == -1) {
      open_table[i].node = node;
      open_table[i].ptr = inode_table[node].size;
      return i;
    }
  }
  return -1;
}

void createInodeTable(sfs_inode *node_ptr) {
	int i;
	for (i = 0; i < NUM_INODE_EYS; i++) {
		node_ptr[i].mode = -1;
	}
}

void createDirectory(sfs_file *dir_ptr, int node) {
	int i;
	for (i = 0; i < NUM_DIR_BK_EYS; i++) {
	  dir_ptr[i].node = -1;
	}
	inode_table[node].mode = 0;
	inode_table[node].size = BK_SIZE;
}

int inode_find_for_name(char *name) {
	char *tmp = strdup(name);
	char *file_name = strtok(tmp, ".");
	if (file_name == NULL) {
		file_name = "";
	}
	char *file_ext = strtok(NULL, ".");
	if (file_ext == NULL) {
		file_ext = "";
	}

	int i = 0;
	for (i = 0; i < NUM_DIR_BK_EYS; i++) {
		if (root_dir[i].node != -1 && strcmp(root_dir[i].name, file_name) == 0 && strcmp(root_dir[i].ext, file_ext) == 0) {
			return root_dir[i].node;
		}
	}
	return -1;
}

int inode_unpack_file_index(int node, int *index) {
	int i;  
	int size = inode_table[node].size;
	for (i = 0; i < SFS_NUM_DIR_PTRS + NUM_IND_BK_EYS; i++) {
		index[i] = -1;
	}
  if (size <= BK_SIZE) {
    index[0] = inode_table[node].block[0];
    return 1;
  } else {
    int block_count = size / BK_SIZE;
    if (size % BK_SIZE != 0) block_count += 1;
    for (i = 0; i < SFS_NUM_DIR_PTRS && i < block_count; i++) {
      index[i] = inode_table[node].block[i];
    }
    if (block_count > SFS_NUM_DIR_PTRS) {
      int * tmp = malloc(BK_SIZE);
      read_blocks(inode_table[node].ind, 1, tmp);
      for (i = SFS_NUM_DIR_PTRS; i < block_count; i++) {
        index[i] = tmp[i-SFS_NUM_DIR_PTRS];
      }
			free(tmp);
    }
    return block_count;
  }
}

int inode_repack_file_index(int node, int * index, int count) {
	if (count > SFS_NUM_DIR_PTRS + NUM_IND_BK_EYS) {
		return -1;
	} else {
		int i;
		for (i = 0; i < SFS_NUM_DIR_PTRS && i < count; i++) {
		  inode_table[node].block[i] = index[i];
		}
		if (count > SFS_NUM_DIR_PTRS) {
			if (inode_table[node].ind < 0) {
				inode_table[node].ind = allocateBlocks(1);
				writeInodeTable();
			}
			int * tmp = malloc(BK_SIZE);
		  for (i = 0; i < count - SFS_NUM_DIR_PTRS; i++) {
		    tmp[i] = index[i+SFS_NUM_DIR_PTRS];
		  }
			for (; i < NUM_IND_BK_EYS; i++) {
				tmp[i] = -1;
			}
		  write_blocks(inode_table[node].ind, 1, tmp);
			free(tmp);
		}
		return count;
	}
}
