//
//  Writer.h
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#ifndef WriteData_h
#define WriteData_h

#import "../substrate/substrate.h"
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <dlfcn.h>

typedef void (*mshookmemory_ptr_t)(void *target, const void *data, size_t size);

/*
This Function checks if the Application has ASLR enabled.
It gets the mach_header of the Image at Index 0.
It then checks for the MH_PIE flag. If it is there, it returns TRUE.
Parameters: nil
Return: Wether it has ASLR or not
*/

bool hasASLR()
{

    const struct mach_header *mach;

    mach = _dyld_get_image_header(0);

    if (mach->flags & MH_PIE)
    {

        //has aslr enabled
        return true;
    }
    else
    {

        //has aslr disabled
        return false;
    }
}

/*
This Function gets the vmaddr slide of the Image at Index 0.
Parameters: nil
Return: the vmaddr slide
*/

uintptr_t get_slide()
{
    return _dyld_get_image_vmaddr_slide(0);
}

/*
This Function calculates the Address if ASLR is enabled or returns the normal offset.
Parameters: The Original Offset
Return: Either the Offset or the New calculated Offset if ASLR is enabled
*/

uintptr_t calculateAddress(uintptr_t offset)
{

    if (hasASLR())
    {

        uintptr_t slide = get_slide();

        return (slide + offset);
    }
    else
    {

        return offset;
    }
}
/*
This function calculates the size of the data passed as an argument.
It returns 1 if 4 bytes and 0 if 2 bytes
Parameters: data to be written
Return: True = 4 bytes/higher or False = 2 bytes
*/

bool getType(unsigned int data)
{
    int a = data & 0xffff8000;
    int b = a + 0x00008000;

    int c = b & 0xffff7fff;
    return c;
}

/*
writeData(offset, data) writes the bytes of data to offset
this version is crafted to take use of MSHookMemory as
mach_vm functions are causing problems with codesigning on iOS 12.
Hopefully this workaround is just temporary.
*/

bool writeData(uintptr_t offset, unsigned int data)
{
    mshookmemory_ptr_t MSHookMemory_ = (mshookmemory_ptr_t)MSFindSymbol(NULL, "_MSHookMemory");

    // MSHookMemory is supported, use that instead of vm_write
    if (MSHookMemory_)
    {
        if (getType(data))
        {
            data = CFSwapInt32(data);
            MSHookMemory_((void *)calculateAddress(offset), &data, 4);
        }
        else
        {
            data = CFSwapInt16(data);
            MSHookMemory_((void *)calculateAddress(offset), &data, 2);
        }
        return true;
    }
    else
    {
        kern_return_t err = KERN_SUCCESS;
        mach_port_t port = mach_task_self();
        vm_address_t address = calculateAddress(offset);

        //set memory protections to allow us writing code there

        err = vm_protect(port, (vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);

        //check if the protection fails

        if (err != KERN_SUCCESS)
        {
            return false;
        }

        //write code to memory

        if (getType(data))
        {
            data = CFSwapInt32(data);
            err = vm_write(port, address, (vm_address_t)&data, sizeof(data));
        }
        else
        {
            data = (unsigned short)data;
            data = CFSwapInt16(data);
            err = vm_write(port, address, (vm_address_t)&data, sizeof(data));
        }
        if (err != KERN_SUCCESS)
        {
            return FALSE;
        }
        //set the protections back to normal so the app can access this address as usual

        err = vm_protect(port, (vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);

        return TRUE;
    }
}

bool writeDataWithSize(uintptr_t offset, void* data, size_t size)
{
    mshookmemory_ptr_t MSHookMemory_ = (mshookmemory_ptr_t)MSFindSymbol(NULL, "_MSHookMemory");

    // MSHookMemory is supported, use that instead of vm_write
    if (MSHookMemory_)
    {
        MSHookMemory_( (void *)calculateAddress(offset), data, size);
        return true;
    }
    else
    {
        kern_return_t err = KERN_SUCCESS;
        mach_port_t port = mach_task_self();
        vm_address_t address = calculateAddress(offset);

        //set memory protections to allow us writing code there

        err = vm_protect(port, (vm_address_t)address, size, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);

        //check if the protection fails

        if (err != KERN_SUCCESS)
        {
            return false;
        }

        err = vm_write(port, address, (vm_address_t)data, size);

        if (err != KERN_SUCCESS)
        {
            return false;
        }

        err = vm_protect(port, (vm_address_t)address, size, false, VM_PROT_READ | VM_PROT_EXECUTE);

        return true;
    }
}

#endif /* Writer_h */
