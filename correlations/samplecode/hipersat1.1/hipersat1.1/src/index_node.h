#ifndef INDEX_NODE_H_UNIVERSITY_OF_OREGON_NIC
#define INDEX_NODE_H_UNIVERSITY_OF_OREGON_NIC


/*
Stores a set of randomly permuted numbers. The numbers are stored as an array of
n "indexes." Each index consists of set of "right" and "left" pointers, an      
integer index number, and a random value used for sorting the numbers. On each  
call of the permute function, the indicies are sorted using a binary tree. The  
order of indicies in the tree is stored in an integer array.                    
*/

#include <cstdlib>

class index_node {
public:
    int      index;
    int      key;
    index_node  * right;
    index_node  * left;

    index_node() : right(NULL), left(NULL) {};

    void reset() 
    {
        right = NULL;
        left = NULL;
    }
};

#endif
// INDEX_NODE_H_UNIVERSITY_OF_OREGON_NIC
