#include <iostream>
#include "ProcessReader.h"

using namespace std;

int
main(int argc, char * argv[]) {
  // preset the values for non-MPI versions
  int rank = 0;
  int n_cpus = 1;

  ProcessReader * process_reader  = new ProcessReader(rank, n_cpus);

  process_reader->validate_load();
  
  return 0;
};
