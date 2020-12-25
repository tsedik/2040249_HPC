#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>

#include "lodepng.h"

/*
compile with c++ lodepng file:
nvcc -o 2040249_Task3_B 2040249_Task3_B.cu lodepng.cpp 

to run:
./2040249_Task3_B_Task3_B

Tsering Dikey Lama, University of Wolverhampton, Herald College Kathmandu
*/



__device__ unsigned int d_width;

__device__ unsigned char getRed(unsigned char *image, unsigned int row, unsigned int col){
	unsigned int i = (row * d_width * 4) + (col * 4);
	return image[i];
  }
  
  __device__ unsigned char getGreen(unsigned char *image, unsigned int row, unsigned int col){
	unsigned int i = (row * d_width * 4) + (col * 4) +1;
	return image[i];
  }
  
  __device__ unsigned char getBlue(unsigned char *image, unsigned int row, unsigned int col){
	unsigned int i = (row * d_width * 4) + (col * 4) +2;
	return image[i];
  }
  
  __device__ unsigned char getAlpha(unsigned char *image, unsigned int row, unsigned int col){
	unsigned int i = (row * d_width * 4) + (col * 4) +3;
	return image[i];
  }
  
  __device__ void setRed(unsigned char *image, unsigned int row, unsigned int col, unsigned char red){
	unsigned int i = (row * d_width * 4) + (col * 4);
	image[i] = red;
  }
  
  __device__ void setGreen(unsigned char *image, unsigned int row, unsigned int col, unsigned char green){
	unsigned int i = (row * d_width * 4) + (col * 4) +1;
	image[i] = green;
  }
  
  __device__ void setBlue(unsigned char *image, unsigned int row, unsigned int col, unsigned char blue){
	unsigned int i = (row * d_width * 4) + (col * 4) +2;
	image[i] = blue;
  }
  
  __device__ void setAlpha(unsigned char *image, unsigned int row, unsigned int col, unsigned char alpha){
	unsigned int i = (row * d_width * 4) + (col * 4) +3;
	image[i] = alpha;
  }
  
__global__ void square(unsigned char * gpu_imageOutput, unsigned char * gpu_imageInput, unsigned int *width){
	
	unsigned redTL, redTC, redTR;
	unsigned redL, redC, redR;
	unsigned redBL, redBC, redBR;
	unsigned newRed;

	unsigned greenTL, greenTC, greenTR;
	unsigned greenL, greenC, greenR;
	unsigned greenBL, greenBC, greenBR;
	unsigned newGreen;

	unsigned blueTL, blueTC, blueTR;
	unsigned blueL, blueC, blueR;
	unsigned blueBL, blueBC, blueBR;
	unsigned newBlue;

	int row = blockIdx.x+1;
	int col = threadIdx.x+1;

	d_width = *width;
	
	setGreen(gpu_imageOutput, row, col, getGreen(gpu_imageInput, row, col));
	setBlue(gpu_imageOutput, row, col, getBlue(gpu_imageInput, row, col));
	setAlpha(gpu_imageOutput, row, col, 255);

	redTL = getRed(gpu_imageInput, row - 1, col - 1);
	redTC = getRed(gpu_imageInput, row - 1, col);
	redTR = getRed(gpu_imageInput, row - 1, col + 1);

	redL = getRed(gpu_imageInput, row, col - 1);
	redC = getRed(gpu_imageInput, row, col);
	redR = getRed(gpu_imageInput, row, col + 1);

	redBL = getRed(gpu_imageInput, row + 1, col - 1);
	redBC = getRed(gpu_imageInput, row + 1, col);
	redBR = getRed(gpu_imageInput, row + 1, col + 1);
	
	//Bluring red color value
	newRed = (redTL+redTC+redTR+redL+redC+redR+redBL+redBC+redBR)/9;  

	setRed(gpu_imageOutput, row, col, newRed);

	greenTL = getGreen(gpu_imageInput, row - 1, col - 1);
	greenTC = getGreen(gpu_imageInput, row - 1, col);
	greenTR = getGreen(gpu_imageInput, row - 1, col + 1);

	greenL = getGreen(gpu_imageInput, row, col - 1);
	greenC = getGreen(gpu_imageInput, row, col);
	greenR = getGreen(gpu_imageInput, row, col + 1);

	greenBL = getGreen(gpu_imageInput, row + 1, col - 1);
	greenBC = getGreen(gpu_imageInput, row + 1, col);
	greenBR = getGreen(gpu_imageInput, row + 1, col + 1);

	//Bluring green color value
	newGreen = (greenTL+greenTC+greenTR+greenL+greenC+greenR+greenBL+greenBC+greenBR)/9; 

	setGreen(gpu_imageOutput, row, col, newGreen);

	blueTL = getBlue(gpu_imageInput, row - 1, col - 1);
	blueTC = getBlue(gpu_imageInput, row - 1, col);
	blueTR = getBlue(gpu_imageInput, row - 1, col + 1);

	blueL = getBlue(gpu_imageInput, row, col - 1);
	blueC = getBlue(gpu_imageInput, row, col);
	blueR = getBlue(gpu_imageInput, row, col + 1);

	blueBL = getBlue(gpu_imageInput, row + 1, col - 1);
	blueBC = getBlue(gpu_imageInput, row + 1, col);
	blueBR = getBlue(gpu_imageInput, row + 1, col + 1);

	//Bluring blue color value
	newBlue = (blueTL+blueTC+blueTR+blueL+blueC+blueR+blueBL+blueBC+blueBR)/9; 

	setBlue(gpu_imageOutput, row, col, newBlue);
}

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

int main(int argc, char **argv){

	struct timespec start, finish;
	long long int time_elapsed;

	unsigned char *image;
	unsigned int width;
	unsigned int height;
	const char* filename = "hck.png";
	const char* newFileName = "filtered.png";
	
	clock_gettime(CLOCK_MONOTONIC, &start);//Start monitoring the duration 

	//Decoding Image
	lodepng_decode32_file(&image, &width, &height, filename);

	const int ARRAY_SIZE = width*height*4;
	const int ARRAY_BYTES = ARRAY_SIZE * sizeof(unsigned char);

	unsigned char host_imageInput[ARRAY_SIZE * 4];
	unsigned char host_imageOutput[ARRAY_SIZE * 4];

	for (int i = 0; i < ARRAY_SIZE; i++) {
		host_imageInput[i] = image[i];
	}

	// declare GPU memory pointers
	unsigned char * d_in;
	unsigned char * d_out;

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES);
	cudaMalloc((void**) &d_out, ARRAY_BYTES);

	cudaMemcpy(d_in, host_imageInput, ARRAY_BYTES, cudaMemcpyHostToDevice);

	//Declaring gpuImageWidth and setting the value 
	unsigned int* d_wid; 
	cudaMalloc( (void**) &d_wid, sizeof(int));
	cudaMemcpy(d_wid, &width, sizeof(int), cudaMemcpyHostToDevice);

	// launch the kernel
	square<<<height-1, width-1>>>(d_out, d_in, d_wid);

	// copy back the result array to the CPU
	cudaMemcpy(host_imageOutput, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);
	cudaDeviceSynchronize();

	//Encoding Image
	lodepng_encode32_file(newFileName, host_imageOutput, width, height);

	cudaFree(d_in);
	cudaFree(d_out);
	clock_gettime(CLOCK_MONOTONIC, &finish); //End the duration of the program
	
	//Calculate difference
	time_difference(&start, &finish, &time_elapsed);
	

	printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, 
         (time_elapsed/1.0e9)); 

	return 0;
}




