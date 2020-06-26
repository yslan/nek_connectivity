// Second file
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <float.h>
#include <math.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>

#ifndef FNAME_H
#define FNAME_H

/*
   FORTRAN naming convention
     default      cpgs_setup, etc.
     -DUPCASE     CPGS_SETUP, etc.
     -DUNDERSCORE cpgs_setup_, etc.
*/

#ifdef UPCASE
#  define FORTRAN_NAME(low,up) up
#else
#ifdef UNDERSCORE
#  define FORTRAN_NAME(low,up) low##_
#else
#  define FORTRAN_NAME(low,up) low
#endif
#endif

#endif

#define byte2_reverse     FORTRAN_NAME(byte2_reverse,     BYTE2_REVERSE    )
#define byte2_reverse8    FORTRAN_NAME(byte2_reverse8,    BYTE2_REVERSE8   )
#define byte2_open        FORTRAN_NAME(byte2_open,        BYTE2_OPEN       )
#define byte2_close       FORTRAN_NAME(byte2_close,       BYTE2_CLOSE      )
#define byte2_rewind      FORTRAN_NAME(byte2_rewind,      BYTE2_REWIND     )
#define byte2_read        FORTRAN_NAME(byte2_read,        BYTE2_READ       )
#define byte2_write       FORTRAN_NAME(byte2_write,       BYTE2_WRITE      )
#define get2_bytesw_write FORTRAN_NAME(get2_bytesw_write, GET2_BYTESW_WRITE)
#define set2_bytesw_write FORTRAN_NAME(set2_bytesw_write, SET2_BYTESW_WRITE)

#define READ     11
#define WRITE    12
#define MAX_NAME 132

#define SWAP(a,b)       temp=(a); (a)=(b); (b)=temp;

static FILE *fp2=NULL;
static int  flag2=0;
static char name2[MAX_NAME+1];

int bytesw_write2=0;
int bytesw_read2=0;

/*************************************byte.c***********************************/

#ifdef UNDERSCORE
  void exitt_();
#else
  void exitt();
#endif

void byte2_reverse(float *buf, int *nn,int *ierr)
{
  int n;
  char temp, *ptr;

  if (*nn<0)
  {
    printf("byte2_reverse() :: n must be positive\n"); 
    *ierr=1;
    return;
  }
  
  for (ptr=(char *)buf,n=*nn; n--; ptr+=4)
  {
     SWAP(ptr[0],ptr[3])
     SWAP(ptr[1],ptr[2])
  }
  *ierr=0;
}

void byte2_reverse8(float *buf, int *nn,int *ierr)
{
  int n;
  char temp, *ptr;

  if (*nn<0)
  {
    printf("byte2_reverse8() :: n must be positive\n");
    *ierr=1;
    return;
  }
  if(*nn % 2 != 0)
  {
    printf("byte2_reverse8() :: n must be multiple of 2\n");
    *ierr=1;
    return;
  }

  for (ptr=(char *)buf,n=*nn,n=n+2; n-=2; ptr+=8)
  {
     SWAP(ptr[0],ptr[7])
     SWAP(ptr[1],ptr[6])
     SWAP(ptr[2],ptr[5])
     SWAP(ptr[3],ptr[4])
  }
  *ierr=0;
}


void byte2_open(char *n,int *ierr,int nlen)
{
  int  i,len,istat;
  char slash;
  char dirname[MAX_NAME+1];

  if (nlen>MAX_NAME)
  {
    printf("byte2_open() :: invalid string length\n"); 
    *ierr=1;
    return;
  }
  strncpy(name2,n,nlen);
  for (i=nlen-1; i>0; i--) if (name2[i] != ' ') break;
  name2[i+1] = '\0';

  for (i=nlen-1; i>0; i--) if (name2[i] == '/') break;
  if (i>0) {
    strncpy(dirname,name2,i);
    dirname[i] = '\0';
    istat = mkdir(dirname,0755);
  }

  *ierr=0;
}

void byte2_close(int *ierr)
{
  if (!fp2) return;

  if (fclose(fp2))
  {
    printf("byte2_close() :: couldn't fclose file!\n");
    *ierr=1;
    return;
  }

  fp2=NULL;
  *ierr=0;
}

void byte2_rewind()
{
  if (!fp2) return;

  rewind(fp2);
}


void byte2_write(float *buf, int *n,int *ierr)
{
  int flag2s;
  mode_t mode;

  if (*n<0)
  {
    printf("byte2_write() :: n must be positive\n"); 
    *ierr=1;
    return;
  }

  if (!fp2)
  {
    if (!(fp2=fopen(name2,"wb")))
    {
      printf("byte2_write() :: fopen failure!\n"); 
      *ierr=1;
      return;
    }
    flag2=WRITE;
  }

  if (flag2==WRITE)
    {
      if (bytesw_write2 == 1)
        byte2_reverse (buf,n,ierr);
      fwrite(buf,sizeof(float),*n,fp2);
    }
  else
  {
      printf("byte2_write() :: can't fwrite after freading!\n"); 
      *ierr=1;
      return;
  }
  *ierr=0;
}


void byte2_read(float *buf, int *n,int *ierr)
{
  int flag2s;
  mode_t mode;

  if (*n<0)
    {printf("byte2_read() :: n must be positive\n"); *ierr=1; return;}

  if (!fp2)
  {
     if (!(fp2=fopen(name2,"rb")))
     {
        printf("%s\n",name2);
        printf("byte2_read() :: fopen failure2!\n"); 
        *ierr=1;
        return;
     }
     flag2=READ;
  }

  if (flag2==READ)
  {
     if (bytesw_read2 == 1)
        byte2_reverse (buf,n,ierr);
     fread(buf,sizeof(float),*n,fp2);
     if (ferror(fp2))
     {
       printf("ABORT: Error reading %s\n",name2);
       *ierr=1;
       return;
     }
     else if (feof(fp2))
     {
       printf("ABORT: EOF found while reading %s\n",name2);
       *ierr=1;
       return;
     }

  }
  else
  {
     printf("byte2_read() :: can't fread after fwriting!\n"); 
     *ierr=1;
     return;
  }
  *ierr=0;
}

void set2_bytesw_write (int *pa)
{
    if (*pa != 0)
       bytesw_write2 = 1;
    else
       bytesw_write2 = 0;
}

void set2_bytesw_read (int *pa)
{
    if (*pa != 0)
       bytesw_read2 = 1;
    else
       bytesw_read2 = 0;
}

void get2_bytesw_write (int *pa)
{
    *pa = bytesw_write2;
}

void get2_bytesw_read (int *pa)
{
    *pa = bytesw_read2;
}
