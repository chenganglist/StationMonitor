/*
   ============================================================================
Name        : sxg.c
Author      : dbs
Version     :
Copyright   : Your copyright notice
Description : Hello World in C, Ansi-style
============================================================================
 */
#include     <stdio.h>      /*标准输入输出定义*/
#include     <stdlib.h>     /*标准函数库定义*/
#include     <unistd.h>     /*Unix 标准函数定义*/
#include     <sys/types.h>
#include     <sys/stat.h>
#include     <fcntl.h>      /*文件控制定义*/
#include     <termios.h>    /*PPSIX 终端控制定义*/
#include     <errno.h>      /*错误号定义*/
#include     <string.h>
#include     <pthread.h>

#define FALSE  -1
#define TRUE   0

/**
 *@brief  设置串口通信速率
 *@param  fd     类型 int  打开串口的文件句柄
 *@param  speed  类型 int  串口速度
 *@return  void
 **/

//设置串口通信速率
int speed_arr[] = { B38400, B19200, B9600, B4800, B2400, B1200, B300,
	B38400, B19200, B9600, B4800, B2400, B1200, B300, };


int name_arr[] = {38400,  19200,  9600,  4800,  2400,  1200,  300, 38400,
	19200,  9600, 4800, 2400, 1200,  300, };


int set_speed(int fd, int speed)
{
	int   i;
	int   status;
	struct termios   Opt;
	tcgetattr(fd, &Opt);

	for ( i= 0;  i < sizeof(speed_arr) / sizeof(int);  i++)
	{
		if  (speed == name_arr[i])
		{
			tcflush(fd, TCIOFLUSH);
			cfsetispeed(&Opt, speed_arr[i]);
			cfsetospeed(&Opt, speed_arr[i]);
			status = tcsetattr(fd, TCSANOW, &Opt);
			if  (status != 0)
			{
				perror("tcsetattr fd");
				return FALSE;
			}
			tcflush(fd,TCIOFLUSH);
		}
	}

	return TRUE;
}

/**
 *@brief   设置串口数据位，停止位和效验位
 *@param  fd     类型  int  打开的串口文件句柄
 *@param  databits 类型  int 数据位   取值 为 7 或者8
 *@param  stopbits 类型  int 停止位   取值为 1 或者2
 *@param  parity  类型  int  效验类型 取值为N,E,O,,S
 **/

//设置串口数据位，停止位和效验位
int set_Parity(int fd,int databits,int stopbits,int parity)
{
	struct termios options;
	if  ( tcgetattr( fd,&options)  !=  0)
	{
		perror("SetupSerial 1");
		return  FALSE;
	}
	options.c_cflag &= ~CSIZE;
	options.c_lflag  &= ~(ICANON | ECHO | ECHOE | ISIG);  /*Input*/
	options.c_oflag  &= ~OPOST;   /*Output*/
        
        options.c_cflag &= ~CRTSCTS;
        options.c_iflag &= ~(IXON | IXOFF | IXANY);

	switch (databits) //设置数据位数
	{
		case 7:
			options.c_cflag |= CS7;
			break;
		case 8:
			options.c_cflag |= CS8;
			break;
		default:
			fprintf(stderr,"Unsupported data size/n");
			return  FALSE;
	}

	switch (parity)     //设置波特率
	{
		case 'n':
		case 'N':
			options.c_cflag &= ~PARENB;   /* Clear parity enable */
			options.c_iflag &= ~INPCK;     /* Enable parity checking */
			break;
		case 'o':
		case 'O':
			options.c_cflag |= (PARODD | PARENB); /* 设置为奇效验*/
			options.c_iflag |= INPCK;             /* Disnable parity checking */
			break;
		case 'e':
		case 'E':
			options.c_cflag |= PARENB;     /* Enable parity */
			options.c_cflag &= ~PARODD;   /* 转换为偶效验*/
			options.c_iflag |= INPCK;    /* Disnable parity checking */
			break;
		case 'S':
		case 's':  /*as no parity*/
			options.c_cflag &= ~PARENB;
			options.c_cflag &= ~CSTOPB;break;
		default:
			fprintf(stderr,"Unsupported parity/n");
			return  FALSE;
	}

	switch (stopbits)//设置停止位
	{
		case 1:
			options.c_cflag &= ~CSTOPB;
			break;
		case 2:
			options.c_cflag |= CSTOPB;
			break;
		default:
			fprintf(stderr,"Unsupported stop bits/n");
			return  FALSE;
	}

	/* Set input parity option */
	//设置超时15
	if (parity != 'n')
		options.c_iflag |= INPCK;
	tcflush(fd,TCIFLUSH);
	options.c_cc[VTIME] = 1; //设置超时15 seconds
	options.c_cc[VMIN] = 1; // 设置数据读取的最少位

	if (tcsetattr(fd,TCSANOW,&options) != 0)
	{
		perror("SetupSerial 3");
		return  FALSE;
	}
	return  TRUE;
}




