#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"


void insert_report(MYSQL *conn) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char char_id[20];
	int id;
	char report[2048];

	printf("Vehicle id: ");
	while(true){
		getInput(20, char_id, false);
		if(int_compare(char_id)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Report: \n");
	getInput(2048, report, false);

	id = atoi(char_id);

	if(!setup_prepared_stmt(&prepared_stmt, "call insert_report(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize insert_report statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = report;
	param[0].buffer_length = strlen(report);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &id;
	param[1].buffer_length = sizeof(id);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for report insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not insert report\n", true);
	}
	else printf("Report correctly inserted...\n");

	mysql_stmt_close(prepared_stmt);
}


void run_as_maintainer(MYSQL *conn)
{
	char options[2] = {'1','2'};
	char op;
	
	printf("Switching to maintainer role...\n");

	if(!parse_config("users/manutentore.json", &conf)) {
		fprintf(stderr, "Unable to load maintainer configuration\n");
		exit(EXIT_FAILURE);
	}

	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while(true) {
		printf("\033[2J\033[H");
		printf("*** What should I do for you? ***\n\n");
		printf("1) Insert new report\n");
		printf("2) Quit\n");

		op = multiChoice("Select an option", options, 2);

		switch(op) {
			case '1':
				insert_report(conn);
				break;
				
			case '2':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}
