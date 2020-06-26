      program contoco2
      logical ifbswap,if_byte_swap_test,ifbinary

      io=10
      call getconfile('Input .con name:$',ifbinary,io,ierr) ! get filename

      ! Read header + simple check
c     call open_bin_file(ifbswap,nelgti,nelgvi,nv,wdsizi)

      ! Read con and then dump into co2
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
      subroutine getconfile(prompt,ifbinary,io,ierr)
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
         call chcopy(file1(len+1),'.con',4)
         inquire(file=file, exist=ifbinary)
         if(ifbinary) ierr = 0
      endif

      write(6,*) 'reading ', file

      return
      end
cc-----------------------------------------------------------------------
c      subroutine open_bin_file(ifbswap,nelgti,nelgvi,nv,wdsizi)
cc     open file & chk for byteswap & 8byte reals
c
c      logical ifbswap,if_byte_swap_test
c
c      CHARACTER*132 NAME
c      CHARACTER*1  NAM1(132)
c      EQUIVALENCE  (NAME,NAM1)
c
c      integer fnami (33)
c      character*132 fname,re2fle
c      equivalence (fname,fnami)
c
cc      character*80 hdr
c      character*132 hdr
c      character*5 version
c      real*4      test
c
c      character*1 re2(4)
c      character*4 re24
c      equivalence (re2,re24)
c      DATA re24   /'.co2'       /
c
c      common /sess/ session
c      character*80 session
c
c      integer wdsizi
c
c      call izero  (fnami,33)
c
c      len = ltrunc(session,80)
c      call chcopy (nam1,session,80)
c      len = len + 1
c      call chcopy (nam1(len),re2,4)
c      len = len + 3
c      call chcopy (fname,nam1,len)
c
c      ierr=0
c      call byte_open(fname,ierr)
c      if(ierr.ne.0) call exitti
c     $  ('Error opening file in open_bin_file ',ierr)
c      call byte_read(hdr,sizeof(hdr)/4,ierr)
c      if(ierr.ne.0) call exitti
c     $  ('Error reading header in open_bin_file ',ierr)
c
c      read (hdr,*) version,nelgti,nelgvi,nv
c      wdsizi=4
c      if(version.eq.'#v001')wdsizi=8
cc      if(version.eq.'#v002')wdsizi=8
cc      if(version.eq.'#v003')wdsizi=8
c
c      call byte_read(test,1,ierr)
c      if(ierr.ne.0) call exitti
c     $  ('Error reading test number in open_bin_file ',ierr)
c      ifbswap = if_byte_swap_test(test)
c
c      write(*,1)version,nelgti,nelgvi,nv
c    1       format(a5,3i12)
c
c      return
c      end
cc-----------------------------------------------------------------------
      subroutine dmpfile(nelgti,nelgvi,nv)

      common /sess/ session
      character*80 session
      character*80 fname1
      character*80 fname2
      character*1  fnam1(80)
      character*1  fnam2(80)
      equivalence (fnam1,fname1)
      equivalence (fnam2,fname2)

      integer e
      common /arrayi2/ iwrk(1+8)

      character*132 hdr
      character*5   version
      real*4 test
      data   test  / 6.54321 /

      version = '#v001'


      ! Get filenames
      len = ltrunc(session,80)
      call chcopy(fname1,session,80)
      call chcopy(fnam1(len+1),'.con',4)
      call chcopy(fname2,session,80)
      call chcopy(fnam2(len+1),'.co2',4)

      ! Get header
      open (unit=29,file=fname1)
      read(29,1) version,nelgti,nelgvi,nv
    1 format(a5,3i12)
      ! write header
      call byte_open(fname2,ierr)
      call blank(hdr,132)
      write(hdr,1) version,nelgti,nelgvi,nv
      call byte_write(hdr,132/4,ierr)
      call byte_write(test,1,ierr) ! write the endian discriminator

      write(6,*) 'convert into ', fname2
      iprog=1
      do e=1,nelgti
         iwrk(1) = e

         ! Read
         read(29,2)(iwrk(ii),ii=1,nv+1)

c         ! Check
c         ierr=0
c         do ii=1,9
c            if(iwrk(ii).le.0) ierr=1
c         enddo
c         if(iwrk(1).gt.nelgti) ierr=1

         ! Dump
         call byte_write(iwrk,nv+1,ierr)
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
      if(ierr.gt.0) call exitti('closing file',ierr)
      end
