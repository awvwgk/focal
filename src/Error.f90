submodule (Focal) Focal_Error
  !! FOCAL: openCL abstraction layer for fortran
  !!  Implementation module for error handling

  !! @note This is an implementation submodule: it contains the code implementing the subroutines defined in the
  !!  corresponding header module file. See header module file (Focal.f90) for interface definitions. @endnote

  use clfortran
  implicit none
  
  contains

  module procedure fclHandleBuildError !(builderrcode,prog,ctx)

    integer :: i
    integer(c_int32_t) :: errcode
    integer(c_size_t), target :: buffLen, int32_ret
    character(len=1,kind=c_char), allocatable, target :: buildLogBuffer(:)

    call fclHandleErrorCode(builderrcode,'fclCompileProgram:clBuildProgram',stopnow=.false.)

    ! Handle compilation error
    if (builderrcode /= CL_SUCCESS) then

      ! Echo kernel from first device

      ! Iterate over context devices 
      do i=1,ctx%platform%numDevice

        write(*,'(A,I3)') ' Build log for context device ',i
        write(*,*) ' (',ctx%platform%devices(i)%name,'):'

        errcode = clGetProgramBuildInfo(prog%cl_program, ctx%platform%cl_device_ids(1), &
          CL_PROGRAM_BUILD_LOG, int(0,c_size_t), C_NULL_PTR, buffLen);

        call fclHandleErrorCode(errcode,'fclCompileProgram:clGetProgramBuildInfo')

        allocate(buildLogBuffer(buffLen))
        buffLen = size(buildLogBuffer,1)

        errcode = clGetProgramBuildInfo(prog%cl_program, ctx%platform%cl_device_ids(1), & 
          CL_PROGRAM_BUILD_LOG, buffLen, c_loc(buildLogBuffer), int32_ret);

        call fclHandleErrorCode(errcode,'fclCompileProgram:clGetProgramBuildInfo')

        write(*,*) buildLogBuffer
        write(*,*)

        deallocate(buildLogBuffer)

      end do

      stop
    end if


  end procedure fclHandleBuildError
  ! ---------------------------------------------------------------------------


  module procedure fclHandleErrorCode !(errcode,descrip,stopnow)

    if (errcode /= CL_SUCCESS) then
      write(*,*) '(!) Fatal openCl error ',errcode,' : ',trim(fclGetErrorString(errcode))
      if (present(descrip)) then
        write(*,*) '      at ',descrip
      end if

      if (present(stopnow)) then
        if (stopnow) then
          stop
        end if
      else
        stop
      end if
    end if

  end procedure fclHandleErrorCode
  ! ---------------------------------------------------------------------------


  module procedure fclGetErrorString !(errcode)

    select case(errcode)
      case (CL_DEVICE_NOT_FOUND)
        errstr = 'CL_DEVICE_NOT_FOUND'

      case (CL_DEVICE_NOT_AVAILABLE)
        errstr = 'CL_DEVICE_NOT_AVAILABLE'

      case (CL_COMPILER_NOT_AVAILABLE)
        errstr = 'CL_COMPILER_NOT_AVAILABLE'

      case (CL_MEM_OBJECT_ALLOCATION_FAILURE)
        errstr = 'CL_MEM_OBJECT_ALLOCATION_FAILURE'

      case (CL_OUT_OF_HOST_MEMORY)
        errstr = 'CL_OUT_OF_HOST_MEMORY'

      case (CL_BUILD_PROGRAM_FAILURE)
        errstr = 'CL_BUILD_PROGRAM_FAILURE'

      case (CL_INVALID_VALUE)
        errstr = 'CL_INVALID_VALUE'

      case (CL_INVALID_PLATFORM)
        errstr = 'CL_INVALID_PLATFORM'

      case (CL_INVALID_DEVICE)
        errstr = 'CL_INVALID_DEVICE'

      case (CL_INVALID_CONTEXT)
        errstr = 'CL_INVALID_CONTEXT'

      case (CL_INVALID_COMMAND_QUEUE)
        errstr = 'CL_INVALID_COMMAND_QUEUE'

      case (CL_INVALID_MEM_OBJECT)
        errstr = 'CL_INVALID_MEM_OBJECT'

      case (CL_INVALID_BINARY)
        errstr = 'CL_INVALID_BINARY'

      case (CL_INVALID_BUILD_OPTIONS)
        errstr = 'CL_INVALID_BUILD_OPTIONS'

      case (CL_INVALID_PROGRAM)
        errstr = 'CL_INVALID_PROGRAM'
        
      case (CL_INVALID_ARG_INDEX)
        errstr = 'CL_INVALID_ARG_INDEX'
        
      case (CL_INVALID_ARG_VALUE)
        errstr = 'CL_INVALID_ARG_VALUE'

      case (CL_INVALID_ARG_SIZE)
        errstr = 'CL_INVALID_ARG_SIZE'

      case (CL_INVALID_OPERATION)
        errstr = 'CL_INVALID_OPERATION'

      case default
        errstr = 'UNKNOWN'

    end select

  end procedure fclGetErrorString
  ! ---------------------------------------------------------------------------


  module procedure fclRuntimeError !(descrip)

    write(*,*) '(!) Fatal runtime error: an incorrect Focal program has been written.'
    if (present(descrip)) then
        write(*,*) '      at ',descrip
      end if
    stop

  end procedure fclRuntimeError
  ! ---------------------------------------------------------------------------


end submodule Focal_Error