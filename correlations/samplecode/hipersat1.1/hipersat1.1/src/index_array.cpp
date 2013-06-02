#ifndef INDEX_ARRAY_CPP_UNIVERSITY_OF_OREGON_NIC
#define INDEX_ARRAY_CPP_UNIVERSITY_OF_OREGON_NIC

#include "index_array.h"
#include <iostream>

using namespace std;

IndexArray::IndexArray(int s, unsigned long seed ) 
:   size(s), n(s), m_rng( seed )
{
    index = new int[size];
    idx   = new index_node[size];

    for (int i = 0; i < size; i++) 
    {
        idx[i].index = i;
    }
}

IndexArray::~IndexArray() 
{
    delete [] index;
    delete [] idx;
}

int*
IndexArray::ordered_indices() 
{

    for (int i = 0; i < size; i++) 
    {
        index[i] = i;
    }
    return index;
}

int* 
IndexArray::permute_uniform() 
{
    for(int i = 0; i < n; i++) 
    {
        idx[i].key  = (int)(m_rng.rand_unsigned_long()%RAND_MAX);//rand();
        insert(&idx[i]);
    }

    //    print_tree();

    for (int i = 0; i < n; i++) 
    {
        index[i] = pop()->index;
    }
    return index;
}

int* 
IndexArray::permute_uniform(int n_) 
{
    if (n_ > size) 
    {
        std::cout << "ERROR: Attempted permutation with n > size of array" 
            << std::endl;
        exit(-13);
    }
    n = n_;
    permute_uniform();
    n = size;
    return index;
}

void IndexArray::print_tree() 
{
    std::cout << "INDEX TREE: " << std::endl;
    print(head);
}

void IndexArray::print(index_node * n) 
{
    if (n == NULL) return;

    if (n->left != NULL) 
    {
        print(n->left);
    }

    std::cout << n->index << " ";

    if (n->right != NULL) 
    {
        print(n->right);
    }
}



#endif
// INDEX_ARRAY_CPP_UNIVERSITY_OF_OREGON_NIC
