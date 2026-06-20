#include <stdio.h>
#include <semver.h>

const char *vers = "\0$VER: compare 1.0 (29.04.2020) semver sample program";
const char *copy = "Copyright (c) Tomas Aparicio";

char current[] = "1.5.10";
char compare[] = "2.3.0";

int main()
{
    semver_t current_version = {0, 0, 0, 0, 0};
    semver_t compare_version = {0, 0, 0, 0, 0};

    if (semver_parse(current, &current_version) || semver_parse(compare, &compare_version))
    {
        fprintf(stderr, "Invalid semver string\n");
        return -1;
    }

    int resolution = semver_compare(compare_version, current_version);

    if (resolution == 0)
    {
        printf("Versions %s is equal to: %s\n", compare, current);
    }
    else if (resolution == -1)
    {
        printf("Version %s is lower than: %s\n", compare, current);
    }
    else
    {
        printf("Version %s is higher than: %s\n", compare, current);
    }

    // Free allocated memory when we're done
    semver_free(&current_version);
    semver_free(&compare_version);
    return 0;
}