/* $Id: manpage.c,v 2.0.1.48 1994/09/16 05:54:36 greyham Exp $
 * stuff to do with manual page outputing
 */

#include "c2man.h"

#include <errno.h>
#include <ctype.h>

#include "manpage.h"
#include "strconcat.h"
#include "strappend.h"
#include "semantic.h"
#include "output.h"

#ifdef I_SYS_FILE
#include <sys/file.h>
#endif

/* list of manual pages */
ManualPage *firstpage = NULL;
ManualPage **lastpagenext = &firstpage;

void dummy() {}

void
new_manual_page(comment, decl_spec, declarator)
     char *comment;
     DeclSpec *decl_spec;
     Declarator *declarator;
{
    ManualPage *newpage;

    /* check that we really want a man page for this */
    if ((!comment) ||
	!inbasefile ||
	(!variables_out && !is_function_declarator(declarator)) ||
	(decl_spec->flags & DS_JUNK) ||
	(!static_out && (decl_spec->flags & DS_STATIC) && !header_file) ||

	/* only document extern stuff if it's in a header file, or includes a
	 * function definition.
	 */
	((decl_spec->flags & DS_EXTERN) && !header_file &&
				    declarator->type != DECL_FUNCDEF))
    {
	free_decl_spec(decl_spec);
	free_declarator(declarator);
	safe_free(comment);
	return;
    }
    
    declarator->comment = comment;
    
    newpage = (ManualPage *)safe_malloc(sizeof *newpage);
    newpage->decl_spec = (DeclSpec *)safe_malloc(sizeof *newpage->decl_spec);
    newpage->declarator = declarator;

    *newpage->decl_spec = *decl_spec;
    newpage->sourcefile = strduplicate(basefile);
    newpage->sourcetime = basetime;

    *lastpagenext = newpage;
    newpage->next = NULL;
    lastpagenext = &newpage->next;
}

void free_manual_page(page)
     ManualPage *page;
{
    free_decl_spec(page->decl_spec);
    free(page->decl_spec);
    free_declarator(page->declarator);
    safe_free(page->sourcefile);
}

/* free the list of manual pages */
void free_manual_pages(first)
     ManualPage *first;
{
    ManualPage *page, *next;

    /* free any terse description read from the file */
    if (group_terse && !terse_specified)
    {
    	free(group_terse);
	group_terse = NULL;
    }
    
    for (page = first;page;page = next)
    {
	next = page->next;
	free_manual_page(page);
	free(page);
    }
}

/* allocate a substring starting at start, ending at end (NOT including *end) */
char *alloc_string(start, end)
     const char *start;
     const char *end;
{
    int len = end - start;
    char *ret;
    if (len == 0)	return NULL;
    
    ret = (char *)safe_malloc((size_t)len+1);

    strncpy(ret,start,len);
    ret[len] = '\0';

    return ret; 
}

/* remember the terse description from the first comment in a file */
void remember_terse(comment)
     char *comment;
{
    char *c, *d;
    
    enum { STUFF, LEADSPACE, DASH, TRAILSPACE, FOUND } state = STUFF;

    /* if we've found a terse comment in a previous file, or one was
     * specified on the command line, forget it.
     */
    if (group_terse)	return;

    /* look for a whitespace surrounded sequence of dashes to skip */
    for (c = comment;*c && state != FOUND;c++)
    {
	switch (state)
	{
	case STUFF:	if (isspace(*c))	state = LEADSPACE;
			break;
	case LEADSPACE:	if (*c == '-')		state = DASH;
			else if (!isspace(*c))	state = STUFF;
			break;
	case DASH:	if (isspace(*c))	state = TRAILSPACE;
			else if (*c != '-')	state = STUFF;
			break;
	case TRAILSPACE:if (!isspace(*c))	{ c--; state = FOUND; }
			break;
	case FOUND:	break;
	}
    }

    /* if no dashes were found, go back to the start */
    if (state != FOUND)	c = comment;

    d = c + 1;
    
    while (*d && *d != '\n')
	d++;

    group_terse = alloc_string(c,d);
}

