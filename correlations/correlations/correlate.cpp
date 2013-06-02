#include "stdafx.h"
#include "Extractor.h"
#include "Network.h"
#include "NNBase.h"
#include "lmcurve.h"

#define MYFACTORS 2

/*
Perfect:    0.0
All 0:        0.6170202739078683
Mean:        0.641787529179134
All 15:        2.61228002028692
*/


double flinear( double t, const double *p )
{
    return
        p[0]+p[1]*t;
};

double fexp(double t, const double *p){
	return exp(t*p[1]-p[0]);
};

double flog(double t, const double *p){
	return log(t)*p[0]+p[1];
};

//sort to be in order.  
static int compare(const void* p1, const void* p2){
	//comparing the first double in the array.  
	return *(double*)p1 - *(double*)p2;
};

static double d[MAX_ENTRIES][2];
static double d2[2][MAX_ENTRIES];

void fit(int n_par, double par[2], simple* pAB, int nCount, NFactor* pFactor1, NFactor* pFactor2){
	char * pRet = NULL;
	//this wont work for the DISCRETE yet, because we have the pRet which we have to use.  
	//get all values into the d array
	if (nCount > MAX_ENTRIES) return;
	for (int i=0; i< nCount; i++){
			double value = pFactor1->getValue((void*)&(pAB[i]), pRet);
			//get the value of the 
			d[i][0] = value;

			double value2 = pFactor2->getValue((void*)&(pAB[i]), pRet);
			d[i][1] = value2;

	}

	//should probably sort this so we can get something linear.  
	//should be able to use the qsort method.  
	qsort(d, nCount, sizeof(double)*2, compare);

	for (int i=0; i<2; i++){
		for (int j=0; j< nCount; j++){
			d2[i][j] = d[j][i];
		}
	}

	double ini[2];
	int j;
	for( j=0; j<n_par; ++j ){
		ini[j] = 10. * rand()/RAND_MAX; /* to generate data */
		par[j] = 10. * rand()/RAND_MAX; /* start values for fit */
	}
	int m_dat = nCount;

	/* auxiliary parameters */

	lm_status_struct status;
	lm_control_struct control = lm_control_double;
	control.maxcall = 8000;
	control.printflags = 0;

	/* perform the fit */

	lmcurve_fit(n_par, par, m_dat, d2[0], d2[1], pFactor1->f, &control, &status);
//	lmcurve_fit( n_par, par, m_dat, t, y, f, &control, &status );


	for (int i=0; i< n_par; i++){
		pFactor1->m_fFit[i] = par[i];
	}
//	pFactor1->m_fFit[0] = par[0];
//	pFactor1->m_fFit[1] = par[1];


}



int createAB(int typeA, int typeB, int length, std::map<string, NFactor*> *pMapFactors){
	NFactor *pFactor;
	int nOffset = sizeof(int);
	pFactor = new NFactor(typeA, nOffset, sizeof(int));
	pFactor->f = flinear;
	(*pMapFactors)["A"] = pFactor;

	nOffset += sizeof(int);
	pFactor = new NFactor(typeB, nOffset, sizeof(int));
	pFactor->f = flinear;
	(*pMapFactors)["B"] = pFactor;
	return 0;
}


