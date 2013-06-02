#ifndef INDEX_ARRAY_H_UNIVERSITY_OF_OREGON_NIC
#define INDEX_ARRAY_H_UNIVERSITY_OF_OREGON_NIC

/*
Stores a set of randomly permuted numbers. The numbers are 
stored as an array of n "indexes." Each index consists of 
set of "right" and "left" pointers, an integer index number, 
and a random value used for sorting the numbers. On each  
call of the permute function, the indicies are sorted 
using a binary tree. The order of indicies in the tree is 
stored in an integer array.                    
*/

#include "index_node.h"
#include "bin_search_tree.h"
#include "MersenneTwister.h"


class IndexArray : public bin_search_tree<index_node> 
{
public:
    index_node                    * idx;
    int                           * index;
    int                             size;
    int                             n;

    // create an array of index_nodes and initialize them
    IndexArray(int s, unsigned long seed );
    ~IndexArray();
    int* ordered_indices();

    // select n values from the index_array where n = size OR a user selected 
    // value, see int* permute_uniform(int n). Assign each value a uniform random
    // number, insert them in a binary search tree (not IndexArray inherits BST)
    // pop them and assign the index value to each element of the permuted indices
    int* permute_uniform();
    int* permute_uniform(int n_);
    void print_tree();

private:
    void print(index_node * n);

    MersenneTwister m_rng;
};

#endif
// INDEX_ARRAY_H_UNIVERSITY_OF_OREGON_NIC
