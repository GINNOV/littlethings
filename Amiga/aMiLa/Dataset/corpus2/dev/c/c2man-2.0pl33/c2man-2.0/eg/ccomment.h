/*
** function starting with a C comment
*/
void ccomment(
	/* single line before */
	int single_before,

	/*
	 * multiple
	 * lines before
	 */
	int multiple_before,

	int end_of_line,	/* end of the line */

	int multiple_eol,	/*
				 * multiple lines
				 * starting at
				 * the EOL
				 */

	int single_eol_before_comma	/* end of line, but before comma */,

	int multiple_eol_before_comma	/*
					 * multiple lines after, at the EOL and
					 * before comma.
					 * can't imagine anyone coding this.
					 */,

	int single_after
	/* single line after */
	,

	int multiple_after
	/*
	 * multiple lines
	 * after.
	 * can't imagine anyone coding like this.
	 */
);

