#ifndef NICMATRIX_H_UNIVERSITY_OF_OREGON_NIC
#define NICMATRIX_H_UNIVERSITY_OF_OREGON_NIC

#include <cstdlib>
#include <cassert>
#include <iostream>

#include "NicVector.h"

template <class T> class NicVector;

using namespace std;


// NicMatrix is a thin class to wrap around
// a data array. Pretty much everything is 
// public, which is poor OO taste but makes
// some of the numeric details easier to
// implement.
template <class T>
class NicMatrix 
{
public:
    int rows;
    int columns;
    int size;
    int total_size;
    int total_rows;
    int total_columns;
    int n_cpus;
    int rank;
    int referenceCount;
    bool isAlias;

    T* data;

    NicMatrix(int r = 0, int c = 0, int t_r = 0, int t_c = 0, 
         int rk = 0, int n_c = 1);

    NicMatrix( const NicMatrix<T>& m);

    ~NicMatrix();

    static void incrementReferenceCount( NicMatrix<T>* matrix );
    static void freeReference( NicMatrix<T>* matrix );

    void zero_matrix();
    void identity_matrix();
    void random_matrix(T min = 0, T max = 1);
    void constant_matrix(T & c);
    void add_row(NicVector<T>* data, int i);
    void add_column(NicVector<T>* data, int i);
    void add_diagonal(NicVector<T>* data);

    void alias( T* data, int r, int c  );

    void resize( int r = 0, int c = 0, int t_r = 0, int t_c = 0,
        int rk = 0, int n_c = 0 );

    void swap_matrices(NicMatrix<T>* A);

    T& operator()(int i, int j);

    void operator=(NicMatrix<T>& B);

    friend ostream& operator<<(ostream & out, const NicMatrix<T>& v) 
    {
        int r = v.rows;
        int c = v.columns;
        T* data = v.data;
        T* d = NULL;

        for (int i = 0; i < r; i++) 
        {
            d = data + i;
            for (int j = 0; j < c; j++) 
            {
                out << *d << " ";
                d += r;
            }
            cout << endl;
        }
        return out;
    }

};

#endif
// NICMATRIX_H_UNIVERSITY_OF_OREGON_NIC