/* output a comment in man page form, followed by a newline */
void
output_comment(comment)
const char *comment;
{
    enum { TEXT, PERIOD, CAPITALISE } state = CAPITALISE;
    boolean new_line = TRUE;
    boolean dot_command = FALSE;
    
    if (!comment || !comment[0])
    {
	output->text("Not Documented.\n");
	return;
    }

    /* correct punctuation a bit as it goes out */
    for (;*comment;comment++)
    {
	int c = *comment;

	if (dot_command)
	{
	    if (c == '\n')	dot_command = FALSE;
	}
	else if (new_line && c == '.')
	    dot_command = TRUE;
	else if (new_line && (c == '-' || c == '*'))
	{
	    output->break_line();
	    state = CAPITALISE;
	}
	else if (c == '.')
	    state = PERIOD;
	else if (isspace(c) && state == PERIOD)
	    state = CAPITALISE;
	else if (isalnum(c) && state == CAPITALISE)
	{   
	    if (islower(c))	c = toupper(c);
	    state = TEXT;
	}
           
	output->character(c);
	new_line = c == '\n';
    }

    /* do a full stop if there wasn't one */
    if (!dot_command && state == TEXT)	output->character('.');

    output->character('\n');
}

/* output the returns section in man page form, followed by a newline */
void
output_returns(comment)
char *comment;
{
    enum { TEXT, PERIOD, CAPITALISE } state = CAPITALISE;
    char lastchar = '\n';
    boolean tag_list_started = FALSE;

    /* for each line... */
    while (*comment)
    {
	boolean tagged = FALSE;

	/* explicitly reject dot commands */
	if (*comment && *comment != '.')
	{
	    char *c = comment;

	    /* search along until the end of a word */
	    while (*c && *c != ':' && !isspace(*c))
		c++;

	    /* skip all spaces or tabs after the first word */
	    while (*c && *c != '\n')
	    {
		if (*c == '\t' || *c == ':')
		{
		    tagged = TRUE;
		    break;
		}
		else if (!isspace(*c))
		    break;

		c++;
	    }
	}

	/* is it tagged?; explicitly reject dot commands */
	if (tagged)
	{
	    /* output lingering newline if necessary */
	    if (lastchar != '\n')
	    {
		if (state == TEXT && !ispunct(lastchar))	output->character('.');
		output->character(lastchar = '\n');
	    }

	    if (!tag_list_started)
	    {
		output->tag_list_start();
		tag_list_started = TRUE;
	    }

	    /* output the taggy bit */
	    output->tag_entry_start();
	    while (*comment && *comment != ':' && !isspace(*comment))
		output->character(*comment++);
	    output->tag_entry_end();

	    /* skip any extra tabs or spaces */
	    while (*comment == ':' || (isspace(*comment) && *comment != '\n'))
		comment++;

	    state = CAPITALISE;
	}

	/* terminate the previous line if necessary */
	if (lastchar != '\n')	output->character(lastchar = '\n');

	/* dot commands go out unaltered */
	if (*comment == '.')
	{
	    for (;*comment && *comment != '\n'; comment++)
		output->character(*comment);
	    output->character('\n');
	}
	else
	{
	    /* correct punctuation a bit as the line goes out */
	    for (;*comment && *comment != '\n'; comment++)
	    {
		char c = *comment;

		if (c == '.')
		    state = PERIOD;
		else if (isspace(c) && state == PERIOD)
		    state = CAPITALISE;
		else if (isalnum(c) && state == CAPITALISE)
		{   
		    if (islower(c))	c = toupper(c);
		    state = TEXT;
		}

		output->character(lastchar = c);
	    }

	    /* if it ended in punctuation, just output the nl straight away. */
	    if (ispunct(lastchar))
	    {
		if (lastchar == '.')	state = CAPITALISE;
		output->character(lastchar = '\n');
	    }
	}

	if (*comment)	comment++;
    }

    /* output lingering newline if necessary */
    if (lastchar != '\n')
    {
	if (state == TEXT && !ispunct(lastchar))	output->character('.');
	output->character('\n');
    }

    if (tag_list_started)
	output->tag_list_end();

}

/* output the phrase "a[n] <type name>" */
void output_conjunction(text)
char *text;
{
    output->character('a');
    if (strchr("aAeEiIoOuU",text[0]))	output->character('n');
    output->character(' ');
    output->code(text);
}

