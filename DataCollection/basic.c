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
			//printf("%d\n",receive_len);
		}
		else
		{
			break;
		}
	}
	return receive_len;
	
}


//十六进制字符串转10进制int 
int HexNumberToInt (char* num16,int len) 
{
    unsigned long cocnvertfactor = 1,num10 = 0;
	int j; 
	                                           
    for (j = 0;j < len;j++) num16[j] = toupper(num16[j]);                // 小写字母转换成大写，其他字符不变
	
	for (j = len - 1;j >= 0;j--) 
	{                                       // 开始转换
       if (isalpha(num16[j])) num10 = num10 + cocnvertfactor*(num16[j] - 'A' + 10);
	   else num10 = num10 + cocnvertfactor*(num16[j] - '0');
	   cocnvertfactor = 16*cocnvertfactor;
 	}
	
	return num10;	
}

//字符串分割。输入char数组指针，输出int数组的命令 
int splitStr(char *str,int len,int command_sub[]){
		
    char *p = NULL;
	p = strtok(str, " ");
    int i =0;
    while(p)
    {
    	command_sub[i] = HexNumberToInt(p,2);

        p = strtok(NULL, " ");  
		i++; 	
    }
  
	return 0;
}	

//读文件，按照行读文件 
int readFile(char *fileName,char *str,int line_number,int Max_Line_len ){
	
	FILE *fp;

	if((fp=fopen(fileName,"r"))== NULL)
	{
		printf("不能打开文件");
		return 0;
	}
	
	printf("读取的文件内容如下：\n");

	int i;
	for(i=0;i<(line_number-1);i++) //跳过指定行前面的所有行 
	{
		fgets(str,Max_Line_len,fp);
	}
	fgets(str,Max_Line_len,fp); //读取指定行字符 
	
	printf("str:%s",str); 
	printf("\n");
	fclose(fp);
	
	return 1;
}




int main(int argc,char* argv[])
{
	
	if(argc != 6)
	{
		printf("参数不足：error!\n");
		exit(0);
	}
	 
 	
//*********打开串口并设置波特率*********	
	
	char *dev  = (char*)argv[5]; //串口

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
	
	char* command_file = argv[1];
	int line_index = atoi(argv[2]);
	int Max_Line_len =atoi(argv[3]) ;
	int command_len  = atoi(argv[4]);	

 	char str[1024];
 	readFile(command_file,str,line_index,Max_Line_len);
 	int command_sub[16]={0};
 	splitStr(str,command_len,command_sub);
 	
 	char order[16]={0};
 	int i;
 	printf("读文件获取到的char数组中的command为：");
	for(i=0;i<command_len;i++)
	{
 	 	order[i] = (char)command_sub[i];
    	printf("%02X  ",(unsigned char)order[i]);
    }
    printf("\n");
    
    
    //*********发送命令************** 
    
    
	int send_res = Send_order(fd,order,command_len);

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
		printf("%02X  ", (unsigned char)total_buff[j]);
		fprintf(stream, "%02X", (unsigned char)total_buff[j]);	
	}    
	fclose(stream);           
	printf("\n");  

	close(fd);
	return 0;

}
