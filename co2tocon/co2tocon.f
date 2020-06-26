      program co2tocon
      logical ifbswap,if_byte_swap_test,ifbinary

      io=10
      call getco2file('Input .co2 name:$',ifbinary,io,ierr)

      ! Read header + simple check
      call open_bin_file(ifbswap,nelgti,nelgvi,nv,wdsizi)

      ! Read co2 and then dump into con
      call dmpfile(nelgti,nelgvi,nv)

      write(*,*)'Done!'
      end
c-----------------------------------------------------------------------
      subroutine exitti(name,ie)
      character*40 name
      write(6,*) name, ie
      stop
      end
c-----------------------------------------------------------------------
      subroutine exitt(ie)
      write(6,*) 'exit status', ie
      stop
      end
c-----------------------------------------------------------------------
      subroutine err_chk(ierr,name)
      character*40 name
      if(ierr.eq.0) return
      call exitti(name,ierr)
      end
c-----------------------------------------------------------------------
      subroutine blank(s,n)
      character*1 s(1)
      do i=1,n
        s(i)=' '
      enddo
      return
      end
c-----------------------------------------------------------------------
      function ltrunc(s,n)
      character*1 s(1)
      ltrunc = 0
      do j=n,1,-1
         if (s(j).ne.' ') then
            ltrunc = j
            return
         endif
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine chcopy(x,y,n)
      character*1 x(1),y(1)
      do i=1,n
         x(i) = y(i)
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine izero(x,n)
      integer x(1)
      do i=1,n
         x(i) = 0
      enddo
      return
      end
c-----------------------------------------------------------------------
      integer function indx1(s1,s2,l2)
      character*80 s1,s2
C
      n1=80-l2+1
      indx1=0
      if (n1.lt.1) return
C
      do 300 i=1,n1
         i2=i+l2-1
         if (s1(i:i2).eq.s2(1:l2)) then
            indx1=i
            return
         endif
300   continue
c
      return
      end
c-----------------------------------------------------------------------
      logical function if_byte_swap_test(bytetest)
c
      real*4 bytetest,test2
      real*4 test_pattern
      save   test_pattern
c
      test_pattern = 6.54321
      eps          = 0.00020
      etest        = abs(test_pattern-bytetest)
      if_byte_swap_test = .true.
      if (etest.le.eps) if_byte_swap_test = .false.

      ierr  = 0
      test2 = bytetest
      call byte_reverse(test2,1,ierr)
      if(ierr.ne.0) call exitti
     $  ('Error with byte_reverse in if_byte_swap_test ',ierr)
c     write(6,*) 'Byte swap:',if_byte_swap_test,bytetest,test2

      return
      end
c-----------------------------------------------------------------------
      subroutine getco2file(prompt,ifbinary,io,ierr)
c
      character*1 prompt(1)
      logical ifbinary
c
      common /sess/ session
      character*80 session

      character*80 file
      character*1  file1(80)
      equivalence (file1,file)

      ierr = 0
      ifbinary = .false.

c     Get file name
      len = indx1(prompt,'$',1) - 1
      write(6,81) (prompt(k),k=1,len)
   81 format(80a1)
      call blank(session,80)
      read(5,80) session
   80 format(a80)

      if (session.eq.'-1') then
         io = -1
         ierr = 1
         return
      else
         call chcopy(file,session,80)
         len = ltrunc(file,80)
         call chcopy(file1(len+1),'.co2',4)
         inquire(file=file, exist=ifbinary)
         if(ifbinary) ierr = 0
      endif

      write(6,*) 'reading ', file

      return
      end
c-----------------------------------------------------------------------
      subroutine open_bin_file(ifbswap,nelgti,nelgvi,nv,wdsizi)
c     open file & chk for byteswap & 8byte reals

      logical ifbswap,if_byte_swap_test

      CHARACTER*132 NAME
      CHARACTER*1  NAM1(132)
      EQUIVALENCE  (NAME,NAM1)

      integer fnami (33)
      character*132 fname,re2fle
      equivalence (fname,fnami)

c      character*80 hdr
      character*132 hdr
      character*5 version
      real*4      test

      character*1 re2(4)
      character*4 re24
      equivalence (re2,re24)
      DATA re24   /'.co2'       /

      common /sess/ session
      character*80 session

      integer wdsizi

      call izero  (fnami,33)

      len = ltrunc(session,80)
      call chcopy (nam1,session,80)
      len = len + 1
      call chcopy (nam1(len),re2,4)
      len = len + 3
      call chcopy (fname,nam1,len)

      ierr=0
      call byte_open(fname,ierr)
      if(ierr.ne.0) call exitti
     $  ('Error opening file in open_bin_file ',ierr)
      call byte_read(hdr,sizeof(hdr)/4,ierr)
      if(ierr.ne.0) call exitti
     $  ('Error reading header in open_bin_file ',ierr)

      read (hdr,*) version,nelgti,nelgvi,nv
      wdsizi=4
      if(version.eq.'#v001')wdsizi=8
c      if(version.eq.'#v002')wdsizi=8
c      if(version.eq.'#v003')wdsizi=8

      call byte_read(test,1,ierr)
      if(ierr.ne.0) call exitti
     $  ('Error reading test number in open_bin_file ',ierr)
      ifbswap = if_byte_swap_test(test)

      write(*,1)version,nelgti,nelgvi,nv
    1       format(a5,3i12)

      return
      end
c-----------------------------------------------------------------------
      subroutine dmpfile(nelgti,nelgvi,nv)

      common /sess/ session
      character*80 session
      character*80 fname
      character*1  fnam1(80)
      equivalence (fnam1,fname)

      integer e
      common /arrayi2/ iwrk(1+8)

      character*132 hdr
      character*5   version
      real*4 test
      data   test  / 6.54321 /

      version = '#v001'

      len = ltrunc(session,80)
      call chcopy(fname,session,80)
      call chcopy(fnam1(len+1),'.con',4)

      open (unit=29,file=fname)
      write(29,1) version,nelgti,nelgvi,nv
    1 format(a5,3i12)

      write(6,*) 'convert into ', fname
      iprog=1
      do e=1,nelgti
         ! Read
         call byte_read(iwrk,nv+1,ierr)

c         ! Check
c         ierr=0
c         do ii=1,9
c            if(iwrk(ii).le.0) ierr=1
c         enddo
c         if(iwrk(1).gt.nelgti) ierr=1

         ! Dump
         write(29,2) (iwrk(ii), ii=1,nv+1)
         if(ierr.gt.0) call exitti('invalid id',ierr)

         ! print progress
         if (e*10.ge.iprog*nelgti) then
            write(*,3)'  progress = ',iprog*10,'%',e,nelgti
            iprog=iprog+1
         endif
      enddo
    2 format(9i12)
    3 format(a13,i3a1,2i12)

      call byte_close(ierr)
      close(unit=29)
      end
