#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

char *create_string(int max, char *title, int buffer_size){
	char *s=malloc(buffer_size);
	if(s == NULL) {
		printf("Error: malloc has failed\n");
		return NULL;
	}
	int nextIndex=0;
	for(int i=0; i<max; i++){
		printf("%s %d :", title, i+1);
		getInput(buffer_size, s+nextIndex, false);
		nextIndex = strlen(s);
		memcpy(s+nextIndex, "$", 1);
		nextIndex++;
	}
	memcpy(s+nextIndex, "\0", 1);
	return s;
}

static void add_train(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;

	// Input for the registration routine
	char char_matricola[5];
	int matricola;
	char marca[20];
	char modello[20];
	char char_num_vagoni[10];
	int num_vagoni;
	char *portata;
	char *posti;
	char *classe;

	char options[2] = {'1','2'};
	char op;

	// Get the required information
	printf("\nRegistration number: ");
	while(true){
		getInput(5, char_matricola, false);
		if(int_compare(char_matricola)) break;
		else printf("Wrong format, please try again: ");
	}
	matricola = atoi(char_matricola);
	printf("Brand: ");
	getInput(20, marca, false);
	printf("Model: ");
	getInput(20, modello, false);
	printf("Wagon number: ");
	while(true){
		getInput(10, char_num_vagoni, false);
		if(int_compare(char_num_vagoni)) break;
		else printf("Wrong format, please try again: ");
	}
	num_vagoni = atoi(char_num_vagoni);

	printf("Train type:\n1) Goods\n2) Passengers\n");
	op = multiChoice("Select: ", options, 2);
	switch(op){
		case '1':
			portata = create_string(num_vagoni, "Max carrying capacity for wagon", 150);
			
			MYSQL_BIND param[5];
			// Prepare stored procedure call
			
			if(!setup_prepared_stmt(&prepared_stmt, "call insert_treno_merci(?, ?, ?, ?, ?)", conn)) {
				finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize train insertion statement\n", false);
			}
			// Prepare parameters
			memset(param, 0, sizeof(param));

			param[0].buffer_type = MYSQL_TYPE_LONG;
			param[0].buffer = &matricola;
			param[0].buffer_length = sizeof(matricola);

			param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
			param[1].buffer = marca;
			param[1].buffer_length = strlen(marca);

			param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
			param[2].buffer = modello;
			param[2].buffer_length = strlen(modello);

			param[3].buffer_type = MYSQL_TYPE_LONG;
			param[3].buffer = &num_vagoni;
			param[3].buffer_length = sizeof(num_vagoni);

			param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
			param[4].buffer = portata;
			param[4].buffer_length = strlen(portata);
			
			if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
				finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for train insertion\n", true);
			}
			break;
		case '2':
			posti = create_string(num_vagoni, "Seats number for wagon", 50);
			classe = create_string(num_vagoni, "Class for wagon", 50);
			printf("%s\n", classe);
			MYSQL_BIND param1[6];
			// Prepare stored procedure call
			
			if(!setup_prepared_stmt(&prepared_stmt, "call insert_treno_passeggeri(?, ?, ?, ?, ?, ?)", conn)) {
				finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize train insertion statement\n", false);
			}
			// Prepare parameters
			memset(param1, 0, sizeof(param1));

			param1[0].buffer_type = MYSQL_TYPE_LONG;
			param1[0].buffer = &matricola;
			param1[0].buffer_length = sizeof(matricola);

			param1[1].buffer_type = MYSQL_TYPE_VAR_STRING;
			param1[1].buffer = marca;
			param1[1].buffer_length = strlen(marca);

			param1[2].buffer_type = MYSQL_TYPE_VAR_STRING;
			param1[2].buffer = modello;
			param1[2].buffer_length = strlen(modello);

			param1[3].buffer_type = MYSQL_TYPE_LONG;
			param1[3].buffer = &num_vagoni;
			param1[3].buffer_length = sizeof(num_vagoni);

			param1[4].buffer_type = MYSQL_TYPE_VAR_STRING;
			param1[4].buffer = posti;
			param1[4].buffer_length = strlen(posti);

			param1[5].buffer_type = MYSQL_TYPE_VAR_STRING;
			param1[5].buffer = classe;
			param1[5].buffer_length = strlen(classe);

			if (mysql_stmt_bind_param(prepared_stmt, param1) != 0) {
				finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for train insertion\n", true);
			}
			break;
		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
	}
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while adding the train.");
	} else {
		printf("Train correctly added...\n");
	}
	
	mysql_stmt_close(prepared_stmt);
}

