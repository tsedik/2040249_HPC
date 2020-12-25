#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
	to compile :
	nvcc -o 2040249_Task3_A 2040249_Task3_A.c 

	to run:
	./2040249_Task3_A

	Tsering Dikey Lama, University of Wolverhampton, Herald College Kathmandu
*/


__device__ char* CudaCrypt(char* rawPassword){

	char * newPassword = (char *) malloc(sizeof(char) * 11);

	newPassword[0] = rawPassword[0] + 2;  
	newPassword[1] = rawPassword[0] - 2;
	newPassword[2] = rawPassword[0] + 1;  
	newPassword[3] = rawPassword[1] + 3;
	newPassword[4] = rawPassword[1] - 3;
	newPassword[5] = rawPassword[1] - 1;
	newPassword[6] = rawPassword[2] + 2;
	newPassword[7] = rawPassword[2] - 2;
	newPassword[8] = rawPassword[3] + 4;
	newPassword[9] = rawPassword[3] - 4;
	newPassword[10] = '\0';

	for(int i =0; i<10; i++){
		if(i >= 0 && i < 6){ //checking all lower case letter limits
			if(newPassword[i] > 122){
				newPassword[i] = (newPassword[i] - 122) + 97;
			}else if(newPassword[i] < 97){
				newPassword[i] = (97 - newPassword[i]) + 97;
			}
		}else{ //checking number section
			if(newPassword[i] > 57){
				newPassword[i] = (newPassword[i] - 57) + 48;
			}else if(newPassword[i] < 48){
				newPassword[i] = (48 - newPassword[i]) + 48;
			}
		}
	}
	return newPassword; //Returns encrypted password
}

__device__ int comparePass(char* str1, char* str2){
	
    while(*str1)
    {
        
        if (*str1 != *str2)
            break;
 
        //Changing Pointer location
        str1++;
        str2++;
    }
 
    // Returing the 0 if the two strings matches 
    return *(const unsigned char*)str1 - *(const unsigned char*)str2;
}

__global__ void crack(char * alphabet, char * numbers){

	char genRawPass[4];
	//Adding test passwords to genRawPass
	genRawPass[0] = alphabet[blockIdx.x];
	genRawPass[1] = alphabet[blockIdx.y];

	genRawPass[2] = numbers[threadIdx.x];
	genRawPass[3] = numbers[threadIdx.y];

	char password[] = "td02";
	//Raw Password being encrypted
	char *encPassword = CudaCrypt(password);
	
	//Comparing encrypted genRawPass with encPassword
	if(comparePass(CudaCrypt(genRawPass),encPassword) == 0){
		printf("Your password is cracked : %s = %s\n", genRawPass, password);
	}
}

int time_difference(struct timespec *start, struct timespec *finish, long long int *difference) {
	long long int ds =  finish->tv_sec - start->tv_sec; 
	long long int dn =  finish->tv_nsec - start->tv_nsec; 

	if(dn < 0 ) {
		ds--;
		dn += 1000000000; 
	} 
	*difference = ds * 1000000000 + dn;
	return !(*difference > 0);
}


int main(int argc, char ** argv){

	char cpuAlphabet[26] = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
	char cpuNumbers[10] = {'0','1','2','3','4','5','6','7','8','9'};

	char * gpuAlphabet;
	cudaMalloc( (void**) &gpuAlphabet, sizeof(char) * 26); 
	cudaMemcpy(gpuAlphabet, cpuAlphabet, sizeof(char) * 26, cudaMemcpyHostToDevice);

	char * gpuNumbers;
	cudaMalloc( (void**) &gpuNumbers, sizeof(char) * 10); 
	cudaMemcpy(gpuNumbers, cpuNumbers, sizeof(char) * 10, cudaMemcpyHostToDevice);

	char * password;
	cudaMalloc( (void**) &password, sizeof(char) * 26); 
	cudaMemcpy(password, argv[1], sizeof(char) * 26, cudaMemcpyHostToDevice);

	struct timespec start, finish;
	long long int time_elapsed;
	
	//Start monitoring the duration 
	clock_gettime(CLOCK_MONOTONIC, &start);
	
	crack<<< dim3(26,26,1), dim3(10,10,1) >>>( gpuAlphabet, gpuNumbers);
	cudaDeviceSynchronize();

	//End the duration of the program
	clock_gettime(CLOCK_MONOTONIC, &finish);
	
	//Calculate the duration
	time_difference(&start, &finish, &time_elapsed);
	
	//Print the duration taken
	printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed,
	(time_elapsed/1.0e9)); 
	
	return 0;
}


	











