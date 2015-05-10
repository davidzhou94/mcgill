#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sfs_api.h"
#include "sfs_util.h"
#include "disk_emu.h"

int mksfs(int fresh)
{
  int i;

	if (open_table != NULL) {
		free(open_table);
	}
  open_table = malloc(MAX_OPEN * sizeof(sfs_open));
  for (i = 0; i < MAX_OPEN; i++) {
    open_table[i].node = -1;
  }
  if (fresh == 1) {
		init_fresh_disk("SFS_DISK_IMAGE", SFS_BK_SIZE, SFS_NUM_BKS);

		BK_SIZE = SFS_BK_SIZE;
		NUM_BKS = SFS_NUM_BKS;
		NUM_FREE_BKS = SFS_NUM_FREE_BKS;
		NUM_FREE_EYS = BK_SIZE * NUM_FREE_BKS / sizeof(sfs_free);
		NUM_INODE_BKS = SFS_NUM_INODE_BKS;
		NUM_INODE_EYS = SFS_BK_SIZE * SFS_NUM_INODE_BKS / sizeof(sfs_inode);
		NUM_IND_BK_EYS = BK_SIZE / sizeof(int);
		NUM_DIR_BK_EYS = BK_SIZE / sizeof(sfs_file);
		ROOT_INODE = 0;
		MAX_FILE_SIZE = (SFS_NUM_DIR_PTRS + NUM_IND_BK_EYS) * BK_SIZE;

    // create and write super block (block 0)
    sfs_super* super = malloc(SFS_BK_SIZE);
    super->magic = 0xAABB0005;
    super->block_size = SFS_BK_SIZE;
    super->file_system_size = SFS_NUM_BKS;
    super->free_desc_table_length = SFS_NUM_FREE_BKS;
    super->inode_table_length = SFS_NUM_INODE_BKS;
    super->root_dir_inode_num = 0;

    write_blocks(0, 1, super);
    free(super);

    // create and write free block (block 1-9)
    free_table = malloc(SFS_BK_SIZE * SFS_NUM_FREE_BKS);
    free_table->begin = SFS_NUM_FREE_BKS + SFS_NUM_INODE_BKS + 2;
    free_table->num_free = SFS_NUM_BKS - SFS_NUM_FREE_BKS - SFS_NUM_INODE_BKS - 2;

    // create and write inode blocks (block 10-63)
    inode_table = malloc(SFS_BK_SIZE * SFS_NUM_INODE_BKS);
    createInodeTable(inode_table);
    addInodeEntry();
		inode_table[ROOT_INODE].block[0] = SFS_NUM_FREE_BKS + SFS_NUM_INODE_BKS + 1;

    // create and write root directory block (block 64)
    root_dir = malloc(SFS_BK_SIZE);
    createDirectory(root_dir, 0);

		writeInodeTable();
		writeFreeTable();
    write_dir_bk();

    return 0;
  } else {
		init_disk("SFS_DISK_IMAGE", SFS_BK_SIZE, SFS_NUM_BKS);

		// read from super block and initialize constants
    sfs_super* super = malloc(4096);
		read_blocks(0, 1, super);

		BK_SIZE = super->block_size;
		NUM_BKS = super->file_system_size;
		NUM_FREE_BKS = super->free_desc_table_length;
		NUM_FREE_EYS = BK_SIZE * NUM_FREE_BKS / sizeof(sfs_free);
		NUM_INODE_BKS = super->inode_table_length;
		NUM_INODE_EYS = BK_SIZE * NUM_INODE_BKS / sizeof(sfs_inode);
		NUM_IND_BK_EYS = BK_SIZE / sizeof(int);
		NUM_DIR_BK_EYS = BK_SIZE / sizeof(sfs_file);
		ROOT_INODE = super->root_dir_inode_num;
		MAX_FILE_SIZE = (SFS_NUM_DIR_PTRS + NUM_IND_BK_EYS) * BK_SIZE;
		free(super);

		// read free table blocks
		if (free_table != NULL) {
			free(free_table);
		}
		free_table = malloc(BK_SIZE * NUM_FREE_BKS);
		read_blocks(1, NUM_FREE_BKS, free_table);

		// read inode table blocks
		if (inode_table != NULL) {
			free(inode_table);
		}
		inode_table = malloc(SFS_BK_SIZE * SFS_NUM_INODE_BKS);
		read_blocks(NUM_FREE_BKS + 1, NUM_INODE_BKS, inode_table);

		// read root directory block(s)
		if (root_dir != NULL) {
			free(root_dir);
		}
		int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
		int file_index_count = inode_unpack_file_index(ROOT_INODE, file_index);
		int i;
		root_dir = malloc(BK_SIZE * file_index_count);
		read_blocks(NUM_FREE_BKS + 1, NUM_INODE_BKS, inode_table);
		for (i = 0; i < file_index_count; i++) {
			read_blocks(file_index[i], 1, ((char*)root_dir)+i*BK_SIZE);
		}
		NUM_DIR_BK_EYS = (file_index_count * BK_SIZE) / sizeof(sfs_file);
		free(file_index);

    return 0;
  }
}

