#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"


static void controlla_biglietti(MYSQL *conn) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	MYSQL_BIND param1;
	char header[512];
	char codice[10];
	int valid;
	int results;

	printf("Inserire il codice della prenotazione: ");
	getInput(20, codice, false);
	if(!setup_prepared_stmt(&prepared_stmt, "call controllo_biglietti(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize check_ticket statement\n", false);
	}
	int i_codice = atoi(codice);
	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &i_codice;
	param[0].buffer_length = sizeof(i_codice);

	param[1].buffer_type = MYSQL_TYPE_SHORT;
	param[1].buffer = &valid;
	param[1].buffer_length = sizeof(valid);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for check_ticket\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not check ticket list\n", true);
	}
	if(conn->server_status & SERVER_PS_OUT_PARAMS) {
		mysql_stmt_next_result(prepared_stmt);
	}
	sprintf(header, "\nInformation:\n");
	dump_result_set(conn, prepared_stmt, header, &results);
	if(results == 0){
		printf("Non existent ticket\n");
		goto err;
	}
		mysql_stmt_next_result(prepared_stmt);
	// Prepare output parameters
	memset(&param1, 0, sizeof(param1));
	param1.buffer_type = MYSQL_TYPE_SHORT; // OUT
	param1.buffer = &valid;
	param1.buffer_length = sizeof(valid);
	
	if(mysql_stmt_bind_result(prepared_stmt, &param1)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto err;
	}
	
	// Retrieve output parameter
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto err;
	}
	printf("%c\n", valid);
	if(valid == 1){
		printf("Ticket already used\n");
	}
	else{
		printf("Valid ticket\n");
	}


	err:
	mysql_stmt_close(prepared_stmt);
}


void run_as_controller(MYSQL *conn)
{
	char options[3] = {'1','2','3'};
	char op;
	
	printf("Switching to controller role...\n");

	if(!parse_config("users/capotreno.json", &conf)) {
		fprintf(stderr, "Unable to load controller configuration\n");
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
		printf("2) Check ticket\n");
		printf("3) Quit\n");

		op = multiChoice("Select an option", options, 3);

		switch(op) {
			case '1':
				mostra_turni(conn);
				break;
			case '2':
				controlla_biglietti(conn);
				break;
			case '3':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}
