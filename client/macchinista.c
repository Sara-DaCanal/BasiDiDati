#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"


void mostra_turni(MYSQL *conn) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	int status;
	char header[512];
	int results;

	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_turni(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize show_shift statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for shift\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve shift list\n", true);
	}

	// We have multiple result sets here!
	do {
		// Skip OUT variables (although they are not present in the procedure...)
		if(conn->server_status & SERVER_PS_OUT_PARAMS) {
			goto next;
		}
		sprintf(header, "\nShifts:\n");
		dump_result_set(conn, prepared_stmt, header, &results);

		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
	    next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0){
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);
		}
		if(results == 0) printf("You don't have any shift this week yet\n");
		
	} while (status == 0);

	mysql_stmt_close(prepared_stmt);
}


void run_as_driver(MYSQL *conn)
{
	char options[2] = {'1','2'};
	char op;
	
	printf("Switching to driver role...\n");

	if(!parse_config("users/macchinista.json", &conf)) {
		fprintf(stderr, "Unable to load driver configuration\n");
		exit(EXIT_FAILURE);
	}

	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while(true) {
		printf("\033[2J\033[H");
		printf("*** What should I do for you? ***\n\n");
		printf("1) Show my shift\n");
		printf("2) Quit\n");

		op = multiChoice("Select an option", options, 2);

		switch(op) {
			case '1':
				mostra_turni(conn);
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