/* output the description for an identifier; be it return value or param */
static void output_identifier_description(comment, outfunc,
						    decl_spec, declarator)
    const char *comment;		/* comment for this identifier */
    void (*outfunc) _((const char *));	/* function to output comment */
    const DeclSpec *decl_spec;
    const Declarator *declarator;
{
    /* one day, this may document the contents of structures too */

    /* output list of possible enum values, if any */
    if (decl_spec->enum_list)
    {
	int maxtaglen = 0;
	char *longestag = NULL;
	int descriptions = 0;
	int entries = 0;
	Enumerator *e;
	int is_first = 1;
	boolean started = FALSE;
	
	/* don't output the "Not Doc." message for enums */
	if (comment)
	{
	    (*outfunc)(comment);
	    output->blank_line();
	}
	
	/* see if any have descriptions */
	for (e = decl_spec->enum_list->first; e; e = e->next)
	    if (e->name[0] != '_')
	    {
		int taglen = strlen(e->name);
		if (taglen > maxtaglen)
		{
		    maxtaglen = taglen;
		    longestag = e->name;
		}
		if (e->comment)	descriptions = 1;
		entries++;
	    }

	/* if there are a lot of them, the list may be automatically generated,
	 * and probably isn't wanted in every manual page.
	 */
	if (entries > 20)
	{
	    char entries_s[15];
	    sprintf(entries_s, "%d", entries);
	    output->text("Since there are ");
	    output->text(entries_s);
	    output->text(" possible values for ");
	    output_conjunction(decl_spec->text);
	    output->text(", they are not all listed here.\n");
	}
	else if (entries > 0)   /* skip the pathological case */
	{
	    /* the number of possibilities is reasonable; list them all */
	    output->text("Possible values for ");
	    output_conjunction(decl_spec->text);
	    output->text(" are as follows:\n");
    
	    for (e = decl_spec->enum_list->first; e; e = e->next)
	    {
		/* don't print names with a leading underscore! */
		if (e->name[0] == '_')	continue;
		
		if (e->group_comment)
		{
		    /* break out of table mode for the group comment */
		    if (started)
		    {
			if (descriptions)
			    output->table_end();
			else
			    output->list_end();
			started = FALSE;
		    }
		    output->indent();
		    output_comment(e->group_comment);
		}
    
		if (!started)
		{
		    if (descriptions)
			output->table_start(longestag);
		    else
			output->list_start();
		    started = TRUE;
		}
    
		if (descriptions)
		    output->table_entry(e->name, e->comment);
		else
		{
		    if (!is_first)
			output->list_separator();
		    is_first = 0;
		    output->list_entry(e->name);
		}
	    }
    
	    if (started)
	    {
		if (descriptions)
		    output->table_end();
		else
		    output->list_end();
	    }
	}
    } 
    else
	(*outfunc)(comment);
}

/* is there automatic documentation here? */
static boolean auto_documented(page)
const ManualPage *page;
{
    /* one day we may handle structs too */
    return
	page->decl_spec->enum_list != NULL;    /* enums are self-documenting. */
}

/* decide if a manual page needs a RETURNS section.
 * If this is true, then output_identifier_description must be able to generate
 * sensible output for it.
 */
static boolean needs_returns_section(page)
const ManualPage *page;
{
    return 
	(page->returns && page->returns[0]) ||
	(auto_documented(page) && is_function_declarator(page->declarator));
}

/* does this declarator have documented parameters? */
boolean has_documented_parameters(d)
const Declarator *d;
{
    if (has_parameters(d))
    {
	Parameter *p;

	for (p = d->head->params.first; p != NULL; p = p->next)
	    if (p->declarator->comment || always_document_params)
		return TRUE;
    }
    return FALSE;
}

/* Output the list of function parameter descriptions.
 */
void
output_parameter_descriptions (params, function)
ParameterList *params;
char *function;
{
    Parameter *p;
    boolean tag_list_started = FALSE;

    for (p = params->first; p != NULL; p = p->next)
    {
	if (p->suppress ||
	    (!always_document_params && p->declarator->comment == NULL))
		continue;

	if (!tag_list_started)
	{
	  output->tag_list_start();
	  tag_list_started = TRUE;
	}

	if (p->duplicate)
	    output->tag_entry_start_extra();
	else
	    output->tag_entry_start();

	output_parameter(p);

	/* include function name if it's a duplicate */
	if (p->duplicate)
	    output->tag_entry_end_extra(function);
	else
	    output->tag_entry_end();

	output_identifier_description(p->declarator->comment, output_comment,
						&p->decl_spec, &p->declarator);
    }

    if (tag_list_started)
	output->tag_list_end();
}

/* split out the 'Returns:' section of a function comment */
boolean
split_returns_comment(comment, description, returns)
     char *comment;
     char **description;
     char **returns;
{
    char *retstart;

    for (retstart = comment;
	 retstart;
	 retstart = strchr(retstart,'\n'))
    {
	if (*retstart == '\n')	retstart++;	/* skip the newline */

	if (!strncmpi(retstart, "returns",(size_t)7))
	{	    
	    char *descend = retstart - 2;	/* back before newline */

	    /* go back to the end of the description in case there were
	     * linefeeds before the returns.
	     */
	    while (descend > comment && isspace(*descend))
		descend--;

	    *description =
		descend > comment ? alloc_string(comment,descend+1) : NULL;

	    retstart += 7;
		
	    while (*retstart == ':' || isspace(*retstart))
		retstart++;

	    if (*retstart)
		*returns = strduplicate(retstart);
	    else
	    	*returns = NULL;
	    return TRUE;
	}
    }

    *description = comment;
    *returns = NULL;
    return FALSE;
}

