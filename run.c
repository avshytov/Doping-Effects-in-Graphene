#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <complex.h>

//#define N 7    //Program is specific to a given N value

double comp(double lam,int n);
double real(double lam,int n);

int main (){

int k=0;
double i=0;
double eps,lam,lam_neg;
double a_n,b_n,c_n,d_n;
double a_neg,b_neg,c_neg,d_neg;
double t,t_neg;

int n=0;
eps=0;
lam=0;
lam_neg=0;
      scanf("%d",&n);
  for(i=0;i<100000;i++){
	eps=((i/10000)-5.001); //Forces range over -5<x<5
	lam = (eps+1);
	lam_neg= (eps-1);	



		if((fabs(lam)<2)&&(fabs(lam_neg)<2)){  
    		t= comp(lam,n);
		t_neg=comp(lam_neg,n);
		printf("%f %f %f\n",eps,t,t_neg);

		}
		if((fabs(lam)>2)&&(fabs(lam_neg)<2)){

		 t=real(lam,n);
		 t_neg=comp(lam_neg,n);
		printf("%f %f %f\n",eps,t,t_neg);
		}

		if((fabs(lam)<2)&&(fabs(lam_neg)>2)){
		 t=comp(lam,n);  
    		 t_neg= real(lam_neg,n);
		 printf("%f %f %f\n",eps,t,t_neg);

		}
		if((fabs(lam_neg)>2)&&(fabs(lam)>2)){
		 t=real(lam,n);
		 t_neg=real(lam_neg,n);
		printf("%f %f %f\n",eps,t,t_neg);
		}

   }
		


return 0;

}

double comp(double lam,int n){

double a_n=0,b_n=0,c_n=0,d_n=0,t=0,t_neg=0,arg1,arg;
double test=0;

arg = (atan2((sqrt(1-pow(lam,2)/4)),(lam/2)));

			a_n = (( -1*sin((n-1)*arg)) / (sin(arg)));
	
			b_n =  ((sin(n*(arg))) / (sin(arg)));

			c_n = ((-1*sin(n*arg)) / (sin(arg)));

			d_n = (sin((n+1)*arg) / (sin(arg)));   
	
			t = ((4)/(pow((a_n+d_n),2)+pow((c_n-b_n),2)));

return (t);

}

double real(double lam,int n){
double a_n=0,b_n=0,c_n=0,d_n=0,t=0,xi=0,cons;

xi=((lam/2)+pow(( ((pow(lam,2))/(4))-1),0.5));
cons= (1/(sqrt( pow(lam,2)-4)));

			a_n= (-1*cons*((pow(xi,(n-1)))-(pow(xi,(-1*(n-1))))));

			b_n= (cons*((pow(xi,n))-(pow(xi,(-1*n)))));

			c_n= (-1*cons*((pow(xi,n))-(pow(xi,(-1*n)))));

			d_n= (cons*((pow(xi,(n+1)))-(pow(xi,(-1*(n+1))))));

			t = ((4)/(pow((a_n+d_n),2)+pow((c_n-b_n),2)));

return (t);
}











