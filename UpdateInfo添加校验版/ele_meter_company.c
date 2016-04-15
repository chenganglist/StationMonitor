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
#include 	 <ctype.h>

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
		return(FALSE);
	}
	options.c_cflag &= ~CSIZE;
	options.c_lflag  &= ~(ICANON | ECHO | ECHOE | ISIG);  /*Input*/
	options.c_oflag  &= ~OPOST;   /*Output*/
	
	//关闭软件流控制 
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
			return (FALSE);
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
			return (FALSE);
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
			return (FALSE);
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
		return (FALSE);
	}
	return (TRUE);
}




//打开串口函数
int OpenDev(char *Dev)
{
	int     fd = open( Dev, O_RDWR );
	//| O_NOCTTY | O_NDELAY
	if (-1 == fd)
	{
		perror("Can't Open Serial Port");
		return -1;
	}
	else
		return fd;
}




//发送命令
int Send_order(int fd,char* order,int length)
{
	int len;

	len=write(fd,order,length);
	if (len == length )
	{
		printf("\nsend_order successful!\n");
		return TRUE;
	}     
	else   
	{
		tcflush(fd,TCOFLUSH);
		printf("send_order failed!\n");
		return FALSE;
	}
}

//读取数据函数
int Recv_data(int fd,char* total_buff,int length)
{

	char * current_pos = total_buff;
	char recv_buff[1024];
	memset(recv_buff,0,1024);//清空recv_buff
	memset(total_buff,0,1024);//清空recv_buff
   
	while (1) //循环读取数据
	{
		fd_set rd;
		struct timeval time;
		FD_ZERO(&rd);// 清空串口接收端口集
		FD_SET(fd,&rd);// 设置串口接收端口集
		time.tv_sec = 2;
		time.tv_usec = 0;

		if(select(fd+1,&rd,NULL,NULL,&time)>0)// 检测串口是否有读写动作
		{
			int recv_len = read(fd,(void *)recv_buff,1024);
                        //printf("recv_len: %d\n", recv_len);
			

		/*
	if(recv_len < 0)
				return FALSE;*/
			

			memcpy(current_pos, recv_buff, recv_len);
			current_pos += recv_len;

			if(current_pos - total_buff >= length )
			{
				printf("接收数据成功！\n");
                 return TRUE;
			} 
			
		}else{
			
			printf("接收数据不成功！\n");
			return FALSE;
			
		}
	}
}

int main(int argc,char* argv[])
{
	
	if(argc != 3)
	{
		printf("缺少参数：error!\n");
		exit(0);
	}
	 
 	
//*********打开串口并设置波特率*********	
	
	char *dev  = (char*)argv[2]; //串口

	int fd = OpenDev(dev);           //打开串口函数
    if(fd<0)
    {
    	close(fd);
        return FALSE;
    }

	int set_res=set_speed(fd,9600);          //设置串口

    if(set_res==FALSE)
    {
    	close(fd);
       return FALSE;
    }

	if (set_Parity(fd,8,1,'N') == FALSE)
	{
		   close(fd);
           return FALSE;
	}

	//***********从文件中读出指令*************** 

	char order1[8]={0x01,0x03,0x00,0x01,0x00,0x01,0xd5,0xca};
	char order2[8]={0x01,0x03,0x03,0x00,0x00,0x01,0x84,0x4e};
	char order3[18]={0x7E,0x32,0x30,0x30,0x31,0x39,0x30,0x38,0x41,
	0x30,0x30,0x30,0x30,0x46,0x44,0x39,0x41,0x0D};
	char order4[8]={0x01,0x03,0x06,0x06,0x00,0x01,0x84,0x82};
	//char order4[8]={0x01,0x04,0x00,0x04,0x00,0x01,0x70,0x0b};
    
    int result =0;
    int flag = atoi(argv[1]);
    int send_res;
    int recv_length = 7;
   	char total_buff[1024];
    if(flag ==1)
	{
  		send_res=Send_order(fd,order1,8);
		Recv_data(fd,total_buff,recv_length);//读取串口数据
		if(total_buff[2]==0x2 & total_buff[3]==0x0 & total_buff[4]==0x1)
		{
			
			result =flag;
			
		}
    }
    if(flag ==2)
	{
  		send_res=Send_order(fd,order2,8);
	    Recv_data(fd,total_buff,recv_length);//读取串口数据
    	if(total_buff[2]==0x2 & total_buff[3]==0x0 & total_buff[4]==0x1)
		{
			
			result =flag;
			
		}
    }
    if(flag ==3)
	{
  		send_res=Send_order(fd,order3,18);
		Recv_data(fd,total_buff,recv_length);//读取串口数据
		if(total_buff[0]== 0x7E )
		{
			result =flag;
		}
    }
	if(flag ==4)
	{
  		send_res=Send_order(fd,order4,8);
		Recv_data(fd,total_buff,recv_length);//读取串口数据
		if(total_buff[2]==0x2 & total_buff[4]==0x1 )
		{
			result =flag;
		}
    }
    
    //*********发送命令************** 

	if(send_res==FALSE)
 	{
		close(fd);
		return FALSE;
	}

  
	
	int j;
	for (j = 0 ; j < recv_length; j++)
	{       
		printf("%02X  ", (unsigned char)total_buff[j]);
	}            

	printf("\n");
		
	close(fd);
	return result;

}
