/*      >>>>>>> start of cc5 <<<<<<<    */

/* 2/23/88 */

expression()
        {
        int lval[2];
        if(heir1(lval))
                rvalue(lval);
        }

heir1(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir2(lval);
        if(match("="))
                {
                if(k==0)
                        {
                        needlval();
                        return 0;
                        }
                if (lval[1])
                        zpush();
                if(heir1(lval2))
                        rvalue(lval2);
                store(lval);
                return 0;
                }
        else return k;
        }

heir2(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir3(lval);
        blanks();
        if(ch()!='|')
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if(match("|"))
                        {
                        zpush();
                        if(heir3(lval2))
                                rvalue(lval2);
                        zpop();
                        zor();
                        }
                else return 0;
                }
        }

heir3(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir4(lval);
        blanks();
        if(ch()!='^')
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if (match("^"))
                        {
                        zpush();
                        if(heir4(lval2))
                                rvalue(lval2);
                        zpop();
                        zxor();
                        }
                else return 0;
                }
        }

heir4(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir5(lval);
        blanks();
        if(ch()!='&')
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if(match("&"))
                        {
                        zpush();
                        if(heir5(lval2))
                                rvalue(lval2);
                        zpop();
                        zand();
                        }
                else return 0;
                }
        }

heir5(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir6(lval);
        blanks();
        if((streq(line+lptr,"==")==0) & (streq(line+lptr,"!=")==0))
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if (match("=="))
                        {
                        zpush();
                        if(heir6(lval2))
                                rvalue(lval2);
                        zpop();
                        zeq();
                        }
                else if (match("!="))
                        {
                        zpush();
                        if(heir6(lval2))
                                rvalue(lval2);
                        zpop();
                        zne();
                        }
                else return 0;
                }
        }

heir6(lval)
        int lval[];
        {
        int k;
        k=heir7(lval);
        blanks();
        if((streq(line+lptr,"<")==0)&
                (streq(line+lptr,">")==0)&
                (streq(line+lptr,"<=")==0)&
                (streq(line+lptr,">=")==0))
                        return k;
        if(streq(line+lptr,">>"))
                return k;
        if(streq(line+lptr,"<<"))
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if (match("<="))
                        {
                        if(heir6wrk(1,lval)) continue;
                        zle();
                        }
                else if (match(">="))
                        {
                        if(heir6wrk(2,lval)) continue;
                        zge();
                        }
                else if((streq(line+lptr,"<")) & (streq(line+lptr,"<<")==0))
                        {
                        inbyte();
                        if(heir6wrk(3,lval)) continue;
                        zlt();
                        }
                else if((streq(line+lptr,">")) & (streq(line+lptr,">>")==0))
                        {
                        inbyte();
                        if(heir6wrk(4,lval)) continue;
                        zgt();
                        }
                else return 0;
                }
        }

heir6wrk(k,lval)
        int k,lval[];
        {
        int lval2[2];
        zpush();
        if(heir7(lval2))
                rvalue(lval2);
        zpop();
        if(cptr=lval[0])
                if(cptr[ident]==pointer)
                        {
                        heir6op(k);
                        return 1;
                        }
        if(cptr=lval2[0])
                if(cptr[ident]==pointer)
                        {
                        heir6op(k);
                        return 1;
                        }
        return 0;
        }

heir6op(k)
        int k;
        {
        if(k==1)
                ule();
        else if(k==2)
                uge();
        else if(k==3)
                ult();
        else ugt();
        }

/*      >>>>>> start of cc6 <<<<<<      */

heir7(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir8(lval);
        blanks();
        if((streq(line+lptr,">>")==0) & (streq(line+lptr,"<<")==0))
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if (match(">>"))
                        {
                        zpush();
                        if(heir8(lval2))
                                rvalue(lval2);
                        zpop();
                        asr();
                        }
                else if (match("<<"))
                        {
                        zpush();
                        if(heir8(lval2))
                                rvalue(lval2);
                        zpop();
                        asl();
                        }
                else return 0;
                }
        }

heir8(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir9(lval);
        blanks();
        if((ch()!='+') & (ch()!='-'))
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {if (match("+"))
                        {
                        zpush();
                        if(heir9(lval2))
                                rvalue(lval2);
                        if(cptr=lval[0])
                                if((cptr[ident]==pointer) & (cptr[type]==cint))
                                        doublereg();
                        zpop();
                        zadd();
                        }
                else if (match("-"))
                        {
                        zpush();
                        if(heir9(lval2))
                                rvalue(lval2);
                        if(cptr=lval[0])
                                if((cptr[ident]==pointer) & (cptr[type]==cint))
                                        doublereg();
                        zpop();
                        zsub();
                        }
                else return 0;
                }
        }

heir9(lval)
        int lval[];
        {
        int k, lval2[2];
        k=heir10(lval);
        blanks();
        if((ch()!='*') & (ch()!='/') & (ch()!='%'))
                return k;
        if(k)
                rvalue(lval);
        while(1)
                {
                if (match("*"))
                        {
                        zpush();
                        if(heir9(lval2))
                                rvalue(lval2);
                        zpop();
                        mult();
                        }
                else if (match("/"))
                        {
                        zpush();
                        if(heir10(lval2))
                                rvalue(lval2);
                        zpop();
                        div();
                        }
                else if (match("%"))
                        {
                        zpush();
                        if(heir10(lval2))
                                rvalue(lval2);
                        zpop();
                        zmod();
                        }
                else return 0;
                }
        }

