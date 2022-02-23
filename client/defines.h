#pragma once

#include <stdbool.h>
#include <mysql.h>

struct configuration {
	char *host;
	char *db_username;
	char *db_password;
	unsigned int port;
	char *database;

	char username[128];
	char password[128];
};

extern struct configuration conf;

extern int parse_config(char *path, struct configuration *conf);
extern char *getInput(unsigned int lung, char *stringa, bool hide);
extern bool yesOrNo(char *domanda, char yes, char no, bool predef, bool insensitive);
extern char multiChoice(char *domanda, char choices[], int num);
extern void print_error (MYSQL *conn, char *message);
extern void print_stmt_error (MYSQL_STMT *stmt, char *message);
extern void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt);
extern bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn);
extern void dump_result_set(MYSQL *conn, MYSQL_STMT *stmt, char *title, int *num_result);
extern void run_as_passenger(MYSQL *conn);
extern void run_as_driver(MYSQL *conn);
extern void run_as_controller(MYSQL *conn);
extern void run_as_administrator(MYSQL *conn);
extern void run_as_maintainer(MYSQL *conn);
extern void mostra_turni(MYSQL *conn);
extern int parse_date(char *date, MYSQL_TIME *parsed);
extern char *parse_time(char *time);
extern int date_compare(char *s);
extern int time_compare(char *s);
extern int int_compare(char *s);
