struct cpu_info_type {
   int architecture;
   int char_size,int_size,long_size;
};

void vmwDumpPPC(FILE *fff);
extern struct cpu_info_type cpu_info;

   