heir10(lval)
        int lval[];
        {
        int k;
        if(match("++"))
                {
                if((k=heir10(lval))==0)
                        {
                        needlval();
                        return 0;
                        }
                heir10inc(lval);
                return 0;
                }
        else if(match("--"))
                {
                if((k=heir10(lval))==0)
                        {
                        needlval();
                        return 0;
                        }
                heir10dec(lval);
                return 0;
                }
        else if (match("-"))
                {
                k=heir10(lval);
                if(k)
                        rvalue(lval);
                neg();
                return 0;
                }
        else if(match("*"))
                {
                heir10as(lval);
                return 1;
                }
        else if(match("&"))
                {
                k=heir10(lval);
                if(k==0)
                        {
                        error("illegal address");
                        return 0;
                        }
                else if(lval[1])
                        return 0;
                else
                        {
                        heir10at(lval);
                        return 0;
                        }
                }
        else
                {
                k=heir11(lval);
                if(match("++"))
                        {
                        if(k==0)
                                {
                                needlval();
                                return 0;
                                }
                        heir10id(lval);
                        return 0;
                        }
                else if(match("--"))
                        {
                        if(k==0)
                                {
                                needlval();
                                return 0;
                                }
                        heir10di(lval);
                        return 0;
                        }
                else return k;
                }
        }

heir10inc(lval)
        int lval[];
        {
        char *ptr;
        if(lval[1])
                zpush();
        rvalue(lval);
        inc();
        ptr=lval[0];
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                add3();
        store(lval);
        }

heir10dec(lval)
        int lval[];
        {
        char *ptr;
        if(lval[1])
                zpush();
        rvalue(lval);
        dec();
        ptr=lval[0];
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                sub3();
        store(lval);
        }

heir10as(lval)
        int lval[];
        {
        int k;
        char *ptr;
        k=heir10(lval);
        if(k)
                rvalue(lval);
        lval[1]=cint;
        if(ptr=lval[0])
                lval[1]=ptr[type];
        lval[0]=0;
        }

heir10at(lval)
        int lval[];
        {
        char *ptr;
        immlabel(ptr=lval[0]);
        lval[1]=ptr[type];
        }

heir10id(lval)
        int lval[];
        {
        char *ptr;
        if(lval[1])
                zpush();
        rvalue(lval);
        inc();
        ptr=lval[0];
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                add3();
        store(lval);
        dec();
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                sub3();
        }

heir10di(lval)
        int lval[];
        {
        char *ptr;
        if(lval[1])
                zpush();
        rvalue(lval);
        dec();
        ptr=lval[0];
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                sub3();
        store(lval);
        inc();
        if((ptr[ident]==pointer) & (ptr[type]==cint))
                add3();
        }

/*      >>>>>>> start of cc7 <<<<<<<    */

heir11(lval)
        int *lval;
        {
        int k;
        char *ptr;
        k=primary(lval);
        ptr=lval[0];
        blanks();
        if((ch()=='[') | (ch()=='('))
                while(1)
                        {
                        if(match("["))
                                {
                                if(ptr==0)
                                        {
                                        error("can't subscript");
                                        junk();
                                        needbrack("]");
                                        return 0;
                                        }
                                else if(ptr[ident]==pointer)
                                        rvalue(lval);
                                else if(ptr[ident]!=array)
                                        {
                                        error("can't subscript");
                                        k=0;
                                        }
                                zpush();
                                expression();
                                needbrack("]");
                                if((ptr[type])==cint)
                                        doublereg();
                                zpop();
                                zadd();
                                lval[1]=ptr[type];
                                k=1;
                                }
                        else if(match("("))
                                {
                                if(ptr==0)
                                        {
                                        callfunction(0);
                                        }
                                else if(ptr[ident]!=function)
                                        {
                                        rvalue(lval);
                                        callfunction(0);
                                        }
                                else callfunction(ptr);
                                k=lval[0]=0;
                                }
                        else return k;
                        }
        if(ptr==0)
                return k;
        if(ptr[ident]==function)
                {
                immlabel(ptr);
                return 0;
                }
        return k;
        }

primary(lval)
        int *lval;
        {
        char *ptr, sname[namesize];
        int num[1];
        int k;
        if(match("("))
                {
                k=heir1(lval);
                needbrack(")");
                return k;
                }
        if(symname(sname))
                {
                if(ptr=findloc(sname))
                        {
                        getloc(ptr);
                        lval[0]=ptr;
                        lval[1]=ptr[type];
                        if(ptr[ident]==pointer)
                                lval[1]=cint;
                        if((ptr[ident]==argument) & (ptr[type]==cchar))
                                lval[1]=cchararg;
                        else if(ptr[ident]==array)
                                return 0;
                        return 1;
                        }
                if(ptr=findglb(sname))
                        if(ptr[ident]!=function)
                        {
                        lval[0]=ptr;
                        lval[1]=0;
                        if(ptr[ident]!=array)
                                return 1;
                        immlabel(ptr);
                        return 0;
                        }
                ptr=addglb(sname,function,cint,0);
                lval[0]=ptr;
                lval[1]=0;
                return 0;
                }
        if(constant(num))
                return(lval[0]=lval[1]=0);
        else
                {
                error("invalid expression");
                immval(0);
                junk();
                return 0;
                }
        }

store(lval)
        int *lval;
        {
        if (lval[1]==0)
                putmem(lval[0]);
        else putstk(lval[1]);
        }

rvalue(lval)
        int *lval;
        {
        if((lval[0]!=0) & (lval[1]==0))
                getmem(lval[0]);
        else indirect(lval[1]);
        }