/* skip to past the dash on the first line, if there is one
 * The dash must be surrounded by whitespace, so hyphens are not skipped.
 */
const char *skipdash(c)
const char *c;
{
    const char *d;

    /* ignore anything on the first line, up to a dash (if any) */
    for (d = c + 1; *d && *d != '\n' && *d != '-'; d++)
	;

    if (isspace(d[-1]) && d[0] == '-' && isspace(d[1]))
    {
	do
	    d++;
	while (*d && *d != '\n' && isspace(*d));

	if (*d && *d != '\n')	c = d;
    }
    return c;
}

/* split the function comment into manual page format */
void
split_function_comment(comment, identifier_name,
				    terse, description, returns, extra_sections)
    const char *comment;
    const char *identifier_name;
     char **terse;
     char **description;
     char **returns;
     Section **extra_sections;
{
    const char *c, *start_text = NULL, *end_text = NULL;
    char **put_ptr = NULL;
    Section *first_section, **lastnextsection = &first_section;
    boolean explicit_description = FALSE;
    boolean lastblank = TRUE;
    boolean skip_dash = FALSE;
    
    *description = *returns = NULL;
    if (terse)	*terse = NULL;

    /* for each line... */
    for (c = comment; *c;)
    {
	const char *start_line = c;
	boolean section_heading;
	/* remember if it's a blank line */
	if (*c == '\n')
	{
	    lastblank = TRUE;
	    c++;
	    continue;
	}

	/* if the last one was blank, perhaps this one is a section heading
	 */
	if (lastblank)
	{
	    /* see if we've found the start of a SECTION */
	    while (isalpha(*c))
		c++;
    
	    section_heading = *c == '\n' || *c == ':' ||
					(*c == '\0' && start_line == comment);
	}
	else
	    section_heading = FALSE;

	lastblank = FALSE;	/* this one's not blank; for next time */

	if (section_heading)
	{
	    size_t section_len = c - start_line; /* length of section name */

	    /* yes, we've found a SECTION; store the previous one (if any) */
	    if (put_ptr && start_text)
	    {
		if (skip_dash)	start_text = skipdash(start_text);
		*put_ptr = alloc_string(start_text,end_text);
	    }

	    skip_dash = FALSE;

	    /* check for comments that start with the name of the identifier */
	    if (start_line == comment &&
		!strncmp(start_line, identifier_name, section_len))
	    {
		put_ptr = description;
	    }

	    /* only accept NAME if not grouped */
	    else if (terse && 
		     (!strncmpi(start_line,"NAME", section_len) ||
		      !strncmpi(start_line,"FUNCTION", section_len) ||
		      !strncmpi(start_line,"PROCEDURE", section_len) ||
		      !strncmpi(start_line,"ROUTINE", section_len))
		     )

	    {
		put_ptr = terse;
		skip_dash = TRUE;
	    }
	    else if (!strncmpi(start_line,"DESCRIPTION", section_len))
	    {
		explicit_description = TRUE;
		put_ptr = description;
	    }
	    else if (!strncmpi(start_line,"RETURNS", section_len))
	    {
		put_ptr = returns;
	    }
	    else
	    {
		/* allocate a new section */
		Section *new_section =
				(Section *)safe_malloc(sizeof *new_section);

		*lastnextsection = new_section;
		lastnextsection = &new_section->next;

		new_section->name = alloc_string(start_line,c);
		strtoupper(new_section->name);
		new_section->text = NULL;
		new_section->been_output = FALSE; /* not been output yet */
		put_ptr = &new_section->text;
	    }

	    /* defer decision about where text starts till we find some */
	    start_text = NULL;

	    if (*c == ':')	/* skip the terminating : */
	    {
		c++;

		/* skip forward to the start of the text */
		while (*c && *c != '\n' && isspace(*c))
		    c++;

		/* if we find the text here, then we've got it */
		if (*c && *c != '\n')
		    start_text = c;
	    }
	}
	else
	{
	    /* are we looking at the top of the function comment? */
	    if (start_line == comment)
	    {
		/* only look for terse comment if not grouped together */
		if (terse)
		{
		    const char *endterse, *afterdash = skipdash(start_line);

		    /* find the end of the terse comment */
		    while (*c && *c != '.' && *c != '\n')
			c++;

		    endterse = *c == '.' ? c+1 : c;
		    *terse = alloc_string(
			afterdash < endterse ? afterdash : start_line,
			endterse);

		    /* skip it if it's a ., and any trailing spaces */
		    if (*c == '.')
			do c++; while (*c && *c != '\n' && isspace(*c));

		    start_text = NULL;	/* look for it */

		    if (*c && *c != '\n')
			/* actually, it's a description, starting here */
			start_text = c;
		}
		/* must be a description starting at the beginning of the line.
		 */
		else
		    start_text = start_line;

		put_ptr = description;
	    }
	    else
		/* have we just located the first real text in a section? */
		if (put_ptr && !start_text)	start_text = start_line;
	}

	/* skip the line */
	if (*c && *c != '\n')
	    while (*c && *c != '\n')	c++;

	end_text = c;	/* so far, the text ends at the end of this line */
	if (*c)	c++;
    }

    /* store the last one */
    if (put_ptr && start_text)
    {
	if (skip_dash)	start_text = skipdash(start_text);
	*put_ptr = alloc_string(start_text,end_text);
    }

    /* terminate (or nuke) section list */
    *lastnextsection = NULL;

    /* if there wasn't a RETURNS section, and the DESCRIPTION field was not
     * explicit, see if we can split one out of the description field.
     */
    if (*returns == NULL && !explicit_description)
    {
	char *olddesc = *description;
    	if (split_returns_comment(olddesc, description, returns))
	    free(olddesc);
    }

    *extra_sections = first_section;
}