static void add_employee(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[6];

	char option[2] = {'1', '2'};
	// Input for the registration routine
	char cf[17];
	char name[20];
	char surname[20];
	char char_data[11];
	MYSQL_TIME data;
	char luogo[30];
	char char_ruolo;
	int ruolo;

	// Get the required information
	printf("\nEmployee cf: ");
	getInput(17, cf, false);
	printf("Employee name: ");
	getInput(20, name, false);
	printf("Employee surname: ");
	getInput(20, surname, false);
	printf("Employee birth date(yyyy-mm-dd): ");
	while(true){
		getInput(11, char_data, false);
		if(date_compare(char_data)) break;
		else printf("Wrong format, try again: ");
	}
	parse_date(char_data, &data);
	printf("Employee birth place: ");
	getInput(30, luogo, false);
	printf("Employee role:\n1)Macchinista\n2)Capotreno\n");
	char_ruolo=multiChoice("Select:", option, 2);
	if (char_ruolo == '1') ruolo = 0;
	else if(char_ruolo == '2') ruolo = 1;
	else {
		printf("Invalid option\n");
		abort();
	}


	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call insert_lavoratore(?, ?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize employee insertion statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = name;
	param[1].buffer_length = strlen(name);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = surname;
	param[2].buffer_length = strlen(surname);

	param[3].buffer_type = MYSQL_TYPE_DATE;
	param[3].buffer = &data;
	param[3].buffer_length = sizeof(MYSQL_TIME);

	param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[4].buffer = luogo;
	param[4].buffer_length= strlen(luogo);

	param[5].buffer_type = MYSQL_TYPE_SHORT;
	param[5].buffer = &ruolo;
	param[5].buffer_length = sizeof(ruolo);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for employee insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while adding the employee.");
		goto out;
	}

	printf("Employee correctly added...\n");

    out:
	mysql_stmt_close(prepared_stmt);
}

static void create_user(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	char options[4] = {'1','2', '3', '4'};
	char r;

	// Input for the registration routine
	char username[17];
	char password[20];
	char ruolo[20];

	// Get the required information
	printf("\nUsername: ");
	getInput(17, username, false);
	printf("password: ");
	getInput(20, password, true);
	printf("Assign a possible role:\n");
	printf("\t1) Driver\n");
	printf("\t2) Controller\n");
	printf("\t3) Administrator\n");
	printf("\t4) Maintainer\n");
	r = multiChoice("Select role", options, 4);

	// Convert role into enum value
	switch(r) {
		case '1':
			strcpy(ruolo, "MACCHINISTA");
			break;
		case '2':
			strcpy(ruolo, "CAPOTRENO");
			break;
		case '3':
			strcpy(ruolo, "AMMINISTRATORE");
			break;
		case '4':
			strcpy(ruolo, "MANUTENTORE");
			break;
		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
	}

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call insert_utente(?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize user insertion statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = username;
	param[0].buffer_length = strlen(username);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = password;
	param[1].buffer_length = strlen(password);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = ruolo;
	param[2].buffer_length = strlen(ruolo);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for user insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while adding the user.");
	} else {
		printf("User correctly added...\n");
	}

	mysql_stmt_close(prepared_stmt);
}

static void assign_train(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];

	// Input for the registration routine
	char char_matricola[5];
	char char_id_tratta[20];
	int matricola;
	int tratta;

	// Get the required information
	printf("\nTrain: ");
	while(true){
		getInput(5, char_matricola, false);
		if(int_compare(char_matricola)) break;
		else printf("Wrong format, try again: ");
	}
	matricola = atoi(char_matricola);
	printf("Route: ");
	while(true){
		getInput(20, char_id_tratta, false);
		if(int_compare(char_id_tratta)) break;
		else printf("Wrong format, try again: ");
	}
	tratta = atoi(char_id_tratta);

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call assign_train(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize train assignment statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tratta;
	param[0].buffer_length = sizeof(tratta);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &matricola;
	param[1].buffer_length = sizeof(matricola);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for train assigment\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while assigning the train.");
		goto out;
	}

	printf("Train correctly assigned...\n");

    out:
	mysql_stmt_close(prepared_stmt);
}

