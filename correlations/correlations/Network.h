#pragma once
#include "stdafx.h"

using namespace std;

class NNBase;
class NFactor;

template<typename T>
class CNetwork
{
public:
	CNetwork(){m_nHeapCounter = 0;};
	T* m_pHeap;
	T** m_ppHeap;
	int m_nHeapCounter;
	int m_nNumElements;
	//percent of network used in the prediction
	float m_fTempPercentOfNetwork;
	//the uniqueness
	float m_fUniqueness;
	std::map<int, T*> m_mapAll;

	T* GetAt(int nId){
		map<int, T*>::iterator cur = m_mapAll.find(nId);
		if (cur == m_mapAll.end()){
			return NULL;
		}
		else{
			return (cur->second);
		}
		
	};

	int LoadSingle(void* pData, int id, std::map<string, NFactor*> *pMapFactors){
		map<int, T*>::iterator cur = m_mapAll.find(id);
		T* pTemp;
		if (cur == m_mapAll.end()){
			if (m_nHeapCounter < m_nNumElements){
				pTemp = &(m_pHeap[m_nHeapCounter]);
				pTemp->m_nId = id;
				m_mapAll[id] = pTemp;
				pTemp->Init(pData, pMapFactors);
				m_nHeapCounter++;
				return 1;
			}
		}
		else{
			//do we want to init twice?  
			//(cur->second)->Init(pData, pMapFactors);
			return 0;
		}
		return 0;

	};

	int Init(int nCount){
		m_pHeap = new T[nCount];
		m_ppHeap = new T *[nCount];
		m_nNumElements = nCount;
		for (int k = 0; k<nCount; k++){
			m_ppHeap[k] = &(m_pHeap[k]);
		}
		return 0;
	};

	int GetClosest(T* p, int nNum, map<string, NFactor*> *pMapFactors, map<string, double> *pWeights){
		map<int, T*>::iterator iter;
		float fCorr;
		T* pTemp;
		for (int i=0; i< m_nNumElements; i++){
			pTemp = &(m_pHeap[i]);
			fCorr = ((NNBase*)p)->GetCorr(pTemp, pMapFactors, pWeights);
			((NNBase*)pTemp)->m_fTempCorr = fCorr;
		}
		//fCorr is between -1 and 1, 
		//need to add the user->movie part here to the pTemp->m_fTempCorr variable.  

		qsort(m_ppHeap, m_nNumElements, sizeof(T*), compareCorr);

		//go through and get the closest 10 and add them to T->m_NN
		return 0;
	};
	int OutputResults(string file){
		for (int i=0; i< nNum && i<m_nNumElements; i++){
			//T->GetUpdateNNQuery(
			//INSERT INTO t_nfuserNN(userid, NNuserid, corr, 
			//p->UserID, m_ppHeap[i]->userid
			//m_ppHeap[i]->m_fTempCorr
		}
		return 0;
	};

	float GetPrediction(int nId, NNBase* pOther, int nDate){
		//maybe GetPrediction(nId, NNBase* pOther, int nDate)
		//this is teh real work here.  
		//has this person watched
		//get the heap
		float fRet = 0;
		map<int, T*>::iterator cur = m_mapAll.find(nId);
		if (cur == m_mapAll.end()){
		}
		else{
			fRet = cur->second->GetPrediction(pOther->m_nId, nDate);

		}
		//if this is a user, 
		//see if we have predictions from similar movies from any of the people in our NN.  
		//we will have X SQL statements, but they should be quick because of the indexes.  
		//SELECT * from t_nfratings where (userid = A or userid = B or userid = C) and movieid = X
		//SELECT * from t_nfratings where (userid = D or userid = E or userid = F) and (movieid = Y or movieid = Z or movieid = )
		//go one level on the movies and up to two levels on the users.  
		//get ratings of similar users with this movie, and of similar users and similar movies.  
		//and just go one user at a time while we are making predictions.  
		//This will be the least memory intensive process.  

		//go through the m_NN until we have a certain number of predictors.  
		//call that ->GetPrediction(), and add up the 
		//add the date prediction as well here for this user.  

		return fRet;
	};

