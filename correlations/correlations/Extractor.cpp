#include "StdAfx.h"
#include "Extractor.h"
using namespace std;

Extractor::Extractor(void)
{
}

Extractor::~Extractor(void)
{
}

int Extractor::output(string file, simple* AB, int nEntries){
	FILE* h;
	char buf[1024];
	//write everything here like you would read it.  

	h = fopen(file.c_str(), "w+");

	for (int i=1; i< nEntries; i++){
		//id and A output to the results
		sprintf(buf, "%d, %d\n", AB[i].id, AB[i].A);
		fwrite(buf, 1, strlen(buf), h);
	}
	fclose(h);

	return 0;	

}

int Extractor::getAB(string file, simple* AB){
	FILE* h = fopen(file.c_str(), "r");

		string str;
		string s2;
		char* buf = new char[256];
		int nCounter=-1;
		int nEmptyLines = -1;
		while(fgets(buf, 256, h)){
			nCounter++;
			if (nCounter <= nEmptyLines){
				continue;
			}
			str = buf;
			int nTokens = 0;
				char token = '\t';
				int nPrevToken = -1;
				int j;
				AB[nCounter].id = nCounter;
				for (j=0; j<str.size(); j++){
					if (str[j]==token){
						s2 = str.substr(nPrevToken+1, j-nPrevToken-1);
						if (nTokens == 0){
							AB[nCounter].A=atoi(s2.c_str());

						}
						else if (nTokens == 1){
							AB[nCounter].B=atoi(s2.c_str());

						}
						nTokens++;
						nPrevToken = j;
					}

				}
				s2 = str.substr(nPrevToken+1,j-nPrevToken-1);
				if (s2.length() > 0){
					AB[nCounter].B=atoi(s2.c_str());
				}
				
		}

		delete[] buf;
		fclose(h);

		return nCounter;
}

