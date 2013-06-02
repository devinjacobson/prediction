#ifndef BIN_SEARCH_TREE_H_UNIVERSITY_OF_OREGON_NIC
#define BIN_SEARCH_TREE_H_UNIVERSITY_OF_OREGON_NIC

// a very simple search tree.
template<class Struct>
class bin_search_tree 
{
public:
    Struct*  head;
    int      size;

    bin_search_tree();

    ~bin_search_tree();

    void insert(Struct * s);

    Struct* pop();
};

#endif
// BIN_SEARCH_TREE_H_UNIVERSITY_OF_OREGON_NIC
