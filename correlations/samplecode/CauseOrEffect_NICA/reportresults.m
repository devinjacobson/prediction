% Report training results at end of epoch

fprintf(1,'cost = %11.8f,  improvement = %11.8f,  epoch %5i\n',cost, mincost-cost, epochs)
