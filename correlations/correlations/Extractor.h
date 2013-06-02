
#pragma once
#include <string>

class Extractor
{
public:
	Extractor(void);
	~Extractor(void);
	int getAB(std::string file, simple* AB);
	int output(std::string file, simple* AB, int nEntries);
};
