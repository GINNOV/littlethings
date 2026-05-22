
extern unsigned long maximum,idle;

main()
{
    int percent,n;

    printf("Showing system usage for 25 seconds:\n");
    if(init_idle())
    {
        for(n=0;n<25;n++)
        {
            percent=(int)((idle*100)/maximum);
            printf("    %d percent free\n",percent);
            Delay(50L);
        }
        free_idle();
    }
}

