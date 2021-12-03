! compile with gfortran

program day03
    implicit none
    integer, parameter :: NUMLEN = 12 ! number of bits
    integer, parameter :: ARRAYLEN = 1000 ! number of lines
    integer :: i, linenum, mostfreq = 0, leastfreq = 0, oxycount, co2count, oxy = 0, co2 = 0
    character*16 buffer ! should be >= NUMLEN
    integer,   dimension(NUMLEN) :: freqs = (/ (0, i = 1, NUMLEN) /)
    character, dimension(ARRAYLEN, NUMLEN) :: numarray
    logical,   dimension(ARRAYLEN) :: validoxy = (/ (.true., i = 1, ARRAYLEN) /)
    logical,   dimension(ARRAYLEN) :: validco2 = (/ (.true., i = 1, ARRAYLEN) /)

    open(unit = 11, file = 'input03.txt')

    ! Part 1
    linenum = 1
    do
        read(11, *, end = 1) buffer
        do i = 1, NUMLEN
            if (buffer(i:i) == '1') then
                freqs(i) = freqs(i) + 1
            end if
            numarray(linenum, i) = buffer(i:i) ! for part 2
        end do
        linenum = linenum + 1
    end do
    !1 rewind(11)
    1 continue

    ! convert freqs to appropriate binary number
    do i = 1, NUMLEN
        if (freqs(i) > (ARRAYLEN / 2)) then
            mostfreq  = ior( mostfreq, ishft(1, NUMLEN-i))
        else
            leastfreq = ior(leastfreq, ishft(1, NUMLEN-i))
        end if
    end do

    print *, (mostfreq * leastfreq)

    ! Part 2
    do i = 1, NUMLEN
        ! check if only one number remains for co2 (not needed for oxy)
        co2count = 0
        do linenum = 1, ARRAYLEN
            if (validco2(linenum)) then
                if (co2count == 0) then
                    co2 = extract(numarray, linenum)
                end if
                co2count = co2count + 1
            end if
        end do
        ! determine most common digit in this slot
        oxycount = 0
        co2count = 0
        do linenum = 1, ARRAYLEN
            select case (numarray(linenum, i))
            case ('0')
                if (validoxy(linenum)) then
                    oxycount = oxycount - 1
                end if
                if (validco2(linenum)) then
                    co2count = co2count - 1
                end if
            case ('1')
                if (validoxy(linenum)) then
                    oxycount = oxycount + 1
                end if
                if (validco2(linenum)) then
                    co2count = co2count + 1
                end if
            end select
        end do
        ! cross out invalid numbers
        do linenum = 1, ARRAYLEN
            select case (numarray(linenum, i))
            case ('0')
                if (oxycount >= 0) then
                    validoxy(linenum) = .false.
                end if
                if (co2count < 0) then
                    validco2(linenum) = .false.
                end if
            case ('1')
                if (oxycount < 0) then
                    validoxy(linenum) = .false.
                end if
                if (co2count >= 0) then
                    validco2(linenum) = .false.
                end if
            end select
        end do
    end do
    ! get valid oxy
    do linenum = 1, ARRAYLEN
        if (validoxy(linenum)) then
            oxy = extract(numarray, linenum)
            goto 3
        end if
    end do
    3 continue

    print *, (oxy * co2)

    contains
        function extract(array, row)
            character, dimension(ARRAYLEN, NUMLEN), intent (in) :: array
            integer, intent (in) :: row
            integer :: val, i, extract
            extract = 0
            do i = 1, NUMLEN
                if (array(row, i) == '1') then
                    extract = ior(extract, ishft(1, NUMLEN-i))
                end if
            end do
            return
        end function

end program day03

! Despite some unusual conventions and syntax (rewind, goto, dimension)
! FORTRAN feels surprisingly modern. The standards committees must have
! worked very hard to ensure this is the case, but another contributor to
! this feeling is probably that FORTRAN inspired so many languages that
! I've already learned FORTRAN's way of doing things via its descendants.
