#pragma once
#include "stdafx.h"
using namespace std;


#define DATA_TYPE_INT 1
#define DATA_TYPE_FLOAT 2
#define DATA_TYPE_SHORT 3
#define DATA_TYPE_DOUBLE 4
#define DATA_TYPE_STRING 5 //this is something we need to figure out the discrete values and could have a prediction for either all of the values.  
#define DATA_TYPE_DISCRETE_INT 6

class NFactor{
public:
	NFactor(int nDataType=DATA_TYPE_INT, int nDataOffset=0, int nDataLength=4){
		m_fAvg = 0; m_fWeight = 0; m_fNormalizedValue = 0;
		m_fStdDev = 0;
		m_fCorrelation = 0;
		m_fFit[0] = 0; m_fFit[1] = 0;
		m_nDataOffset = nDataOffset;
		m_nDataType = nDataType;
		m_nDataLength = nDataLength;
		m_nCount = 0;
		m_pInternalMap = NULL;
		m_pInternalMap2 = NULL;
		if (m_nDataType == DATA_TYPE_STRING){
			m_pInternalMap = new map<string, NFactor*>;
		}
		else if (m_nDataType == DATA_TYPE_DISCRETE_INT){
			m_pInternalMap2 = new map<int, NFactor*>;
		}
		masterS = "";
		master = 0;
	};

	double Predict(void* pData, int nCount=1){
		//pass the count of the InternalMap, if it is DISCRETE or STRING.  
		
		char* pRet = NULL;
		double d = getValue(pData, pRet);
			//look up in the internal map
		NFactor* pFactor = getSubFactor(pData, pRet, nCount);
		if (pFactor){
			return pFactor->Predict(pData, nCount); 
		}
		//return exp(d*m_fFit[0])+m_fFit[1];
		return this->f(d, (m_fFit));
//		return m_fFit[0]+m_fFit[1]*d;
			
		//predict value from d, and multiply the correlation by nCount to see if we have an actual correlation and the error. 
	};

	NFactor* getSubFactor(void* pData, char* pRet, int &nCount){
		if (pRet && (masterS.compare("") == 0 && master == 0)){
			if (m_nDataType == DATA_TYPE_STRING){
				//do we already have it in the map?  
				if (masterS.compare("")==0){
					string str = pRet;
					if (str.compare("") !=0){
						map<string, NFactor*>::iterator cur = m_pInternalMap->find(str);
						if (cur == m_pInternalMap->end()){
							return NULL;
						}
						else{
							nCount /= m_pInternalMap->size();
							return cur->second;
						}
					}
				}			
			}
			else if (m_nDataType == DATA_TYPE_DISCRETE_INT){
				if (master == 0){
					int n = (int)pRet;
					if (n !=0){
						map<int, NFactor*>::iterator cur = m_pInternalMap2->find(n);
						if (cur == m_pInternalMap2->end()){
							return NULL;
						}
						else{
							nCount /= m_pInternalMap2->size();
							return cur->second;
						}
					}
				}
			}
		}
		return NULL;
		
	};

	//get Pearsons correlation
	double getCorrelation(NFactor* pOther, void* pData, int nDataSize, int nDataCount){
		//assumes avg and stddev already set.  
		//pData Assumes the same set of data is used with this and pOther
		double total = 0;
		char* pRet = NULL;
		for (int i=0; i< nDataCount; i++){
			void* pTemp = (char*)pData + i*nDataSize;
			double X = this->getValue(pTemp, pRet);
			double Y = pOther->getValue(pTemp, pRet);
			double temp = (X - this->m_fAvg)*(Y - pOther->m_fAvg);
			total += temp;
		}
		total /= (this->m_fStdDev*pOther->m_fStdDev);
		total /= nDataCount;
		return total;
	};

	double getValue(void* pData, char* &pRet){
		if (m_nDataType == DATA_TYPE_INT){
			int n;
			memcpy(&n, (char*)pData+m_nDataOffset, m_nDataLength);
			return (double)n;
		}
		else if (m_nDataType == DATA_TYPE_FLOAT){
			float f;
			memcpy(&f, (char*)pData+m_nDataOffset, m_nDataLength);
			return (double)f;
		}
		else if (m_nDataType == DATA_TYPE_DOUBLE){
			double f;
			memcpy(&f, (char*)pData+m_nDataOffset, m_nDataLength);
			return f;
		}
		else if (m_nDataType == DATA_TYPE_SHORT){
			short n;
			memcpy(&n, (char*)pData+m_nDataOffset, m_nDataLength);
			return (double)n;
		}
		else if (m_nDataType == DATA_TYPE_STRING){
			//check if it is same and return 1 or 0
			pRet = (char*)pData+m_nDataOffset;
			if (strcmp((char*)pRet, masterS.c_str()) == 0) return 1;
			else return 0;
		}
		else if (m_nDataType == DATA_TYPE_DISCRETE_INT){
			//check if it is same, and return 1 or 0.  
			int n;
			memcpy(&n, (char*)pData+m_nDataOffset, m_nDataLength);
			pRet = (char*)n;
			if (master == n) return 1;
			else return 0;
		}
	};