/* see if two parameters are declared identically */
boolean params_identical(first, second)
     Parameter *first;
     Parameter *second;
{
    return
	first->decl_spec.flags == second->decl_spec.flags &&

	/* there may be no decl_spec.text if it's an ellipsis arg */
	((!first->decl_spec.text && !second->decl_spec.text) ||
	 (first->decl_spec.text && second->decl_spec.text &&
	  !strcmp(first->decl_spec.text, second->decl_spec.text))) &&

	((!first->declarator->text && !second->declarator->text) ||
	 (first->declarator->text && second->declarator->text &&
	  !strcmp(first->declarator->text, second->declarator->text)));
}

/* search all the parameters in this grouped manual page for redundancies */
boolean mark_duplicate_parameters(firstpage)
     ManualPage *firstpage;
{
    Parameter *param;
    boolean any = FALSE;
    ManualPage *page;

    for (page = firstpage; page; page = page->next)
    {
	if (has_parameters(page->declarator))
	for (param = page->declarator->head->params.first; param;
							param = param->next)
	{
	    ManualPage *otherpage;
	    Parameter *otherparam;
	    
	    if (always_document_params || param->declarator->comment)
		any = TRUE;

	    for (otherpage = page->next; otherpage;
						otherpage = otherpage->next)
	    {
		if (has_parameters(otherpage->declarator))
		for (otherparam = otherpage->declarator->head->params.first;
		     otherparam;
		     otherparam = otherparam->next)
		{
		    /* do these two look the same? */
		    if (params_identical(param, otherparam))
		    {
			/* order is important for bit positions */
			enum { NEITHER, US, THEM, BOTH } has_comm = NEITHER;
			
			/* work out who has the comment */
			if (param->declarator->comment)	has_comm |= US;
			if (otherparam->declarator->comment) has_comm |= THEM;

			switch(has_comm)
			{
			case NEITHER:
			case US:
			    otherparam->suppress = TRUE;
			    break;
			case THEM:
			    param->suppress = TRUE;
			    break;
			case BOTH:
			    if (!strcmp(param->declarator->comment,
					    otherparam->declarator->comment))
				otherparam->suppress = TRUE;
			    else
			    {
				param->duplicate = TRUE;
				otherparam->duplicate = TRUE;
			    }
			    break;
			}
		    }
		}
	    }
	}
    }
    return any;
}

/* output a formatting string so that it works with filling on */
void output_format_string(fmt)
const char *fmt;
{
    while (*fmt)
    {
	output->character(*fmt);

	if (*fmt++ == '\n')
	    output->break_line();	/* break the line */
    }
}

/* write the warning for the header */
void output_warning()
{
    output->comment();
    output->text("WARNING! THIS FILE WAS GENERATED AUTOMATICALLY BY ");
    output->text(progname);
    output->text("!\n");
    output->comment();
    output->text("DO NOT EDIT! CHANGES MADE TO THIS FILE WILL BE LOST!\n");
}

