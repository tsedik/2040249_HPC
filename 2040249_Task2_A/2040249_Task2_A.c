#include <stdio.h>

#include <stdlib.h>

#include <string.h>

#include <time.h>

/*
to compile :
gcc -o 2040249_Task2_A 2040249_Task2_A.c 

to run:
./2040249_Task2_A

Tsering Dikey Lama [2040249], University of Wolverhampton, Herald College Kathmandu

*/

int time_difference(struct timespec *start, struct timespec *finish, long long int *difference)
 {
	  long long int ds =  finish->tv_sec - start->tv_sec; 
	  long long int dn =  finish->tv_nsec - start->tv_nsec; 

	  if(dn < 0 ) 
	  {
	    ds--;
	    dn += 1000000000; 
          } 

	  *difference = ds * 1000000000 + dn;
	  return !(*difference > 0);
}

    int main(){
    	struct timespec start, finish;
	long long int time_elapsed;

      int a[2][2], b[2][2], c[2][2], i, j;

      int m1, m2, m3, m4 , m5, m6, m7;

     

      printf("Enter the 4 elements of first matrix: ");

      for(i = 0;i < 2; i++)

          for(j = 0;j < 2; j++)

               scanf("%d", &a[i][j]);

     

      printf("Enter the 4 elements of second matrix: ");

      for(i = 0; i < 2; i++)

          for(j = 0;j < 2; j++)

               scanf("%d", &b[i][j]);

     

      printf("\nThe first matrix is\n");

      for(i = 0; i < 2; i++){

          printf("\n");

          for(j = 0; j < 2; j++)

               printf("%d\t", a[i][j]);

      }

     

      printf("\nThe second matrix is\n");

      for(i = 0;i < 2; i++){

          printf("\n");

          for(j = 0;j < 2; j++)

               printf("%d\t", b[i][j]);

      }

     clock_gettime(CLOCK_MONOTONIC, &start);//Start monitoring the duration

      m1= (a[0][0] + a[1][1]) * (b[0][0] + b[1][1]);

      m2= (a[1][0] + a[1][1]) * b[0][0];

      m3= a[0][0] * (b[0][1] - b[1][1]);

      m4= a[1][1] * (b[1][0] - b[0][0]);

      m5= (a[0][0] + a[0][1]) * b[1][1];

      m6= (a[1][0] - a[0][0]) * (b[0][0]+b[0][1]);

      m7= (a[0][1] - a[1][1]) * (b[1][0]+b[1][1]);

     

      c[0][0] = m1 + m4- m5 + m7;

      c[0][1] = m3 + m5;

      c[1][0] = m2 + m4;

      c[1][1] = m1 - m2 + m3 + m6;

     

       printf("\nAfter multiplication using Strassen's algorithm \n");

       for(i = 0; i < 2 ; i++){

          printf("\n");

          for(j = 0;j < 2; j++)

               printf("%d\t", c[i][j]);

       }
     	clock_gettime(CLOCK_MONOTONIC, &finish); //End the duration of the program
	
	//Calculate difference
	time_difference(&start, &finish, &time_elapsed);
	

	printf("\nTime elapsed was %lldns or %0.9lfs\n", time_elapsed, 
         (time_elapsed/1.0e9)); 

       return 0;

    }
