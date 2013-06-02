#pragma once
#include "nnbase.h"


class NNAttribute :
	public NNBase
{
public:
	NNAttribute(void);
	virtual int Load(NNBase* p){return 0;};
	virtual float GetCorr(NNBase* p){return 0;};
	virtual float GetPrediction(int nDate){return 0;};
	virtual int Init(void* p){return 0;};
	
	//little bit of waste here.  
//	NNAtribute* m_pInitial;

	int m_nGlobalCount; //count of each of the individual attribute objects.  

	vector<NFactor> *m_GlobalAttributes;
	//1st is global, 2nd is for movieid, 3rd is for userid, but userid should calc manually not using db.  

public:
	~NNAttribute(void);
};