int sfs_fopen(char *name)
{
	int inode = inode_find_for_name(name);
	if (inode == -1) { // file does not exist
		inode = createNewFile(name);
		write_dir_bk();
		return addOpenEntry(inode);
	} else { // file exists already
		int i;
		for (i = 0; i < MAX_OPEN; i++) {
			if (open_table[i].node == inode) {
				return i;
			}
		}
		return addOpenEntry(inode);
	}
	return -1;
}

int sfs_fclose(int fileID)
{
	int inode = open_table[fileID].node;
	if (inode > 0) {
		open_table[fileID].node = -1;
		return 0;
	} else {
		return -1;
	}
}

int sfs_fwrite(int fileID, const char *buf, int length) {
	if (fileID > MAX_OPEN) {
		return -1;
	} 
	int inode = open_table[fileID].node;
	if (inode < 0) {
		return -1;
	}
	int size = inode_table[inode].size;
	if (size + length > MAX_FILE_SIZE) {
		return -1;
	}

	int error = 0, ret = 0;
	int length_rem = length;
	char *cur_input_ptr = (char *)buf;
	int file_ptr = open_table[fileID].ptr;
	int first_block_number = getBlockNumber(file_ptr);
	int first_block_offset = getBlockOffset(file_ptr);
	int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
	int file_index_count = inode_unpack_file_index(inode, file_index);
	char *tmp;

	// allocate a new data block if necessary
	if (size <= 0 || file_index[first_block_number] < 0) {
		file_index[first_block_number] = allocateBlocks(1);
		file_index_count += 1;
		ret = inode_repack_file_index(inode, file_index, file_index_count);
		error += ret < 0 ? -1 : 0;
	}

	// write to the partial block if there is one.
	tmp = malloc(BK_SIZE);
	ret = read_blocks(file_index[first_block_number], 1, tmp);
	error += ret < 0 ? -1 : 0;
	int read_length = (BK_SIZE-first_block_offset < length) ? BK_SIZE-first_block_offset : length;
	memcpy((tmp+first_block_offset), cur_input_ptr, read_length);
	ret = write_blocks(file_index[first_block_number], 1, tmp);
	error += ret < 0 ? -1 : 0;
	free(tmp);
	cur_input_ptr += read_length;
	length_rem -= read_length;

	// write to remaining existing blocks if they exist.
	int i;
	if (length_rem > 0 && file_index_count > first_block_number + 1) {
		for (i = first_block_number + 1; i < file_index_count || length_rem <= 0; i++) {
			if (length_rem > BK_SIZE) {
				ret = write_blocks(file_index[i], 1, cur_input_ptr);
				error += ret < 0 ? -1 : 0;
				length_rem -= BK_SIZE;
				cur_input_ptr += BK_SIZE;
			} else {
				tmp = malloc(BK_SIZE);
				ret = read_blocks(file_index[i], 1, tmp);
				error += ret < 0 ? -1 : 0;
				memcpy(tmp, cur_input_ptr, length_rem);
				ret = write_blocks(file_index[i], 1, tmp);
				error += ret < 0 ? -1 : 0;
				free(tmp);
				length_rem = 0;
				cur_input_ptr = (char *)buf+length;
			}
		}
	}

	// write to new blocks if necessary
	if (length_rem > 0) {
		int num_new_blocks = (length_rem / BK_SIZE) + 1;
		int block_begin_new = allocateBlocks(num_new_blocks);
		if (block_begin_new < 0 || block_begin_new >= NUM_BKS) {
			return error-1;
		}
		if (num_new_blocks > 1) {
			ret = write_blocks(block_begin_new, num_new_blocks-1, cur_input_ptr);
			error += ret < 0 ? -1 : 0;
			length_rem -= (BK_SIZE * (num_new_blocks - 1));
			cur_input_ptr += (BK_SIZE * (num_new_blocks - 1));
		}
		tmp = malloc(BK_SIZE);
		memcpy(tmp, cur_input_ptr, length_rem);
		ret = write_blocks(block_begin_new + num_new_blocks - 1, 1, tmp);
		free(tmp);
		error += ret < 0 ? -1 : 0;
		length_rem = 0;
		cur_input_ptr = 0;
		for (i = 0; i < num_new_blocks; i++) {
			file_index[i + file_index_count] = block_begin_new + i;
		}
		ret = inode_repack_file_index(inode, file_index, file_index_count + num_new_blocks);
		error += ret < 0 ? -1 : 0;
	}
	
	free(file_index);
	if (error < 0) {
		return error;
	} else {
		inode_table[inode].size += length - (size - file_ptr) > 0 ? length - (size - file_ptr) : 0;
		open_table[fileID].ptr += length;
		writeInodeTable();
		return length;
	}
}