//打开串口函数
int OpenDev(char *Dev)
{
	int fd = open( Dev, O_RDWR );
	if (-1 == fd)
	{
		perror("Can't Open Serial Port");
		return -1;
	}
	else
		return fd;
}



//读取数据函数
void Recv_data(int fd,char* total_buff)
{

	char * current_pos = total_buff;
	char recv_buff[512];
	memset(recv_buff,0,512);//清空recv_buff
	memset(total_buff,0,1024);//清空recv_buff
        
	fd_set rd;
	struct timeval time;
	FD_ZERO(&rd);
	FD_SET(fd,&rd);
	time.tv_sec = 1;
	time.tv_usec = 0;

	while (1) //循环读取数据
	{

		if( select(fd+1,&rd,NULL,NULL,&time) > 0 )
		{
			int recv_len = read(fd,(void *)recv_buff,512);
			memcpy(current_pos, recv_buff, recv_len);
			current_pos = current_pos + recv_len;    
		}
		else
		{ 
			break;                
		}
	}

}


int Recive_Validate(unsigned char* s) 
{
    unsigned char CS=0x00;
    unsigned char i=0,length=0;
    if(*s!=0xfe||*(s+1)!=0xfe)
        return 0;
    
    if(*(s+2)!=0x68) 
	    return 0;
        
    CS=CS+0x68; 

    for(i=0;i<6;i++)  
      CS=CS+(*(s+3+i));

	
    if(*(s+9)!=0x68)
        return 0; 

    CS=CS+0x68;
	
    CS=CS+(*(s+10));
	
    length=(*(s+11));
	
    CS=CS+length;
    
    for(i=0;i<length;i++) 
      CS=CS+(*(s+i+12)); 
	
    if(CS!=(*(s+length+12)))    
        return 0;
		
    if((*(s+length+13))!=0x16)
         return 0;

	 
    return 1;
}



int main(int argc,char* argv[])
{
	if(argc != 2)
	{
		printf("error!\n");
		exit(0);
	}
	char *dev  = (char*)argv[1]; //串口
	int fd = OpenDev(dev);           //打开串口函数
	if( fd < 0 )
    {
        return FALSE;
    }

	int set_res=set_speed(fd,9600);          //设置串口

	if(set_res == FALSE)
    {
       return FALSE;
    }

	if (set_Parity(fd,8,1,'N') == FALSE)
	{
           return FALSE;
	}
    
	char order[16]={0xfe,0xfe,0x68,0xa0,0xa0,0xa0,0xa0,0xa0,0xa0,
             0x68,0x01,0x02,0xaa,0xaa,0xe7,0x16};

	char total_buff[1024];
       
	while(1)
	{
			int len;
 			tcflush(fd,TCIOFLUSH);
			//puts("writed");
			len=write(fd,order,16);
			if(len!=16)
			{
				continue;
			}             
                       
			Recv_data(fd,total_buff);//读取串口数据
			
			if(Recive_Validate(total_buff)==0)
			{
				printf("Failed");
				return 1;
			}				

			int length;//显示接收到的字符
			for (length = 0 ; length < 37; length++)
			{       
				//here need to be change according situation
				printf("%02X", (unsigned char)total_buff[length]);
			}               
			printf("\n");
			break;
	}

	close(fd);
	return 0;

}
