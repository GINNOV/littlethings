//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

//
// example of use of dos.libraray/SystemTags to run commands in given path
//
// dos.libraray is auto open/close by amiga.lib
//

#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>

#include <dos/dostags.h>
#include <proto/dos.h>

int suffixCounter;

void ExecuteSystem(const std::string &path, const std::string &command)
{
    std::string suffix = std::to_string(suffixCounter++);
    std::string fileName("T:output." + suffix);
    std::string errFileName("T:error." + suffix);

    std::cout << "#path> [" << path << "] #Command> " << command << std::endl;

    auto lock = Lock(path.c_str(), SHARED_LOCK);
    if (lock)
    {
        auto output = Open(fileName.c_str(), MODE_NEWFILE);
        if (output)
        {
            auto error = Open(errFileName.c_str(), MODE_NEWFILE);
            if (error)
            {
                auto res =
                    SystemTags(command.c_str(),
                               SYS_Input, 0,
                               SYS_Output, output,
                               NP_Error, error,
                               SYS_Asynch, TRUE,
                               NP_CurrentDir, (ULONG)lock,
                               NP_StackSize, 64 * 1024,
                               TAG_DONE);

                std::cout << "SystemTags() = " << res << std::endl;

                if (res != -1)
                {
                    // no Close(error) and no Close(output) and no UnLock(lock)
                    // because for "SYS_Asynch,TRUE", error & output are closed, lock is unlocked by SystemTags (see AmigaOS Autodocs)
                    lock = 0L;
                    std::cout << "SystemTags() ... ok" << std::endl;
                }
                else
                {
                    std::cout << "SystemTags(..) ... failed" << std::endl;
                    Close(error);
                    Close(output);
                }
            }
            else
            {
                std::cout << "error Open(" + errFileName + ") for write" << std::endl;
                Close(output);
            }
        }
        else
            std::cout << "error Open(" + fileName + ") for write" << std::endl;

        std::cout << "going to UnLock()" << std::endl;

        if (lock)
            UnLock(lock);
    }
    else
        std::cout << "error Lock(" + path + ")" << std::endl;

    // output, error files from T: are not deleted, should be in T:
}

int main(int argc, char **argv)
{
    srand((unsigned)time(NULL));
    suffixCounter = rand();

    std::cout << "argc = " << argc << std::endl;
    if (argc == 0) // check if run from icon
    {
        std::cout << "run from icon" << std::endl;
        return 0; // unsupported
    }
    else
        std::cout << "run from command line" << std::endl;

    std::vector<std::string> commands =
        {
            "assign",
            "which git",
            "list ram:",
            "dir ram:",
            "avail",
            "version",
            "run version",
            "unknowncommand",
            "run uknowncommand",
        };

    std::cout << "START commands" << std::endl;

    for (auto command : commands)
        ExecuteSystem("work:", command); // when using eg. RAM for path to lock it cause guru/exception

    std::cout << "END commands" << std::endl;

    return 0;
}