int sfs_fread(int fileID, char *buf, int length)
{
	if (fileID > MAX_OPEN) {
		return -1;
	} 
	int inode = open_table[fileID].node;
	if (inode < 0) {
		return -1;
	}
	int file_ptr = open_table[fileID].ptr;
	int size = inode_table[inode].size;
	if (file_ptr + length > size) {
		//printf("Warning: request received to read past end of file %d for length %d when ptr is %d and size is %d\n",fileID,length,file_ptr,size);
		length = size - file_ptr;
	}

	int error = 0, ret = 0;
	int length_rem = length;
	char *cur_output_ptr = buf;
	int first_block_number = getBlockNumber(file_ptr);
	int first_block_offset = getBlockOffset(file_ptr);
	int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
	int file_index_count = inode_unpack_file_index(inode, file_index);
	char *tmp = malloc(BK_SIZE);

	// read from the first (potentially partial) block
	tmp = malloc(BK_SIZE);
	ret = read_blocks(file_index[first_block_number], 1, tmp);
	error += ret < 0 ? -1 : 0;
	int read_length = (BK_SIZE-first_block_offset < length) ? BK_SIZE-first_block_offset : length;
	memcpy(cur_output_ptr, (tmp+first_block_offset), read_length);
	error += ret < 0 ? -1 : 0;
	free(tmp);
	cur_output_ptr += read_length;
	length_rem -= read_length;

	// read from the remaining blocks if necessary
	int i;
	if (length_rem > 0) {
		for (i = first_block_number + 1; i < file_index_count && length_rem > 0; i++) {
			if (length_rem > BK_SIZE) {
				ret = read_blocks(file_index[i], 1, cur_output_ptr);
				error += ret < 0 ? -1 : 0;
				length_rem -= BK_SIZE;
				cur_output_ptr += BK_SIZE;
			} else {
				tmp = malloc(BK_SIZE);
				ret = read_blocks(file_index[i], 1, tmp);
				error += ret < 0 ? -1 : 0;
				memcpy(cur_output_ptr, tmp, length_rem);
				free(tmp);
				length_rem = 0;
				cur_output_ptr = ((char*)buf)+length;
			}
		}
	}

	free(file_index);
	if (error < 0) {
		return error;
	} else {
		open_table[fileID].ptr += length;
		return length;
	}
}

int sfs_fseek(int fileID, int offset)
{
	if (open_table[fileID].node < 0) {
		return -1;
	} else {
		if (offset > inode_table[open_table[fileID].node].size) {
			return -1;
		}
		open_table[fileID].ptr = offset;
		return offset;
	}
}

int sfs_remove(char *file)
{
	int inode = inode_find_for_name(file);

	if (inode < 0) {
		return -1;
	} else {
		int *file_index = malloc(BK_SIZE + SFS_NUM_DIR_PTRS * sizeof(int));
		int file_index_count = inode_unpack_file_index(inode, file_index);
		int i;
		for (i = 0; i < file_index_count; i++) {
			free_blocks(file_index[i], 1);
		}
		if (file_index_count > SFS_NUM_DIR_PTRS) {
			free_blocks(inode_table[inode].ind, 1);
		}
		inode_table[inode].mode = -1;
		writeInodeTable();
		for (i = 0; i < NUM_DIR_BK_EYS; i++) {
			if (root_dir[i].node == inode) {
				root_dir[i].node = -1;
				break;
			}
		}
		write_dir_bk();
		for (i = 0; i < MAX_OPEN; i++) {
			if (open_table[i].node == inode) {
				open_table[i].node = -1;
				break;
			}
		}
		return 0;
	}
}