void output_includes()
{
    IncludeFile *incfile;
    
    for (incfile = first_include; incfile; incfile=incfile->next)
    {
	char *name = incfile->name;
	boolean surrounded = *name == '"' || *name == '<';
	
	output->text("#include ");
	if (!surrounded)	output->character('<');
	output->text(name);
	if (!surrounded)	output->character('>');
	output->text("\n");
	output->break_line();
	}
}

int exclude_section(section)
const char *section;
{
    ExcludeSection *exclude;

    for (exclude = first_excluded_section ; exclude ; exclude = exclude->next)
	if (!strcmp(section, exclude->name)) return 1;

    return 0;
}


/* Writes the entire contents of the manual page specified by basepage. */
void
output_manpage(firstpage, basepage, input_files, title, section)
    /* the first page in the list of all manual pages.  This is used to build
     * the SEE ALSO section of related pages when group_together is false.
     */
    ManualPage *firstpage;

    /* the base page from which the output manual page will be generated.  if
     * group_together indicates that the user wanted grouped pages, basepage
     * will always be the same as firstpage, and all the ManualPage's in the
     * list will be grouped together into the one output page.
     */
    ManualPage *basepage;

    int input_files;
    const char *title;
    const char *section;
{
    ManualPage *page;
    boolean need_returns;
    char *terseout, *terse = NULL;
    
    /* check if there's more than one page in the group */
    boolean grouped = group_together && firstpage->next;

    /* split up all the function comments for this page */
    for (page = basepage; page; page = page->next)
    {
	split_function_comment(page->declarator->comment,
	    page->declarator->name,
	    group_together ? (char **)NULL : &terse,
	    &page->description,&page->returns,&page->first_section);
	if (!group_together)	break;
    }

    /* work out what we'll actually print as a terse description */
    terseout = group_terse ? group_terse : (terse ? terse : "Not Described");

    output->header(basepage, input_files, grouped,
		    title ? title : basepage->declarator->name, section);
    
    output->name(NULL);
    /* output the names of all the stuff documented on this page */
    for (page = basepage; page; page = page->next)
    {
	output->name(page->declarator->name);

	if (!group_together)	break;

	if (page->next)	output->text(",\n");
    }

    output->terse_sep();
    output->text(terseout);
    output->character('\n');
    
    output->section("SYNOPSIS");

    output->code_start();
    
    /* list the include files the user asked us to */
    output_includes();

    /* if it's a header file, say to #include it */
    if (header_file)
    {
	output->text("#include <");
	if (header_prefix)
	{
	    output->text(header_prefix);
	    output->character('/');
	}
	output->text(basefile);
	output->text(">\n");
    }

    /* can't just use .PP; that may reset our font */
    if (first_include || header_file)	output->blank_line();

    for (page = basepage; page; page = page->next)
    {
	output_format_string(decl_spec_prefix);

	/* make sure variables are prefixed extern */
	if (!(page->decl_spec->flags & DS_STATIC) &&
	    !is_function_declarator(page->declarator) &&
	    !strstr(page->decl_spec->text, "extern"))
	    output->text("extern ");

	output_decl_spec(page->decl_spec);
	output_format_string(declarator_prefix);

	/* format it nicely if there's more than one parameter */
	output_declarator(page->declarator, 
	    page->declarator->head->params.first !=
	    page->declarator->head->params.last);

	output->text(";\n");
    
	if (!grouped)	break;
	if (page->next)	output->blank_line();
    }

    output->code_end();

    /* only output paramaters if there actually are some,
     * not including merely (void)
     */
    if ((grouped && mark_duplicate_parameters(basepage)) ||
        (!grouped && has_documented_parameters(basepage->declarator)))
    {
	output->section("PARAMETERS");

	for (page = basepage; page; page = page->next)
	{
	    if (has_parameters(page->declarator))
		output_parameter_descriptions(&page->declarator->head->params,
						    page->declarator->name);
	    if (!grouped)	break;	/* only do first page */
	}
    }

    output->section("DESCRIPTION");

    if (grouped)
    {
	need_returns = FALSE;
	for (page = basepage; page; page = page->next)
	{
	    if (needs_returns_section(page))	need_returns = TRUE;

	    /* enum variables are documented in DESCRIPTION */
	    if (auto_documented(page) &&
				    !is_function_declarator(page->declarator))
	    {
		output->sub_section(page->declarator->name);
		output_identifier_description(page->description,
		    output_comment, page->decl_spec, page->declarator);
	    }
	    else if (page->description)
	    {
		output->sub_section(page->declarator->name);
		output_comment(page->description);
	    }

	    safe_free(page->description);
	}
    }
    else
    {
	const char *descr = basepage->description ? basepage->description
						   : terseout;

	need_returns = needs_returns_section(basepage);

	if (auto_documented(page) && !is_function_declarator(page->declarator))
	    output_identifier_description(descr, output_comment,
					    page->decl_spec, page->declarator);
	else
	    output_comment(descr);

	safe_free(basepage->description);

    }

    /* terse can now never be a static string */
    safe_free(terse);

    if (need_returns)
    {
	output->section("RETURNS");

	for (page = basepage; page; page = page->next)
	{
	    if (needs_returns_section(page))
	    {
		if (grouped) output->sub_section(page->declarator->name);

		output_identifier_description(page->returns, output_returns,
					    page->decl_spec, page->declarator);
		safe_free(page->returns);
	    }

	    if (!grouped)	break;
	}
    }

    /* output any other sections */
    for (page = basepage; page; page = page->next)
    {
	Section *section, *next;

	for (section = page->first_section; section; section = next)
	{
	    next = section->next;

	    if (!section->been_output && section->text &&
		strncmpi(section->text,"none",4) &&
		 !exclude_section(section->name))
	    {
		output->section(section->name);
		if (grouped) output->sub_section(page->declarator->name);
		output_comment(section->text);
		section->been_output = TRUE;
    
		if (grouped && page->next)
		{
		    ManualPage *other_page = page->next;
    
		    /* look through all the other pages for matching sections */
		    for (; other_page; other_page = other_page->next)
		    {
			Section *other_section = other_page->first_section;
			for (;other_section; other_section =
							    other_section->next)
			{
			    if (other_section->been_output ||
				strcmp(other_section->name, section->name))
				continue;
    
			    output->sub_section(other_page->declarator->name);
			    output_comment(other_section->text);
			    other_section->been_output = TRUE;
			}
		    }
		}
	    }


	    /* free this section */
	    free(section->name);
	    safe_free(section->text);
	    free(section);
	}

	if (!grouped)	break;
    }

    /* only output SEE ALSO if not grouped */
    if (!group_together)
    {
	ManualPage *also;

	/* add the SEE ALSO section */
	/* look for any other functions to refer to */
	for (also = firstpage; also && also == basepage; also = also->next)
		;
	
	if (also && !exclude_section("SEE ALSO"))	/* did we find at least one? */
	{
	    int isfirst = 1;

	    output->section("SEE ALSO");
	    
	    for (also = firstpage; also; also = also->next)
	    {
		if (also == basepage)	continue;
		
		if (!isfirst)
		    output->text(",\n");
		else
		    isfirst = 0;
		    
		output->reference(also->declarator->name);
	    }
	
	    output->character('\n');
	}
    }

    if (!make_embeddable)
	output->file_end();
}


