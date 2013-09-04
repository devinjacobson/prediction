#ifndef BIN_SEARCH_TREE_CPP_UNIVERSITY_OF_OREGON_NIC
#define BIN_SEARCH_TREE_CPP_UNIVERSITY_OF_OREGON_NIC

#include "bin_search_tree.h"

template < class Struct >
bin_search_tree<Struct>::bin_search_tree() 
: head(0), size(0) 
{}

template < class Struct >
bin_search_tree<Struct>::~bin_search_tree()
{
    Struct * temp = pop();
    while(temp != 0) 
    {
        delete temp;
        temp = pop();
    }
}


template < class Struct >
void bin_search_tree<Struct>::insert(Struct * s)
{
    if (head == 0) 
    {
        head = s;
    } 
    else 
    {
        Struct * temp = head;
        int key = s->key;
        bool done = false;

        while(!done) 
        {
	        if(key < temp->key) 
            {
	            if (temp->left != 0) 
                {
	                temp = temp->left;
	            } 
                else 
                {
	                temp->left = s;
	                done = true;
	            }
	        } 
            else 
            {
	            if (temp->right != 0) 
                {
	                temp = temp->right;
	            } 
                else 
                {
	                temp->right = s;
	                done = true;
	            }
	        }
        }
    }
    ++size;
}

template < class Struct >
Struct* bin_search_tree<Struct>::pop()
{
    Struct * top_ = head;
    Struct * rtn = 0;

    if (head == 0) 
    {
        return 0;
    } 
    else if (top_->left == 0) 
    {
        rtn = head;
        head = head->right;
    } 
    else 
    {
        while(top_->left->left != 0) 
        {
	        top_ = top_->left;
        }
        rtn = top_->left;
        top_->left = top_->left->right;
    }
  
    rtn->left = 0;
    rtn->right = 0;
    --size;

    return rtn;
}

#ifdef INSTANTIATE_TEMPLATES
#include "index_node.h"
template class bin_search_tree< index_node >;
#endif

#endif
// BIN_SEARCH_TREE_CPP_UNIVERSITY_OF_OREGON_NIC