int dir_cur_pos = 0;

int sfs_get_next_filename(char* filename)
{
	int i = dir_cur_pos;
	dir_cur_pos = -1;
	for ( ; i < NUM_DIR_BK_EYS; i++) {
		if (root_dir[i].node >= 0) {
			dir_cur_pos = i;
			break;
		}
	}
	if (dir_cur_pos >= 0) {
		//filename = strdup(strcat(root_dir[dir_cur_pos].name, root_dir[dir_cur_pos].ext));
		char *tmp = strdup(root_dir[dir_cur_pos].name);
		char *new_name;
		if (strlen(root_dir[dir_cur_pos].ext) > 0) {
			new_name = strcat(tmp, ".");
		}
		new_name = strcat(tmp, root_dir[dir_cur_pos].ext);
		strncpy(filename, new_name, SFS_FILE_NAME_LEN + SFS_FILE_EXT_LEN + 1);
		dir_cur_pos++;
		return dir_cur_pos;
	} else {
		dir_cur_pos = 0;
		return 0;
	}
}

int sfs_GetFileSize(const char* path)
{
	int inode = inode_find_for_name((char*)path);
	if (inode < 0) {
		return -1;
	} else {
		return inode_table[inode].size;
	}
}
/*
int main(int argc, char *argv[])
{
  mksfs(1);
  sfs_super *b = malloc(SFS_BK_SIZE);
  read_blocks(0, 1, b);
  printf("Magic number : %lu\n", b->magic);
  printf("Block size : %d\n", b->block_size);
  sfs_inode *i = malloc(SFS_BK_SIZE * SFS_NUM_INODE_BKS);
  read_blocks(SFS_NUM_FREE_BKS + 1, SFS_NUM_INODE_BKS, i);
  printf("Root inode pointer 0 is : %d\n", i[0].block[0]); 
  printf("Root inode pointer 1 is : %d\n", i[0].block[1]); 
  printf("2nd inode points to block : %d\n", i[1].block[0]);
  printf("3rd inode points to block : %d\n", i[2].block[0]);
  printf("1 file_desc is %lu bytes\n", sizeof(sfs_file));
  sfs_file *f = malloc(SFS_BK_SIZE * SFS_NUM_FREE_BKS);
  read_blocks(SFS_NUM_FREE_BKS + SFS_NUM_INODE_BKS + 1, 1, f);
  printf("File record 0 name : %s\n", f[0].name);
  printf("File record 1 name : %s\n", f[1].name);
  printf("File record 2 name : %s\n", f[2].name);
  if (f[2].node == 0) {
    printf("File record 2 had null node\n");
  }
  free(b);
  free(i);
  free(f);
  int tmp = sfs_fopen("larry.txt");
  printf("larry.txt gave id %d\n",tmp);
  tmp = sfs_fopen("greg.txt");
  printf("greg.txt gave id %d\n",tmp);
  tmp = sfs_fopen("bob.txt");
  printf("bob.txt gave id %d\n",tmp);
  tmp = sfs_fopen("mo.c");
  printf("mo.c gave id %d\n",tmp);
  tmp = sfs_fopen("aaa");
  printf("aaa gave id %d\n",tmp);

  printf("%d\n",open_table[0].node);
  printf("%d\n",open_table[1].node);
  printf("%d\n",open_table[2].node);

  sfs_fwrite(0, "DOES THIS MOTHERFUCKER WRITE????", 32);
  sfs_fwrite(1, "YET ANOTHER FUCKING FILE JESUS~~", 32);
  sfs_fwrite(0, "OMG THIS IS SUCH GARBAGE, WHY???", 32);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE", 64);
  sfs_fwrite(0, "THIS SHOULD BE THE FIRST IN A NEW BLOCK, LETS SEE IF IT PAYS OFF", 64);

	if (sfs_remove("greg.txt") >= 0) {
		printf("greg.txt removed\n");
	}

	char cur_name[100];
	printf("root dir contains these files:\n");
	while(sfs_get_next_filename(cur_name) != 0) {
		printf("%s\t\t%d\n",cur_name,sfs_GetFileSize(cur_name));
	}

	sfs_fseek(0, 0);
	char* output = malloc(576 * sizeof(char));
	if (sfs_fread(0, output, 576) >= 0) {
		printf("Printing the contents of file larry.txt\n");
		printf("%s\n",output);
	}	

  close_disk();
  return 0;
}
*/
