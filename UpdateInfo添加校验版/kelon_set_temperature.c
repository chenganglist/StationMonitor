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
	int  fd = open( Dev, O_RDWR );
	if (-1 == fd)
	{
		perror("Can't Open Serial Port");
		return -1;
	}
	else
	{
		return fd;
	}		
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
int Recv_data(int fd,char* total_buff)
{

	char * current_pos = total_buff;
	char recv_buff[1024];
	memset(recv_buff,0,1024);//清空recv_buff
	memset(total_buff,0,1024);//清空recv_buff
    int receive_len = 0;
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
			memcpy(current_pos, recv_buff, recv_len);
			current_pos += recv_len;
			receive_len = receive_len + recv_len;
		}
		else
		{
			break;
		}
	}
	return receive_len;
	
}

char outcommand[24];

int  set_temperature(int temperature)
{
	char tempVal[4];
	sprintf(tempVal,"%04X",(unsigned short)temperature);
	puts(tempVal);
	char SOI = 0x7E;
	char EOI = 0x0D;
	char str[18] = {'3','0', '0','1', '6','0', '4','9', 'A','0','0','6', 
					'8','6',tempVal[0],tempVal[1],tempVal[2],tempVal[3]};
	int i = 0;
	int sum = 0;
	for(;i<18;i++)
	{
		sum = sum + str[i];
		printf("第%d个字符：ASCII码为：%c,16进制为%4X\n",i,str[i],str[i]);
	}
	printf("和为：%04X\n",sum);
    sum = sum&0xFFFF;
    sum = ~sum + 1 ;
    printf("ASCII字节个数：%d  ",i);
    char checksum[4];
    puts("校验码为："); 
	sprintf(checksum, "%04X", (unsigned short)sum);
	puts(checksum);
	for(i=0;i<4;i++)
	{
		printf("校验码第%d个字符：ASCII码为：%c,16进制为%4X\n",i,checksum[i],checksum[i]);
	}
	char command[24] = {SOI,
	         '3','0', '0','1', '6','0', '4','9', 'A','0','0','6', 
             '8','6',tempVal[0],tempVal[1],tempVal[2],tempVal[3],
             checksum[0],checksum[1],checksum[2],checksum[3],
	EOI	
	};	

	for(i=0;i<24;i++)
	{
		outcommand[i] = command[i];
		printf("%02X  ",outcommand[i]);
	}
	
	return 0;
	
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
	int temperature = atoi(argv[1]);
	
	set_temperature(temperature);
	
    //*********发送命令************** 
	int send_res = Send_order(fd,outcommand,24);

	if(send_res==FALSE)
 	{
 		close(fd);
   		return FALSE;
	}

    char total_buff[1024];
	int length = Recv_data(fd,total_buff);//读取串口数据
	printf("接收数据长度为:%d\n",length);
	
	int j;//显示接收到的字符
    FILE *stream;
	stream = fopen("receiveinfo","w+");
	for (j = 0 ; j < length; j++)
	{       
		printf("%02X  ", total_buff[j]);
		fprintf(stream, "%02X", total_buff[j]);	
	}    
	fclose(stream);           
	printf("\n");  

	close(fd);
	return 0;

}