static void insert_shift(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];

	// Input for the registration routine
	char cf[17];
	char char_data[11];
	MYSQL_TIME data;
	char char_inizio[6];
	char *inizio;
	char char_fine[6];
	char *fine;
	char char_matricola[5];
	int matricola;

	// Get the required information
	printf("\nEmployee cf: ");
	getInput(17, cf, false);
	printf("Date(yyyy-mm-dd): ");
	while(true){
		getInput(11, char_data, false);
		if(date_compare(char_data)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Start time(hh:mm): ");
	while(true){
		getInput(6, char_inizio, false);
		if(time_compare(char_inizio)) break;
		else printf("Wrong format, try again: ");
	}
	printf("End time(hh-mm): ");
	while(true){
		getInput(6, char_fine, false);
		if(time_compare(char_fine)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Train: ");
	while(true){
		getInput(5, char_matricola, false);
		if(int_compare(char_matricola)) break;
		else printf("Wrong format, try again: ");
	}
	// Convert values
	parse_date(char_data, &data);
	inizio = parse_time(char_inizio);
	fine = parse_time(char_fine);
	matricola = atoi(char_matricola);

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call insert_turno(?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize shift insert statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);

	param[1].buffer_type = MYSQL_TYPE_DATE;
	param[1].buffer = &data;
	param[1].buffer_length = sizeof(MYSQL_TIME);

	param[2].buffer_type = MYSQL_TYPE_STRING;
	param[2].buffer = inizio;
	param[2].buffer_length = strlen(inizio);

	param[3].buffer_type = MYSQL_TYPE_STRING;
	param[3].buffer = fine;
	param[3].buffer_length = strlen(fine);

	param[4].buffer_type = MYSQL_TYPE_LONG;
	param[4].buffer = &matricola;
	param[4].buffer_length = sizeof(matricola);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for shift insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while inserting the shift.");
	} else {
		printf("Shift correctly inserted...\n");
	}

	mysql_stmt_close(prepared_stmt);
}

static void replace_shift(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];

	// Input for the registration routine
	char cf[17];
	char char_data[11];
	MYSQL_TIME data;

	// Get the required information
	printf("\nEmployee that needs replacement cf: ");
	getInput(17, cf, false);
	printf("Date(yyyy-mm-dd): ");
	while(true){
		getInput(11, char_data, false);
		if(date_compare(char_data)) break;
		else printf("Wrong format, try again: ");
	}
	
	// Convert values
	parse_date(char_data, &data);

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call sostituisci_turno(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize shift replacement statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);

	param[1].buffer_type = MYSQL_TYPE_DATE;
	param[1].buffer = &data;
	param[1].buffer_length = sizeof(MYSQL_TIME);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for shift replacement\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while replacing the shift.");
	} else {
		printf("Shift correctly updated...\n");
	}

	mysql_stmt_close(prepared_stmt);
}

static void insert_travel(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];

	// Input for the registration routine
	char char_tratta[20];
	int tratta;
	char char_data[11];
	MYSQL_TIME data;
	char char_treno[5];
	int treno;
	int num_fermate;
	char *oraPartenza;
	char *oraArrivo;

	// Get the required information
	printf("\nRoute: ");
	while(true){
		getInput(5, char_tratta, false);
		if(int_compare(char_tratta)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Date(yyyy-mm-dd): ");
	while(true){
		getInput(11, char_data, false);
		if(date_compare(char_data)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Train: ");
	while(true){
		getInput(20, char_treno, false);
		if(int_compare(char_treno)) break;
		else printf("Wrong format, try again: ");
	}

	// Convert values
	tratta = atoi(char_tratta);
	parse_date(char_data, &data);
	treno = atoi(char_treno);

	//ricava il numero di fermate
	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tratta;
	param[0].buffer_length = sizeof(tratta);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &num_fermate;
	param[1].buffer_length = sizeof(num_fermate);

	if(!setup_prepared_stmt(&prepared_stmt, "call num_fermate(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize retrieve stops number statement\n", false);
	}

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for stops number\n", true);
	}
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving stops number.");
		goto out;
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &num_fermate;
	param[0].buffer_length = sizeof(num_fermate);
	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto out;
	}
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto out;
	}
	mysql_stmt_close(prepared_stmt);

	oraPartenza = create_string(num_fermate, "Departure time for stop", 150);
	oraArrivo = create_string(num_fermate, "Arrival time for stop", 150);


	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call insert_viaggio(?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize travel insert statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tratta;
	param[0].buffer_length = sizeof(tratta);

	param[1].buffer_type = MYSQL_TYPE_DATE;
	param[1].buffer = &data;
	param[1].buffer_length = sizeof(MYSQL_TIME);

	param[2].buffer_type = MYSQL_TYPE_LONG;
	param[2].buffer = &treno;
	param[2].buffer_length = sizeof(treno);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = oraPartenza;
	param[3].buffer_length = strlen(oraPartenza);

	param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[4].buffer = oraArrivo;
	param[4].buffer_length = strlen(oraArrivo);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for travel insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while inserting the travel.");
	} else {
		printf("Travel correctly inserted...\n");
	}
	out:
	mysql_stmt_close(prepared_stmt);
}

