#include <stdio.h>
#include <semver.h>

const char *vers = "\0$VER: satisfies 1.0 (29.04.2020) semver sample program";
const char *copy = "Copyright (c) Tomas Aparicio";

semver_t current = {0, 0, 0, 0, 0};
semver_t compare = {0, 0, 0, 0, 0};

int main()
{
    semver_parse("1.3.10", &current);
    semver_parse("1.5.2", &compare);

    // Use caret operator for the comparison
    char operator[] = "^";

    if (semver_satisfies(current, compare, operator))
    {
        printf("Version %s can be satisfied by %s", "1.3.10", "1.5.2");
    }

    // Free allocated memory when we're done
    semver_free(&current);
    semver_free(&compare);
    return 0;
}