	void InitStdDev(void* pData){ 
		char* pRet=NULL;
		double d = getValue(pData, pRet);
		m_fStdDev += (d - m_fAvg)*(d-m_fAvg);

	};
	void FinishStdDev(int nCount=0){
		if (nCount <= 0) nCount = m_nCount;
		m_fStdDev /= nCount;
		m_fStdDev = sqrt(m_fStdDev);

		if (m_nDataType == DATA_TYPE_DISCRETE_INT && master == 0){
			map<int, NFactor*>::iterator cur =m_pInternalMap2->begin();
			for (; cur != m_pInternalMap2->end(); ++cur){
				cur->second->FinishStdDev(nCount);
			}
		}
		else if (m_nDataType == DATA_TYPE_STRING && masterS.compare("")==0){
			map<string, NFactor*>::iterator cur =m_pInternalMap->begin();
			for (; cur != m_pInternalMap->end(); ++cur){
				cur->second->FinishStdDev(nCount);
			}
		}
	};

	
	void InitAvg(void* pData){ 
		//pmap is the discrete string map if we want it.  We would have to add a new factor to this map as well.  
		char* pRet = NULL;
		if (m_nDataType == DATA_TYPE_STRING){
			//do we already have it in the map?  
			getValue(pData, pRet);
			if (masterS.compare("")==0){
				string str = pRet;
				if (str.compare("") !=0){
					map<string, NFactor*>::iterator cur = m_pInternalMap->find(str);
					if (cur == m_pInternalMap->end()){
						(*m_pInternalMap)[str] = new NFactor(m_nDataType, m_nDataOffset, m_nDataLength);
						(*m_pInternalMap)[str]->masterS = str;
						(*m_pInternalMap)[str]->f = this->f;
					}
					(*m_pInternalMap)[str]->InitAvg(pData);
				}
			}
			
		}
		else if (m_nDataType == DATA_TYPE_DISCRETE_INT){
			getValue(pData, pRet);
			if (master == 0){
				int n = (int)pRet;
				if (n !=0){
					map<int, NFactor*>::iterator cur = m_pInternalMap2->find(n);
					if (cur == m_pInternalMap2->end()){
						(*m_pInternalMap2)[n] = new NFactor(m_nDataType, m_nDataOffset, m_nDataLength);
						(*m_pInternalMap2)[n]->master = n;
						(*m_pInternalMap2)[n]->f = this->f;
					}
					(*m_pInternalMap2)[n]->InitAvg(pData);
				}
			}
		}

		double d = getValue(pData, pRet);
		m_fAvg = (m_fAvg*m_nCount+d)/(m_nCount+1);
		m_nCount++;
		//calculating rolling average.  
	};

	double (*f)( double t, const double *par );
	map<string, NFactor*> *m_pInternalMap;
	map<int, NFactor*> *m_pInternalMap2;
	string masterS;
	int master;
	int m_nDataOffset;
	short m_nDataType; //DATA_TYPE_INT
	short m_nDataLength;
	double m_fStdDev;
	double m_fAvg;
	int m_nCount;
	double m_fNormalizedValue; //only interested in the normalized value or the rank within the group.  
	double m_fWeight; //weight of the attribute is used in kNN creation and with the Bayesian outcome prediction
	double m_fCorrelation;
	double m_fFit[2];

public:
	~NFactor(){};
};
class NNBase
{
public:
	NNBase(void){m_pmapFactors = NULL; m_nId = 0; m_nNNSize = 0; m_ppNN = NULL;};
	virtual float GetCorr(NNBase* p, map<string, NFactor*> *pMapFactors, map<string, double> *pWeights){return 0;};
	virtual float GetPrediction(int nDate){return 0;};
	virtual int Init(void* p, std::map<string, NFactor*> *pMapFactors){	
		m_pMe = p;
		m_pmapFactors = pMapFactors;
		//go through the factors and add the data for the average
		return 0;
	};
	virtual NFactor* GetFactor(string str){ 
		if (m_pmapFactors){ 
			map<string, NFactor*>::iterator cur = m_pmapFactors->find(str);
			if (cur == m_pmapFactors->end()){
				return NULL;
			}
			else return cur->second;
		}
		return NULL;
	};

	float m_fTempCorr;
	int m_nId;
	void* m_pMe;
	std::map<string, NFactor*> *m_pmapFactors;
	int m_nNNSize;
	NNBase** m_ppNN;
	float m_fBayesian[5]; //percent predictor that this attribute will cause outcome of 1-5 compared with the standard set.  
	//so we have this information for the Global attribute and for each user.  
	//how far is it from the Global attribute average, and the farther it is from the global compared to 
	//the other attributes, it should have a stronger 
	//weight.  but only if the rating is far away from that attributes overall rating.  
	//there will be some outliers with this, but the average rating for any particular attribute should have enough to dampen 
	//any strange effects.  
	//the average rating for that attribute.  calcualate the distance as we do with the clustering thing in metautil.  
	//if I want to use the bayesian for Attributes and compare, I need to create networks for them.  
public:
	~NNBase(void){};
};
