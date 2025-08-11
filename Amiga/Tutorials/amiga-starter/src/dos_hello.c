#include <proto/dos.h>
#include <proto/exec.h>

int main(void) {
    const char *msg = "Hello from C (DOS/CLI)!\n";
    BPTR out = Output();
    if (out) {
        Write(out, (STRPTR)msg, 26);
    }
    return 0;
}