/* generate output filename based on a string */
char *page_file_name(based_on, object_type, extension)
    /* string to base the name on; this will be the name of an identifier or
     * the base of the input file name.
     */
    const char *based_on;
    enum Output_Object object_type;	/* class of object documented */
    const char *extension;		/* file extension to use */
{
    char *filename;
    const char *subdir = output_object[object_type].subdir;

#ifndef FLEXFILENAMES
    char *basename;
    int chopoff = 14 - strlen(extension) - 1;

    basename = strduplicate(based_on);
    if (strlen(basename) > chopoff)
	basename[chopoff] = '\0';
#else
    const char *basename = based_on;
#endif

    filename = strduplicate(output_dir);

    if (subdir)
    {
	if (filename)	filename = strappend(filename, "/", NULLCP);
	filename = strappend(filename, subdir, NULLCP);
    }

    if (filename)	filename = strappend(filename, "/", NULLCP);
    filename = strappend(filename, basename,".",extension, NULLCP);

#ifndef FLEXFILENAMES
    free(basename);
#endif
    return filename;
}

/* determine the output page type from a declaration */
enum Output_Object page_output_type(decl_spec, declarator)
const DeclSpec *decl_spec;
const Declarator *declarator;
{
    boolean is_static = decl_spec->flags & DS_STATIC;
    return is_function_declarator(declarator)
	? (is_static ? OBJECT_STATIC_FUNCTION : OBJECT_FUNCTION)
	: (is_static ? OBJECT_STATIC_VARIABLE : OBJECT_VARIABLE);
}

/* determine the extension/section from an output type */
const char *page_manual_section(output_type)
enum Output_Object output_type;
{
    return	output_object[output_type].extension ?
		output_object[output_type].extension : manual_section;
}

