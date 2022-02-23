#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include "defines.h"


static void find_route(MYSQL *conn, char *p_partenza, char *c_partenza, char *p_arrivo, char *c_arrivo, MYSQL_TIME date, bool *connect) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];
	int status;
	char header[512];
	int results;

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call trova_viaggio(?,?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize search\n", false);
		*connect = false;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = p_partenza;
	param[0].buffer_length = strlen(p_partenza);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = c_partenza;
	param[1].buffer_length = strlen(c_partenza);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = p_arrivo;
	param[2].buffer_length = strlen(p_arrivo);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = c_arrivo;
	param[3].buffer_length = strlen(c_arrivo);

	param[4].buffer_type = MYSQL_TYPE_DATE;
	param[4].buffer = (char *)&date;
	param[4].buffer_length = sizeof(MYSQL_TIME);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for search\n", true);
		*connect = false;
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving the route.");
		*connect = false;
		goto out;
	}
	// We have multiple result sets here!
	do {
		// Skip OUT variables (although they are not present in the procedure...)
		if(conn->server_status & SERVER_PS_OUT_PARAMS) {
			goto next;
		}
		sprintf(header, "\nPossible routes:\n");
		dump_result_set(conn, prepared_stmt, header, &results);
		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
	    next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0){
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);
			*connect = false;
		}
		if(results == 0){
			printf("No routes found\n");
			*connect = false;
		}
		
	} while (status == 0);

    out:
	mysql_stmt_close(prepared_stmt);
}

static int select_route(MYSQL *conn, int tratta, MYSQL_TIME data, char *ora, char *provincia, char *citta, char *stazione, int classe, char *cf, char *nome,
char *cognome, MYSQL_TIME nascita, char *numero){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[13];
	int ret;
	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call prenota_biglietto(?,?,?,?,?,?,?,?,?,?,?,?,?)" , conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to book ticket\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tratta;
	param[0].buffer_length = sizeof(tratta);

	param[1].buffer_type = MYSQL_TYPE_DATE;
	param[1].buffer = &data;
	param[1].buffer_length = sizeof(MYSQL_TIME);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = provincia;
	param[2].buffer_length = strlen(provincia);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = citta;
	param[3].buffer_length = strlen(citta);

	param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[4].buffer = stazione;
	param[4].buffer_length = strlen(stazione);

	param[5].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[5].buffer = ora;
	param[5].buffer_length = strlen(ora);

	param[6].buffer_type = MYSQL_TYPE_SHORT;
	param[6].buffer = &classe;
	param[6].buffer_length = sizeof(classe);

	param[7].buffer_type = MYSQL_TYPE_STRING;
	param[7].buffer = cf;
	param[7].buffer_length = strlen(cf);

	param[8].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[8].buffer = nome;
	param[8].buffer_length = strlen(nome);

	param[9].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[9].buffer = cognome;
	param[9].buffer_length = strlen(cognome);

	param[10].buffer_type = MYSQL_TYPE_DATE;
	param[10].buffer = (char *)&nascita;
	param[10].buffer_length = sizeof(MYSQL_TIME);

	param[11].buffer_type = MYSQL_TYPE_STRING;
	param[11].buffer = numero;
	param[11].buffer_length = strlen(numero);

	param[12].buffer_type = MYSQL_TYPE_LONG; //OUT
	param[12].buffer = &ret;
	param[12].buffer_length = sizeof(ret);


	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for booking\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while searching a ticket.");
		goto out;
	}
	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[0].buffer = &ret;
	param[0].buffer_length = sizeof(ret);
	
	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto out;
	}
	
	// Retrieve output parameter
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto out;
	}
    out:
	mysql_stmt_close(prepared_stmt);
	return ret;
}

void run_as_passenger(MYSQL *conn)
{
	char options[2] = {'1','2'};
	char op;
	bool connect = true;
	//Input for find_route routine
	char p_partenza[20];
	char c_partenza[20];
	char p_arrivo[20];
	char c_arrivo[20];
	char date[11];
	char tratta[10];
	char stazione[30];
	char orario[6];
	char classe;
	MYSQL_TIME parsed_date;
	char *parsed_time;
	char cf[17];
	char nome[20];
	char cognome[20];
	char nascita[11];
	MYSQL_TIME parsed_nascita;
	char numero[17];
	int codice;

	
	printf("Redircting to booking page...\n");

	if(!parse_config("users/passeggero.json", &conf)) {
		fprintf(stderr, "Unable to load passenger configuration\n");
		exit(EXIT_FAILURE);
	}

	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while(true) {
		printf("\033[2J\033[H");
		printf("*** What should I do for you? ***\n\n");
		printf("1) Find route\n");
		printf("2) Quit\n");

		op = multiChoice("Select an option", options, 2);

		switch(op) {
			case '1':
				printf("FROM:\nprovincia\t");
				getInput(20, p_partenza, false);
				printf("città\t");
				getInput(20,c_partenza, false);
				printf("\nTO:\nprovincia\t");
				getInput(20, p_arrivo, false);
				printf("città\t");
				getInput(20, c_arrivo, false);
				printf("\nDAY(yyyy-mm-dd):\n");
				while(true){
					getInput(11, date, false);
					if(date_compare(date)) break;
					else printf("Wrong format, please try again: ");
				}
				parse_date(date, &parsed_date);
				find_route(conn, p_partenza, c_partenza, p_arrivo, c_arrivo, parsed_date, &connect);
				if(connect){
					printf("Select your favorite Tratta: ");
					while(true){
						getInput(10, tratta, false);
						if(int_compare(tratta)) break;
						else printf("Wrong format, please try again: ");
					}
					printf("From which station do you wish to leave? ");
					getInput(30, stazione, false);
					printf("Select your favorite time(hh:mm): ");
					while(true){
						getInput(6, orario, false);
						if(time_compare(orario)) break;
						else printf("Wrong format, please try again: ");
					}
					parsed_time = parse_time(orario);
					classe = multiChoice("Select class: ", options, 2);
					printf("\033[2J\033[H");

					//inserire le informazioni del passeggero
					printf("Please insert passenger informations\n");
					printf("CF: ");
					getInput(17, cf, false);
					printf("Name: ");
					getInput(20, nome, false);
					printf("Surname: ");
					getInput(20, cognome, false);
					printf("Date of birth(yyyy-mm-dd): ");
					while(true){
						getInput(11, nascita, false);
						if(date_compare(nascita)) break;
						else printf("Wrong format, please try again: ");
					}
					parse_date(nascita, &parsed_nascita);
					printf("Credit card number: ");
					getInput(17, numero, false);
					codice = select_route(conn, atoi(tratta), parsed_date, parsed_time, p_partenza, c_partenza, stazione, classe-'0', cf, nome, cognome, parsed_nascita, numero);
					printf("This is your ticket number: %d!", codice);
				}
				connect = false;
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
