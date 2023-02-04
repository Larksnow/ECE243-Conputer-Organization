/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// Begin part3.c code for Lab 7
void draw();
void clear_screen();
void swap(int* x, int* y);
void draw_line(int x0,int y0,int x1,int y1, short int line_color);
void draw_box(int x, int y, int color);
void wait_for_vsync();
void plot_pixel(int x, int y, short int line_color);
int array[8][5];

volatile int pixel_buffer_start; // global variable

int main(void)
{
	int i;
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	
	for (i=0;i<8;i++){
		array[i][0] = rand()%RESOLUTION_X;
		array[i][1] = rand()%RESOLUTION_Y;
		array[i][2] = (rand()%2)*2-1;
		array[i][3] = (rand()%2)*2-1;
		array[i][4] = rand()%65536;
	}
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
		clear_screen();
		draw(); //draw boxes and lines for next time
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}
void draw(){
//erase contents of the backbuffer
	int i;
	for(i=0; i<8; i++){
		if(i!=7){
		draw_box(array[i][0],array[i][1],array[i][4]);
		draw_line(array[i][0],array[i][1],array[i+1][0], array[i+1][1],array[i][4]);
		}
		if(i==7){
		draw_line(array[7][0],array[7][1],array[0][0], array[0][1],array[7][4]);
		}
		if (array[i][0]<=0 || array [i][0]>=RESOLUTION_X){
		    array[i][2]=-array[i][2];
		}
		if (array[i][1]<=0 || array [i][1]>=RESOLUTION_Y){
		    array[i][3]=-array[i][3];
		}
		array[i][0]+=array[i][2];
		array[i][1]+=array[i][3];
	}	
}

void clear_screen(){
int x;
int y;
for (y = 0; y<RESOLUTION_Y;y++){
	for (x=0;x<RESOLUTION_X;x++){
	plot_pixel(x,y,0x0000);
}
}
}

void swap(int* x, int* y){
    int temp;
    temp = *x;
    *x = *y;
    *y = temp;
}

void draw_line(int x0,int y0,int x1,int y1, short int line_color){
	bool is_steep = abs(y1-y0)>abs(x1-x0);
	if (is_steep){
		swap(&x0,&y0);
		swap(&x1,&y1);
	}
	if (x0>x1){
		swap(&x0,&x1);
		swap(&y0,&y1);
	}
	int deltax = x1-x0;
	int deltay = abs(y1-y0);
	int error = -(deltax/2);
	int y = y0;
	int y_step;
	if (y0<y1){
   		y_step = 1;
	}else{
  		y_step = -1;
	}
	int x;
	for (x = x0; x<=x1; x++){
   		if (is_steep){
    	plot_pixel(y,x,line_color);
   	}else{
       plot_pixel(x,y,line_color);
   	}
	error = error+deltay;

   	if (error>0){
       y = y+y_step;
       error = error-deltax;
   	}
}
}
void draw_box(int x, int y, int color){
    int i;
    int j;
    for (i=0; i<2; i++){
        for (j=0;j<2;j++){
            plot_pixel(x+i,y+j,color);
        }
    }
}




void wait_for_vsync(){
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	register int status;
	*pixel_ctrl_ptr=1;
	status = *(pixel_ctrl_ptr+3);
	while((status &0x01)!=0){
		status = *(pixel_ctrl_ptr+3);
	}
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

// code for subroutines (not shown)