int _tmain(int argc, _TCHAR* argv[])
{


	Extractor* ext = new Extractor();
	simple* pAB = new simple[MAX_ENTRIES];

	simple* results = new simple[MAX_ENTRIES];
	std::map<string, NFactor*> *pMapFactors = new std::map<string, NFactor*>;
	map<string, double> weights;
	map<int, string> factors;

	//so set up the factors just 2.  
	//we have to read what the type is.  
	/*
		So categorical and binary is DATA_TYPE_DISCRETE_INT
		otherwise it is just DATA_TYPE_INT it seems at least for this.  
		set up a function to analyze the whole thing.  
		separate the file reading and the analysis.  
		we want to be able to use this.  
		So perhaps we just want to create a simple struct when reading in and then we find the 
		correlation and causation.  just use the Factor to do this like we have below.  
		with the dd variable.  
		add to the factor logic to find causation.  
		and auto-regressed time causation as well

		ok so we have the base set up. now what do we want to do, just calculate correlation for now.  
		then we want to calculate causation.  

		ok, so we have some excess data, but this is interesting.  
		Is causation something we can calculate.  
		I understand it could be if you have a time series, but if you dont, how do you go about it?  

		http://www.causality.inf.ethz.ch/cause-effect.php?page=help
		http://webdav.tuebingen.mpg.de/causality/
		
		study a bit and see if any of it makese sense.  
		I am a bit doubtful to begin with if you just have two pieces of data.  
		But it is interesting.  
		could we do something like autocorrelate within a variable, and then see if this
		gives us some idea as to the function of the variable itself. 
		I think we have to order by one variable or the other.  
		And then think about how to go forward from there.  
		if we order, then autocorrelate, what does that tell us?  
		is it any help to fit a function and then take the deviations of each variable?  
		does this make sense?  This is part of what they are doing in some of the papers.  

		

	*/
	factors[0] = "A";
	factors[1] = "B";


	string base = "C:\\web\\chorrd\\prediction\\correlations\\CEdata_split\\train\\train";
	int k=0;
	for (k=1; k<4;/*7832;*/ k++){
		char buf[16];
		sprintf(buf, "%d", k);
		string temp = buf;
		int nEntries = ext->getAB(base + temp + ".txt", pAB);

		createAB(DATA_TYPE_INT, DATA_TYPE_INT, nEntries, pMapFactors);

		CNetwork<NNBase> network;
		network.Init(nEntries);
		int nTotalMembers = 0;
		for (int i=0; i< nEntries; i++){
			network.LoadSingle(&(pAB[i]), pAB[i].id, pMapFactors);
		}



		for (int i=0; i< nEntries; i++){
			NNBase* pN = network.GetAt(pAB[i].id);
			map<string, NFactor*>::iterator cur = pMapFactors->begin();

			for( ; cur != pMapFactors->end(); ++cur ){
				//do logic
				cur->second->InitAvg(pN->m_pMe);
			}
		}
		
		for (int i=0; i< nEntries; i++){
				NNBase* pN = network.GetAt(pAB[i].id);
				map<string, NFactor*>::iterator cur = pMapFactors->begin();

				for( ; cur != pMapFactors->end(); ++cur ){
					//do logic
					cur->second->InitStdDev(pN->m_pMe);
				}
		}
		
		map<string, NFactor*>::iterator cur = pMapFactors->begin();

		for( ; cur != pMapFactors->end(); ++cur ){
			//do logic
			cur->second->FinishStdDev(nEntries);
		}

		//could get a matrix of correlation coefficients here.  
		//but first lets just get one.  
		double dd[MYFACTORS][MYFACTORS];

		for (int i=0; i< MYFACTORS; i++){
			for (int j=0; j<MYFACTORS; j++){
				map<int, string>::iterator cur = factors.find(i);
				map<int, string>::iterator cur2 = factors.find(j);
				//this has to be passed the offset in the second parameter?  
				//why did we have +2 here all the time?  
				dd[i][j] = (*pMapFactors)[ cur->second ]->getCorrelation((*pMapFactors)[ cur2->second ], pAB, sizeof(simple), nEntries);

				if (i==0){
					(*pMapFactors)[ cur2->second ]->m_fCorrelation = dd[i][j];
					//make the curve fits for each of these.  
					//this is for the prediction.  
					int n_par = 2;
					double ini[2], par[2];
					fit(n_par, par, pAB+2, nEntries, (*pMapFactors)[ cur2->second ], (*pMapFactors)[ cur->second ]);
				}
				if (i==0 && j==1){
					results[k].id=k;
					results[k].A = dd[i][j]*100000;
				}
			}
		}

	}
	ext->output(base + "results.txt", results, k);
//	double result = verify(pAB, nEntries);

	return 0;
}