/* remove an existing file, if it exists & we have write permission to it */
int remove_old_file(name)
const char *name;
{
#ifdef HAS_ACCESS
    /* check that we have write premission before blasting it */
    if (access(name,W_OK) == -1)
    {
	if (errno != ENOENT)
	{
	    my_perror("can't access output file", name);
	    return FALSE;
	}
     }
    else
#endif
    {
	/* if it exists, blast it */
	if (unlink(name) == -1 && errno != ENOENT)
	{
	    my_perror("error unlinking old link file", name);
	    return FALSE;
	}
    }
    return TRUE;
}

/* output all the manual pages in a list */
void output_manual_pages(first, input_files, link_type)
    ManualPage *first;
    int input_files;	/* number of different input files */
    enum LinkType link_type;	/* how grouped pages will be linked */
{
    ManualPage *page;
    int tostdout = output_dir && !strcmp(output_dir,"-");

    char *filename = NULL;

    /* output each page, in turn */
    for (page = first; page; page = page->next)
    {
	char *input_file_base = NULL;
	enum Output_Object output_type =
			page_output_type(page->decl_spec, page->declarator);

	/* the manual name is used as the output file extension, and also in
	 * the nroff output header.
	 */
	const char *section = page_manual_section(output_type);

	/* work out the base name of the file this was generated from */
	if (page->sourcefile)
	{
	    const char *base = strrchr(firstpage->sourcefile, '/');
	    const char *last;
    
	    /* use the file name as the manual page title */
	    if (base == NULL)
		base = firstpage->sourcefile;
	    else
		base++;
	    last = strrchr(base, '.');
	    if (last == NULL)
		last = base + strlen(base);
    
	    input_file_base = alloc_string(base, last);
	}

	if (!tostdout)
	{
	    safe_free(filename);	/* free previous, if any */
	    filename = page_file_name(
		use_input_name && input_file_base
				? input_file_base : page->declarator->name,
		output_type, section);
	    fprintf(stderr,"generating: %s\n",filename);

	    /* a previous run may have left links, so nuke old file first */
	    if (!remove_old_file(filename))	exit(1);

	    if (freopen(filename, "w", stdout) == NULL)
	    {
		my_perror("error opening output file", filename);
		free(filename);
		exit(1);
	    }
	}

	/* do the page itself */
	output_manpage(first, page, input_files,
	    group_together && input_file_base ? input_file_base
					      : page->declarator->name,
	    group_together ? manual_section : section);

	safe_free(input_file_base);

	/* don't continue if grouped, because all info went into this page */
	if (group_together)		break;

	if (tostdout &&	page->next)	output->character('\f');
    }

    /* close the last output file if there was one */
    if (!tostdout && fclose(stdout) == EOF)
    {
	my_perror("error linking closing file", filename);
	exit(1);
    }

    /* if pages are grouped, just link the rest to the first */
    if (group_together && !tostdout && link_type != LINK_NONE)
    {
	for (page=use_input_name && first->sourcefile ? first : first->next;
						    page; page = page->next)
	{
	    enum Output_Object output_type =
			page_output_type(page->decl_spec, page->declarator);
	    const char *extension = page_manual_section(output_type);
	    char *linkname = page_file_name(page->declarator->name,
							output_type, extension);
	    int result = 0;

	    /* we may have a function with the same name as the sourcefile */
	    if (!strcmp(filename, linkname))
	    {
		free(linkname);
		continue;
	    }
			
	    fprintf(stderr,"%s: %s\n",
		link_type == LINK_REMOVE ? "removing" : "linking", linkname);

	    /* always nuke old output file, since it may be linked to the one
	     * we've just generated, so LINK_FILE may trash it.
	     */
	    if (!remove_old_file(linkname))	exit(1);

	    switch(link_type)
	    {
#ifdef HAS_LINK
	    case LINK_HARD:
		result = link(filename, linkname);
		break;
#endif
#ifdef HAS_SYMLINK
	    case LINK_SOFT:
		result = symlink(filename, linkname);
		break;
#endif
	    case LINK_FILE:
		if (freopen(linkname, "w", stdout) == NULL)
		{
		    result = -1;
		    break;
		}
		output_warning();
		output->include(filename);
		if (fclose(stdout) == EOF)
		    result = -1;
		break;
	    case LINK_NONE:
	    case LINK_REMOVE:
		break;
	    }

	    /* check it went OK */
	    if (result == -1)
	    {
		my_perror("error linking output file", linkname);
		exit(1);
	    }
	    free(linkname);
	}
    }

    safe_free(filename);
}