	static int compareCorr(const void* p1, const void* p2){
		if ( ((*((NNBase**)p2))->m_fTempCorr) < ((*((NNBase**)p1))->m_fTempCorr)) return 1;
		else if ( ((*((NNBase**)p2))->m_fTempCorr) > ((*((NNBase**)p1))->m_fTempCorr)) return -1;
		else return 0;
//		return (int)ceil(((*((NNBase**)p2))->m_fTempCorr - (*((NNBase**)p1))->m_fTempCorr)*100000);
	};

	int Setup(map<string, NFactor*> *pMapFactors, map<string, double> *pWeights){
		/*
		for (int j=0; j< m_pHeap[0].m_GlobalAttributes.size(); j++){
			m_pHeap[0].m_GlobalAttributes[j].m_fAvg /= m_nNumElements;
		}
		float fTemp;
		int i, j;
		//set up the stddev.  
		for (j=0; j< m_pHeap[0].m_GlobalAttributes.size(); j++){
			for (i=0; i<m_nNumElements; i++){
				if (0){//m_pHeap[i].m_Attributes[j].m_fAvg NOT INITIALIZED)
				}
				else{
				fTemp = (m_pHeap[i].m_Attributes[j].m_fAvg - m_pHeap[0].m_GlobalAttributes[j].m_fAvg);
				m_pHeap[0].m_GlobalAttributes[j].m_fStdDev += fTemp*fTemp;
				}
			}
			m_pHeap[0].m_GlobalAttributes[j].m_fStdDev /= (m_nNumElements-1);
			m_pHeap[0].m_GlobalAttributes[j].m_fStdDev = sqrt(m_pHeap[0].m_GlobalAttributes[j].m_fStdDev);
		}	
		//set up the normalized values
		for (j=0; j< m_pHeap[0].m_GlobalAttributes.size(); j++){
			for (i=0; i<m_nNumElements; i++){
				if (m_pHeap[0].m_GlobalAttributes[j].m_fStdDev > 0){
					fTemp = (m_pHeap[i].m_Attributes[j].m_fAvg - m_pHeap[0].m_GlobalAttributes[j].m_fAvg);
					//dont want to include the stddev here as this is part of the prediction
//					fTemp /= m_pHeap[0].m_GlobalAttributes[j].m_fStdDev;
					m_pHeap[i].m_Attributes[j].m_fNormalizedValue = fTemp;
				}
			}
		}
		*/
		for (int i=0; i<m_nNumElements; i++){
			float fTemp = m_nNumElements;
			fTemp *= 4000000; //4 million is greater than anything we are going to have.  this means 10 users in each.  
			fTemp /= pow((double)m_nNumElements, (int)2);
			if (fTemp > m_nNumElements/10) //only want up to numelements/10
				fTemp = m_nNumElements/10;
			int nTemp = fTemp;
			if (m_pHeap[i].m_nNNSize < nTemp){
				GetClosest(&(m_pHeap[i]), nTemp, pMapFactors, pWeights);//need  a function here which decreases as x increases.  
				InitNN(&(m_pHeap[i]), nTemp);
				for (int k=0; k < nTemp; k++){
					InitNN(m_ppHeap[k], nTemp, k/2);
				}

			}			
		}
		return 0;
	};

	int InitNN(T* p, int nTemp /*size*/, int nOffset = 0){
		//may need to allocate this all at once if we get problems here.  
		if (p->m_nNNSize < nTemp){
			p->m_ppNN = (NNBase**) (new T *[nTemp]);
			p->m_nNNSize = nTemp;
			for (int k=nOffset; k < nOffset+nTemp; k++){
				//create this 
				p->m_ppNN[k-nOffset] = m_ppHeap[k];
			}
		}
		return 0;
	};
	//LoadAll(), 
	//Setup()

	//need to figure out the general statistics on the ratings, etc.  
	//so we need to know the number of ratings for each one.  
	//then set up the deviation from the average or find the most likely to deviate from the average, by looking at movies most similar to 
	//the ones that most deviate from the average.  
	//it may not be worth guessing below 2 or above 4 at any point at all.  The risk may be too great.  Just to keep in mind.  
	//
	//GetClosest(), OutputToDB()
public:
	~CNetwork(void){};
};
