#define DEBUG 0
#include "opt.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "ic.h"
#include "expr.h"
#include "util/bset.h"

void opt_main(void)
{
    unsigned n1;

    for (n1 = 0; n1 < cg_nodes_counter; n1++) {
        unsigned n2;

        for (n2 = cg_node(n1).bb_i; n2 <= cg_node(n1).bb_f; n2++) {
            unsigned i;

            for (i = cfg_node(n2).leader; i <= cfg_node(n2).last; i++) {
                unsigned tar, arg1, arg2;

                tar = instruction(i).tar;
                arg1 = instruction(i).arg1;
                arg2 = instruction(i).arg2;

                switch (instruction(i).op) {
                    ;
                }
            }
        }
    }
}
