/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "wheel";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#eeeeee",   /* during input */
	[FAILED] = "#f4cccc",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;