static void insert_goods(MYSQL *conn)
{
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[7];

	// Input for the registration routine
	char tipo[30];
	char char_massa[6];
	int massa;
	char provenienza[12];
	char direzione[12];
	char char_tratta[20];
	int tratta;
	char char_data[11];
	MYSQL_TIME data;
	char char_ora[6];
	char *ora;

	// Get the required information
	printf("\nGoods type: ");
	getInput(30, tipo, false);
	printf("Goods mass: ");
	while(true){
		getInput(6, char_massa, false);
		if(int_compare(char_massa)) break;
		else printf("Wrong format, try again: ");
	}
	printf("From: ");
	getInput(12, provenienza, false);
	printf("To: ");
	getInput(12, direzione, false);
	printf("Route: ");
	while(true){
		getInput(20, char_tratta, false);
		if(int_compare(char_tratta)) break;
		else printf("Wrong format, try again: ");
	}	
	printf("Date(yyyy-mm-dd): ");
	while(true){
		getInput(11, char_data, false);
		if(date_compare(char_data)) break;
		else printf("Wrong format, try again: ");
	}
	printf("Time(hh:mm): ");
	while(true){
		getInput(6, char_ora, false);
		if(time_compare(char_ora)) break;
		else printf("Wrong format, try again: ");
	}
	
	// Convert values
	massa = atoi(char_massa);
	tratta = atoi(char_tratta);
	parse_date(char_data, &data);
	ora = parse_time(char_ora);

	// Prepare stored procedure call
	if(!setup_prepared_stmt(&prepared_stmt, "call insert_merce(?, ?, ?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize goods insertion statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = tipo;
	param[0].buffer_length = strlen(tipo);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &massa;
	param[1].buffer_length = sizeof(massa);	

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = provenienza;
	param[2].buffer_length = strlen(provenienza);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = direzione;
	param[3].buffer_length = strlen(direzione);

	param[4].buffer_type = MYSQL_TYPE_LONG;
	param[4].buffer = &tratta;
	param[4].buffer_length = sizeof(tratta);

	param[5].buffer_type = MYSQL_TYPE_DATE;
	param[5].buffer = &data;
	param[5].buffer_length = sizeof(MYSQL_TIME);

	param[6].buffer_type = MYSQL_TYPE_STRING;
	param[6].buffer = ora;
	param[6].buffer_length = strlen(ora);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for goods insertion\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while inserting the goods.");
	} else {
		printf("Goods correctly inserted...\n");
	}

	mysql_stmt_close(prepared_stmt);
}

void run_as_administrator(MYSQL *conn)
{
	char options[9] = {'1','2', '3', '4', '5', '6', '7', '8', '9'};
	char op;
	
	printf("Switching to administrative role...\n");

	if(!parse_config("users/amministratore.json", &conf)) {
		fprintf(stderr, "Unable to load administrator configuration\n");
		exit(EXIT_FAILURE);
	}

	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while(true) {
		printf("\033[2J\033[H");
		printf("*** What should I do for you? ***\n\n");
		printf("1) Add new train\n");
		printf("2) Add new employee\n");
		printf("3) Create new user\n");
		printf("4) Assign train to route\n");
		printf("5) Insert shift\n");
		printf("6) Replace shift\n");
		printf("7) Add new travel\n");
		printf("8) Add goods and assign them to a travel\n");
		printf("9) Quit\n");

		op = multiChoice("Select an option", options, 9);

		switch(op) {
			case '1':
				add_train(conn);
				break;
			case '2':
				add_employee(conn);
				break;
			case '3':
				create_user(conn);
				break;
			case '4':
				assign_train(conn);
				break;
			case '5':
				insert_shift(conn);
				break;
			case '6':
				replace_shift(conn);
				break;
			case '7':
				insert_travel(conn);
				break;
			case '8':
				insert_goods(conn);
				break;
			case '9':
				return;	
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}
