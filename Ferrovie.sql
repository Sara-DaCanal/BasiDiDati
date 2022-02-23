-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Ferrovie
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema Ferrovie
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Ferrovie` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `Ferrovie` ;

-- -----------------------------------------------------
-- Table `Ferrovie`.`Azienda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Azienda` (
  `PartitaIva` CHAR(12) NOT NULL,
  `Nome` VARCHAR(20) NOT NULL,
  `Tipo` VARCHAR(4) NOT NULL,
  `Indirizzo` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`PartitaIva`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Passeggero`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Passeggero` (
  `CF_passeggero` CHAR(17) NOT NULL,
  `Nome_passeggero` VARCHAR(20) NOT NULL,
  `Cognome_passeggero` VARCHAR(20) NOT NULL,
  `Data_nascita_passeggero` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`CF_passeggero`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Veicolo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Veicolo` (
  `Id_veicolo` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Marca` VARCHAR(20) NOT NULL,
  `Modello` VARCHAR(20) NOT NULL,
  `DataAcquisto` DATE NOT NULL,
  PRIMARY KEY (`Id_veicolo`))
ENGINE = InnoDB
AUTO_INCREMENT = 14
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Tratta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Tratta` (
  `Id_tratta` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`Id_tratta`))
ENGINE = InnoDB
AUTO_INCREMENT = 301
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Treno`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Treno` (
  `Matricola` INT UNSIGNED NOT NULL,
  `Tipo` TINYINT NOT NULL,
  `Tratta` INT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`Matricola`),
  INDEX `Tratta` (`Tratta` ASC) VISIBLE,
  CONSTRAINT ``
    FOREIGN KEY (`Tratta`)
    REFERENCES `Ferrovie`.`Tratta` (`Id_tratta`)
    ON DELETE SET NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Vagone_passeggeri`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Vagone_passeggeri` (
  `Id_vagone_passeggeri` INT UNSIGNED NOT NULL,
  `Classe` SMALLINT UNSIGNED NOT NULL,
  `Treno` INT UNSIGNED NULL DEFAULT NULL,
  `Posti` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`Id_vagone_passeggeri`),
  INDEX `FK_VagonePTreno` (`Treno` ASC) VISIBLE,
  CONSTRAINT `FK_VagonePasseggeriVeicolo`
    FOREIGN KEY (`Id_vagone_passeggeri`)
    REFERENCES `Ferrovie`.`Veicolo` (`Id_veicolo`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_VagonePTreno`
    FOREIGN KEY (`Treno`)
    REFERENCES `Ferrovie`.`Treno` (`Matricola`)
    ON DELETE SET NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Viaggio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Viaggio` (
  `Tratta` INT UNSIGNED NOT NULL,
  `DataPartenza` DATE NOT NULL,
  `OraPartenza` TIME NOT NULL,
  `Treno` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`Tratta`, `DataPartenza`, `OraPartenza`),
  INDEX `FK_ViaggioTreno` (`Treno` ASC) VISIBLE,
  INDEX `Data` (`DataPartenza` ASC) VISIBLE,
  CONSTRAINT `FK_ViaggioTratta`
    FOREIGN KEY (`Tratta`)
    REFERENCES `Ferrovie`.`Tratta` (`Id_tratta`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_ViaggioTreno`
    FOREIGN KEY (`Treno`)
    REFERENCES `Ferrovie`.`Treno` (`Matricola`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Posto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Posto` (
  `Vagone` INT UNSIGNED NOT NULL,
  `Numero` SMALLINT UNSIGNED NOT NULL,
  `Occupato` TINYINT NOT NULL DEFAULT '0',
  `Tratta` INT UNSIGNED NOT NULL,
  `DataViaggio` DATE NOT NULL,
  `OraViaggio` TIME NOT NULL,
  PRIMARY KEY (`Vagone`, `Numero`, `Tratta`, `DataViaggio`, `OraViaggio`),
  INDEX `Vagone` (`Vagone` ASC) VISIBLE,
  INDEX `FK_PostoViaggio_idx` (`Tratta` ASC, `DataViaggio` ASC, `OraViaggio` ASC) VISIBLE,
  CONSTRAINT `FK_PostoVagone`
    FOREIGN KEY (`Vagone`)
    REFERENCES `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_PostoViaggio`
    FOREIGN KEY (`Tratta` , `DataViaggio` , `OraViaggio`)
    REFERENCES `Ferrovie`.`Viaggio` (`Tratta` , `DataPartenza` , `OraPartenza`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Biglietto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Biglietto` (
  `Codice_prenotazione` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CF_passeggero` CHAR(17) NOT NULL,
  `NumeroCartaCredito` CHAR(17) NOT NULL,
  `Utilizzato` TINYINT NOT NULL DEFAULT '0',
  `VagonePosto` INT UNSIGNED NOT NULL,
  `NumeroPosto` SMALLINT UNSIGNED NOT NULL,
  `TrattaViaggio` INT UNSIGNED NOT NULL,
  `DataViaggio` DATE NOT NULL,
  `OraViaggio` TIME NOT NULL,
  PRIMARY KEY (`Codice_prenotazione`),
  INDEX `FK_BigliettoPasseggero_idx` (`CF_passeggero` ASC) VISIBLE,
  INDEX `BigliettoViaggio` (`TrattaViaggio` ASC, `DataViaggio` ASC, `OraViaggio` ASC) VISIBLE,
  INDEX `FK_BigliettoPosto` (`VagonePosto` ASC, `NumeroPosto` ASC, `TrattaViaggio` ASC, `DataViaggio` ASC, `OraViaggio` ASC) VISIBLE,
  CONSTRAINT `FK_BigliettoPasseggero`
    FOREIGN KEY (`CF_passeggero`)
    REFERENCES `Ferrovie`.`Passeggero` (`CF_passeggero`),
  CONSTRAINT `FK_BigliettoPosto`
    FOREIGN KEY (`VagonePosto` , `NumeroPosto` , `TrattaViaggio` , `DataViaggio` , `OraViaggio`)
    REFERENCES `Ferrovie`.`Posto` (`Vagone` , `Numero` , `Tratta` , `DataViaggio` , `OraViaggio`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 17
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Fermata`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Fermata` (
  `Provincia` VARCHAR(20) NOT NULL,
  `Citta` VARCHAR(20) NOT NULL,
  `Stazione` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`Provincia`, `Citta`, `Stazione`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Composizione_tratta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Composizione_tratta` (
  `Tratta` INT UNSIGNED NOT NULL,
  `ProvinciaFermata` VARCHAR(20) NOT NULL,
  `CittaFermata` VARCHAR(20) NOT NULL,
  `StazioneFermata` VARCHAR(30) NOT NULL,
  `Ordine` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Tratta`),
  INDEX `FK_TrattaComposizione` (`Tratta` ASC) VISIBLE,
  INDEX `FK_FermataComposizione` (`ProvinciaFermata` ASC, `CittaFermata` ASC, `StazioneFermata` ASC) VISIBLE,
  CONSTRAINT `FK_FermataComposizione`
    FOREIGN KEY (`ProvinciaFermata` , `CittaFermata` , `StazioneFermata`)
    REFERENCES `Ferrovie`.`Fermata` (`Provincia` , `Citta` , `Stazione`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_TrattaComposizione`
    FOREIGN KEY (`Tratta`)
    REFERENCES `Ferrovie`.`Tratta` (`Id_tratta`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Fermare`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Fermare` (
  `Tratta` INT UNSIGNED NOT NULL,
  `DataViaggio` DATE NOT NULL,
  `OraViaggio` TIME NOT NULL,
  `ProvinciaFermata` VARCHAR(20) NOT NULL,
  `CittaFermata` VARCHAR(20) NOT NULL,
  `StazioneFermata` VARCHAR(30) NOT NULL,
  `OraPartenza` TIME NULL DEFAULT NULL,
  `OraArrivo` TIME NULL DEFAULT NULL,
  PRIMARY KEY (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`),
  UNIQUE INDEX `Tratta` (`Tratta` ASC, `DataViaggio` ASC, `ProvinciaFermata` ASC, `CittaFermata` ASC, `StazioneFermata` ASC, `OraPartenza` ASC) VISIBLE,
  INDEX `FK_FermareViaggio` (`Tratta` ASC, `DataViaggio` ASC, `OraViaggio` ASC) VISIBLE,
  INDEX `FK_FermareFermata` (`ProvinciaFermata` ASC, `CittaFermata` ASC, `StazioneFermata` ASC) VISIBLE,
  CONSTRAINT `FK_FermareFermata`
    FOREIGN KEY (`ProvinciaFermata` , `CittaFermata` , `StazioneFermata`)
    REFERENCES `Ferrovie`.`Fermata` (`Provincia` , `Citta` , `Stazione`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_FermareViaggio`
    FOREIGN KEY (`Tratta` , `DataViaggio` , `OraViaggio`)
    REFERENCES `Ferrovie`.`Viaggio` (`Tratta` , `DataPartenza` , `OraPartenza`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Lavoratore`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Lavoratore` (
  `CF` CHAR(17) NOT NULL,
  `Nome` VARCHAR(20) NOT NULL,
  `Cognome` VARCHAR(20) NOT NULL,
  `DataNascita` DATE NULL DEFAULT NULL,
  `LuogoNascita` VARCHAR(30) NULL DEFAULT NULL,
  `Ruolo` TINYINT NOT NULL,
  PRIMARY KEY (`CF`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Locomotrice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Locomotrice` (
  `Id_locomotrice` INT UNSIGNED NOT NULL,
  `Treno` INT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`Id_locomotrice`),
  UNIQUE INDEX `Treno` (`Treno` ASC) VISIBLE,
  CONSTRAINT `FK_LocomotriceTreno`
    FOREIGN KEY (`Treno`)
    REFERENCES `Ferrovie`.`Treno` (`Matricola`)
    ON DELETE SET NULL,
  CONSTRAINT `FK_LocomotriceVeicolo`
    FOREIGN KEY (`Id_locomotrice`)
    REFERENCES `Ferrovie`.`Veicolo` (`Id_veicolo`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Vagone_merci`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Vagone_merci` (
  `Id_vagone_merci` INT UNSIGNED NOT NULL,
  `Portata` SMALLINT UNSIGNED NOT NULL,
  `Treno` INT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`Id_vagone_merci`),
  INDEX `FK_VagoneMTreno` (`Treno` ASC) VISIBLE,
  CONSTRAINT `FK_VagoneMerciVeicolo`
    FOREIGN KEY (`Id_vagone_merci`)
    REFERENCES `Ferrovie`.`Veicolo` (`Id_veicolo`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_VagoneMTreno`
    FOREIGN KEY (`Treno`)
    REFERENCES `Ferrovie`.`Treno` (`Matricola`)
    ON DELETE SET NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Merce`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Merce` (
  `Id_merce` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Tipo` VARCHAR(30) NOT NULL,
  `Massa` INT UNSIGNED NOT NULL,
  `Vagone` INT UNSIGNED NULL DEFAULT NULL,
  `Provenienza` CHAR(12) NULL DEFAULT NULL,
  `Direzione` CHAR(12) NULL DEFAULT NULL,
  `Viaggio` INT UNSIGNED NULL DEFAULT NULL,
  `DataViaggio` DATE NULL DEFAULT NULL,
  `OraViaggio` TIME NULL DEFAULT NULL,
  PRIMARY KEY (`Id_merce`),
  INDEX `FK_ViaggioMerce` (`Viaggio` ASC, `DataViaggio` ASC, `OraViaggio` ASC) VISIBLE,
  INDEX `FK_AziendaMerce1_idx` (`Provenienza` ASC) VISIBLE,
  INDEX `FK_AziendaMerce2_idx` (`Direzione` ASC) VISIBLE,
  INDEX `FK_VagoneMerce_idx` (`Vagone` ASC) VISIBLE,
  CONSTRAINT `FK_AziendaMerce1`
    FOREIGN KEY (`Provenienza`)
    REFERENCES `Ferrovie`.`Azienda` (`PartitaIva`)
    ON DELETE SET NULL,
  CONSTRAINT `FK_AziendaMerce2`
    FOREIGN KEY (`Direzione`)
    REFERENCES `Ferrovie`.`Azienda` (`PartitaIva`)
    ON DELETE SET NULL,
  CONSTRAINT `FK_VagoneMerce`
    FOREIGN KEY (`Vagone`)
    REFERENCES `Ferrovie`.`Vagone_merci` (`Id_vagone_merci`)
    ON DELETE SET NULL,
  CONSTRAINT `FK_ViaggioMerce`
    FOREIGN KEY (`Viaggio` , `DataViaggio` , `OraViaggio`)
    REFERENCES `Ferrovie`.`Viaggio` (`Tratta` , `DataPartenza` , `OraPartenza`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Report_di_manutenzione`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Report_di_manutenzione` (
  `Id_veicolo` INT UNSIGNED NOT NULL,
  `DataManutenzione` DATE NOT NULL,
  `Testo` VARCHAR(2048) NOT NULL,
  PRIMARY KEY (`Id_veicolo`, `DataManutenzione`),
  CONSTRAINT `FK_ReportVeicolo`
    FOREIGN KEY (`Id_veicolo`)
    REFERENCES `Ferrovie`.`Veicolo` (`Id_veicolo`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Turno`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Turno` (
  `LavoratoreAssegnato` CHAR(17) NOT NULL,
  `DataTurno` DATE NOT NULL,
  `OraInizio` TIME NOT NULL,
  `OraFine` TIME NOT NULL,
  `Treno` INT UNSIGNED NOT NULL,
  `LavoratoreSvolto` CHAR(17) NULL DEFAULT NULL,
  PRIMARY KEY (`LavoratoreAssegnato`, `DataTurno`),
  INDEX `FK_TurnoTreno` (`Treno` ASC) VISIBLE,
  INDEX `Data` (`DataTurno` ASC) VISIBLE,
  INDEX `FK_LavoratoreTurno1` (`LavoratoreAssegnato` ASC) VISIBLE,
  INDEX `FK_TurnoLavoratore2_idx` (`LavoratoreSvolto` ASC) VISIBLE,
  CONSTRAINT `FK_TurnoLavoratore1`
    FOREIGN KEY (`LavoratoreAssegnato`)
    REFERENCES `Ferrovie`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_TurnoLavoratore2`
    FOREIGN KEY (`LavoratoreSvolto`)
    REFERENCES `Ferrovie`.`Lavoratore` (`CF`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_TurnoTreno`
    FOREIGN KEY (`Treno`)
    REFERENCES `Ferrovie`.`Treno` (`Matricola`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `Ferrovie`.`Utenti`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`Utenti` (
  `Username` VARCHAR(20) NOT NULL,
  `U_password` VARCHAR(20) NOT NULL,
  `Ruolo` ENUM('amministratore', 'macchinista', 'capotreno', 'manutentore') NOT NULL,
  PRIMARY KEY (`Username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `Ferrovie` ;

-- -----------------------------------------------------
-- Placeholder table for view `Ferrovie`.`week_turno`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`week_turno` (`LavoratoreAssegnato` INT, `dataTurno` INT, `Settimana` INT);

-- -----------------------------------------------------
-- Placeholder table for view `Ferrovie`.`occupazione_vagoni_merci`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Ferrovie`.`occupazione_vagoni_merci` (`Data` INT, `Ora` INT, `Vagone` INT);

-- -----------------------------------------------------
-- function SPLIT
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT`(portata VARCHAR(500), count INT) RETURNS int
    NO SQL
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE start INT DEFAULT 0;
    DECLARE end INT ;
    SET end = LOCATE('$', portata);
	WHILE i < count DO
		SET start = end;
		SET end = LOCATE('$', portata, start+1);
        SET i = i+1;
	END WHILE;
    SET start = start+1;
    SET end = end-start;
	RETURN CONVERT(SUBSTRING(portata, start, end), UNSIGNED INT);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function SPLIT_STRING
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT_STRING`(s VARCHAR(500), count INT) RETURNS varchar(30) CHARSET utf8mb4
    NO SQL
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE start INT DEFAULT 0;
    DECLARE end INT ;
    SET end = LOCATE('$', s);
	WHILE i < count DO
		SET start = end;
		SET end = LOCATE('$', s, start+1);
        SET i = i+1;
	END WHILE;
    SET start = start+1;
    SET end = end-start;
	RETURN SUBSTRING(s, start, end);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assign_train
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `assign_train`(IN var_tratta INT, IN var_treno INT)
BEGIN
	UPDATE Treno SET Tratta = var_tratta WHERE Matricola = var_treno;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure controllo_biglietti
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `controllo_biglietti`(IN var_codice INT, OUT var_valido TINYINT(1))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;
		SELECT CF_passeggero as Passeggero, TrattaViaggio, DataViaggio AS Data, VagonePosto as Vagone, NumeroPosto AS Posto
		FROM Biglietto
		WHERE Codice_prenotazione = var_codice;
		SELECT Utilizzato FROM Biglietto WHERE Codice_prenotazione = var_codice
		INTO var_valido;
		UPDATE Biglietto SET Utilizzato = 1 WHERE Codice_prenotazione = var_codice;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_azienda
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_azienda`(IN var_p_iva CHAR(11))
BEGIN
	DELETE FROM Azienda WHERE PartitaIva = var_p_iva;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_fermata
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_fermata`(IN var_prov VARCHAR(20), IN var_citta VARCHAR(20), IN var_staz VARCHAR(30))
BEGIN
	DELETE FROM Fermata WHERE Provincia = var_prov AND Citta = var_citta AND Stazione = var_staz;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_lavoratore
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_lavoratore`(IN var_cf CHARACTER(16))
BEGIN
	DELETE FROM Lavoratore WHERE CF = var_cf;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_tratta
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_tratta`(IN var_id INT)
BEGIN
	DELETE FROM Tratta WHERE Id_tratta = var_id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_treno
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_treno`(IN var_matricola INT)
BEGIN
	DELETE FROM Treno WHERE Matricola = var_matricola;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_veicolo
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_veicolo`(IN var_id INT, IN var_tipo INT)
BEGIN
	IF var_tipo = 1 THEN
		DELETE FROM Locomotrice WHERE Id_locomotrice = var_id;
	ELSEIF var_tipo = 2 THEN
		DELETE FROM Vagone_merci WHERE Id_vagone_merci = var_id;
	ELSEIF var_tipo = 3 THEN
		DELETE FROM Vagone_passeggeri WHERE Id_vagone_passeggeri = var_id;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_azienda
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_azienda`(IN var_P_iva CHAR(11), IN var_nome VARCHAR(20), IN var_tipo VARCHAR(4), IN var_indirizzo VARCHAR(50))
BEGIN
	INSERT INTO Azienda values (var_P_iva, var_nome, var_tipo, var_indirizzo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_fermata
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_fermata`(IN var_prov VARCHAR(20), IN var_citta VARCHAR(20), IN var_staz VARCHAR(30))
BEGIN
	INSERT INTO Fermata VALUES (var_prov, var_citta, var_staz);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_lavoratore
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_lavoratore`(IN var_cf CHARACTER(17), IN var_nome VARCHAR(20), IN var_cognome VARCHAR(20), IN var_data DATE, IN var_luogo VARCHAR(30), IN var_ruolo BOOL)
BEGIN
	INSERT INTO Lavoratore VALUES (var_cf, var_nome, var_cognome, var_data, var_luogo, var_ruolo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_merce
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_merce`(IN var_tipo VARCHAR(30), IN var_massa INT, IN var_prov CHAR(12), IN var_arr CHAR(12), IN var_tratta INT, IN var_data DATE, IN var_ora TIME)
BEGIN
	DECLARE idvagone INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    START TRANSACTION;
		SELECT Id_vagone_merci FROM Vagone_merci as Vagone JOIN Treno on Vagone.Treno = Treno.Matricola
        JOIN Viaggio ON Treno.Matricola = Viaggio.Treno
        WHERE Viaggio.Tratta = var_tratta AND Viaggio.DataPartenza = var_data AND Viaggio.OraPartenza = var_ora
        AND Vagone.Portata <= var_massa AND id_vagone_merci NOT IN (SELECT Vagone 
																	FROM occupazione_vagoni_merci
                                                                    WHERE Data = var_data AND Ora = var_ora)
        LIMIT 1 INTO idvagone;
        INSERT INTO Merce (Tipo, Massa, Vagone, Provenienza, Direzione, Viaggio, DataViaggio, OraViaggio) 
        values (var_tipo, var_massa, idvagone, var_prov, var_arr, var_tratta, var_data, var_ora);
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_report
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_report`(IN var_testo varchar(2048), IN var_id INT)
BEGIN
	INSERT INTO Report_di_manutenzione VALUES (var_id, DATE(NOW()), var_testo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_tratta
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_tratta`(IN var_provincia VARCHAR(500),IN var_citta VARCHAR(500), IN var_stazione VARCHAR(750), IN var_num INT)
BEGIN
	DECLARE count INT DEFAULT 0;
    DECLARE id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    START TRANSACTION;
		SELECT MAX(Id_tratta) FROM Tratta INTO id;
        IF id IS NULL THEN SET id = 100;
        ELSE SET id = id + 100;
        END IF;
		INSERT INTO Tratta values(id);
        WHILE count < var_num DO
			INSERT INTO Composizione_tratta values (id, SPLIT_STRING(var_provincia, count), SPLIT_STRING(var_citta, count), SPLIT_STRING(var_stazione, count), count +1);
            SET count = count +1;
		END WHILE;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_treno_merci
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_treno_merci`(IN Var_matricola INTEGER, IN Var_marca VARCHAR(20), IN Var_modello VARCHAR(20), IN var_num_vagoni INT, IN var_portata VARCHAR(150))
BEGIN
	DECLARE count INT default 0;
    DECLARE p INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any changes made in the transaction
        RESIGNAL;  -- raise again the sql exception to the caller
    END;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	START TRANSACTION;
		INSERT INTO Treno (Matricola, Tipo) values (Var_matricola, 0);
        INSERT INTO Veicolo (Marca, Modello, DataAcquisto) values (Var_marca, Var_modello, DATE(NOW()));
        INSERT INTO Locomotrice values (LAST_INSERT_ID(), Var_matricola);
        WHILE count < var_num_vagoni DO
			SET p = SPLIT(var_portata, count);
            INSERT INTO Veicolo (Marca, Modello, DataAcquisto) values (Var_marca, Var_modello, DATE(NOW()));
            INSERT INTO Vagone_merci VALUES (LAST_INSERT_ID(), p, Var_matricola);
            SET count = count +1;
		END WHILE;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_treno_passeggeri
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_treno_passeggeri`(IN Var_matricola INTEGER, IN Var_marca VARCHAR(20), IN Var_modello VARCHAR(20), IN var_num_vagoni INT, IN var_posti VARCHAR(50), IN var_classe VARCHAR(50))
BEGIN
	DECLARE count INT default 0;
    DECLARE p INT;
    DECLARE c INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any changes made in the transaction
        RESIGNAL;  -- raise again the sql exception to the caller
    END;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	START TRANSACTION;
		INSERT INTO Treno (Matricola, Tipo) values (Var_matricola, 1);
        INSERT INTO Veicolo (Marca, Modello, DataAcquisto) values (Var_marca, Var_modello, DATE(NOW()));
        INSERT INTO Locomotrice values (LAST_INSERT_ID(), Var_matricola);
        WHILE count < var_num_vagoni DO
			SET p = SPLIT(var_posti, count);
            SET c = SPLIT(var_classe, count);
            INSERT INTO Veicolo (Marca, Modello, DataAcquisto) values (Var_marca, Var_modello, DATE(NOW()));
            INSERT INTO Vagone_passeggeri VALUES (LAST_INSERT_ID(), c, Var_matricola, p);
            SET count = count +1;
		END WHILE;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_turno
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_turno`(IN var_lavoratore CHARACTER(17), IN var_data DATE, IN var_inizio TIME, IN var_fine TIME, IN var_treno INT)
BEGIN
	INSERT INTO Turno (LavoratoreAssegnato, DataTurno, OraInizio, OraFine, Treno) 
    values (var_lavoratore, var_data, var_inizio, var_fine, var_treno);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_utente
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_utente`(IN var_user VARCHAR(17), IN var_pass VARCHAR(20), IN var_role ENUM('AMMINISTRATORE', 'MACCHINISTA', 'CAPOTRENO', 'MANUTENTORE'))
BEGIN
	INSERT INTO Utenti VALUES (var_user, var_pass, var_role);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_viaggio
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_viaggio`(IN var_tratta INT, IN var_data DATE, IN var_treno INT, IN var_oraPartenza VARCHAR(150), IN var_oraArrivo VARCHAR(150))
BEGIN
	DECLARE done INT DEFAULT False;
	DECLARE count INT DEFAULT 0;
    DECLARE num_fermate INT;
    DECLARE ora, p, a TIME;
    DECLARE prov, citt VARCHAR(20);
    DECLARE staz VARCHAR(30);
    DECLARE var_posti, var_vagone INT;
    DECLARE cur CURSOR FOR SELECT Id_vagone_passeggeri FROM Vagone_passeggeri WHERE Treno = var_treno;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;  -- rollback any changes made in the transaction
		RESIGNAL;  -- raise again the sql exception to the caller
	END;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    START TRANSACTION;
		SELECT COUNT(*) FROM Composizione_tratta WHERE Tratta = var_tratta INTO num_fermate;
        SET ora = SPLIT_STRING(var_oraPartenza, 0);
        INSERT INTO Viaggio  values (var_tratta, var_data, ora, var_treno);
        WHILE count < num_fermate DO
			IF count <> num_fermate -1 THEN 
				SET p = SPLIT_STRING(var_oraPartenza, count);
			ELSE
				SET p = NULL;
			END IF;
            IF count <> 0 THEN
				SET a = SPLIT_STRING(var_oraArrivo, count);
			ELSE
				SET a = NULL;
			END IF;
            SELECT ProvinciaFermata FROM Composizione_tratta WHERE Tratta = var_tratta AND Ordine = count+1 INTO prov;
            SELECT CittaFermata FROM Composizione_tratta WHERE Tratta = var_tratta AND Ordine = count+1 INTO citt;
            SELECT StazioneFermata FROM Composizione_tratta WHERE Tratta = var_tratta AND Ordine = count+1 INTO staz;
            INSERT INTO Fermare VALUES (var_tratta, var_data, ora, prov, citt, staz, p, a);
            SET count = count +1;
		END WHILE;
        IF (SELECT Tipo FROM Treno WHERE Matricola = var_treno) = 1 THEN
        OPEN cur;
        insert_posti: LOOP
			FETCH cur INTO var_vagone;
            IF done THEN
				LEAVE insert_posti;
			END IF;
            SET count = 0;
            SELECT Posti FROM Vagone_passeggeri WHERE Id_vagone_passeggeri = var_vagone INTO var_posti;
            WHILE count < var_posti DO
				INSERT INTO Posto values (var_vagone, count+1, 0, var_tratta, var_data, ora);
                SET count = count + 1;
			END WHILE;
		END LOOP;
	END IF;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `login`(in var_username varchar(20), in var_pass varchar(20), out var_role INT)
BEGIN
	DECLARE var_user_role ENUM('AMMINISTRATORE', 'MACCHINISTA', 'CAPOTRENO', 'MANUTENTORE');
    
	select `Ruolo` from `Utenti`
		where `Username` = var_username
        and `U_password` = var_pass
        into var_user_role;
        
        -- See the corresponding enum in the client
		if var_user_role = 'AMMINISTRATORE' then
			set var_role = 1;
		elseif var_user_role = 'MACCHINISTA' then
			set var_role = 2;
		elseif var_user_role = 'CAPOTRENO' then
			set var_role = 3;
		elseif var_user_role = 'MANUTENTORE' then
			set var_role = 4;
		else
			set var_role = 5;
		end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure num_fermate
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `num_fermate`(IN var_tratta INT, OUT var_return INT)
BEGIN
	SELECT count(*) FROM Composizione_tratta WHERE Tratta = var_tratta;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure prenota_biglietto
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prenota_biglietto`(IN var_tratta INT, IN var_data DATE, IN var_prov_fermata VARCHAR(20), IN var_citta_fermata VARCHAR(20), IN var_staz_fermata VARCHAR(30), IN var_ora TIME, IN var_classe SMALLINT, 
IN var_cf CHARACTER(17), IN var_nome VARCHAR(20), IN var_cognome VARCHAR(20), IN var_nascita DATE, IN var_num CHARACTER(17), OUT var_codice INT)
BEGIN
    DECLARE var_posto, var_vagone INT;
    DECLARE var_ora_viaggio TIME;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any changes made in the transaction
        RESIGNAL;  -- raise again the sql exception to the caller
    END;
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;
    SELECT Viaggio.OraPartenza
    FROM Viaggio JOIN Fermare ON (Viaggio.Tratta = Fermare.Tratta AND Viaggio.DataPartenza = Fermare.DataViaggio AND Fermare.OraViaggio = Viaggio.OraPartenza)
    WHERE Viaggio.Tratta = var_tratta AND Viaggio.DataPartenza = var_data AND Fermare.ProvinciaFermata = var_prov_fermata AND Fermare.CittaFermata = var_citta_fermata AND Fermare.StazioneFermata = var_staz_fermata AND Fermare.OraPartenza = var_ora
    INTO var_ora_viaggio;
    SELECT V.Id_vagone_passeggeri FROM Posto JOIN Vagone_passeggeri AS V ON Posto.Vagone = V.Id_vagone_passeggeri
	WHERE  Posto.Occupato = 0 AND V.classe = var_classe AND Posto.Tratta = var_tratta AND Posto.DataViaggio = var_data AND Posto.OraViaggio = var_ora_viaggio
	LIMIT 1 INTO var_vagone;
        IF var_vagone IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Non ci sono posti liberi';
	END IF;
    SELECT Numero FROM Posto
	WHERE  Posto.Vagone = var_vagone AND Posto.Tratta = var_tratta AND Posto.DataViaggio = var_data AND Posto.OraViaggio = var_ora_viaggio AND Posto.Occupato = 0
    LIMIT 1 INTO var_posto;

    UPDATE Posto SET Occupato = 1 WHERE Vagone = var_vagone AND Numero = var_posto and Tratta = var_tratta AND DataViaggio = var_data AND OraViaggio = var_ora_viaggio;
    INSERT IGNORE INTO Passeggero values (var_cf, var_nome, var_cognome, var_nascita);
    INSERT INTO Biglietto (CF_passeggero, NumeroCartaCredito, VagonePosto, NumeroPosto, TrattaViaggio, DataViaggio, OraViaggio)
    VALUES (var_cf, var_num, var_vagone, var_posto, var_tratta, var_data, var_ora_viaggio);
    SELECT LAST_INSERT_ID() INTO var_codice;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure sostituisci_turno
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sostituisci_turno`(IN var_lavoratore CHARACTER(17), IN var_data DATE)
BEGIN
	DECLARE var_new CHARACTER(17);
    DECLARE var_tipo BOOL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;
    SET TRANSACTION ISOLATION LEVEL serializable;
    START TRANSACTION;
		SELECT Ruolo FROM Lavoratore WHERE CF = var_lavoratore INTO var_tipo;
        SELECT Lavoratore.Cf FROM Lavoratore
        WHERE Lavoratore.Ruolo = var_tipo AND CF not in (
														SELECT LavoratoreAssegnato
                                                        FROM week_turno)
		LIMIT 1 INTO var_new;
		IF var_new IS NULL THEN
        SELECT T.LavoratoreAssegnato FROM week_turno AS T JOIN Lavoratore AS L on L.CF = T.LavoratoreAssegnato
        WHERE var_data <> T.DataTurno AND L.Ruolo = var_tipo AND L.CF <> var_lavoratore
		AND T.Settimana <> WEEK(var_data)LIMIT 1 INTO var_new;
        END IF;
        IF var_new IS NULL THEN
			SELECT T.LavoratoreAssegnato FROM week_turno as T JOIN Lavoratore as L on L.CF = T.LavoratoreAssegnato 
            WHERE var_data <> T.DataTurno AND T.Settimana = WEEK(var_data) AND L.Ruolo = var_tipo AND L.CF <> var_lavoratore
            GROUP BY T.LavoratoreAssegnato
            HAVING COUNT(T.Settimana) < 5 LIMIT 1 INTO var_new;
		END IF;
		UPDATE Turno SET LavoratoreSvolto = var_new WHERE LavoratoreAssegnato = var_lavoratore AND DataTurno = var_data;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure trova_viaggio
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `trova_viaggio`(IN var_provincia_par varchar(20), IN var_partenza varchar(20), IN var_provincia_arr varchar(20), IN var_arrivo varchar(20), IN var_data date)
BEGIN
	SELECT DISTINCT Partenza.Tratta, Partenza.DataViaggio, Partenza.OraPartenza, Partenza.StazioneFermata as Partenza, Arrivo.OraArrivo, Arrivo.StazioneFermata as Arrivo 
    FROM Fermare as Partenza JOIN Fermare AS Arrivo on (Partenza.Tratta = Arrivo.Tratta AND Partenza.DataViaggio = Arrivo.DataViaggio AND Partenza.OraViaggio = Arrivo.OraViaggio)
		JOIN Viaggio AS v ON (v.Tratta = Partenza.tratta AND v.DataPartenza = Partenza.DataViaggio)
	WHERE (Partenza.ProvinciaFermata = var_provincia_par AND Partenza.CittaFermata = var_partenza AND Arrivo.ProvinciaFermata = var_provincia_arr AND Arrivo.CittaFermata = var_arrivo
		AND var_data = v.DataPartenza AND Partenza.OraPartenza < Arrivo.OraArrivo AND v.Treno IN
			(SELECT Matricola
            FROM Treno
            WHERE Tipo = 1)
	);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_turni
-- -----------------------------------------------------

DELIMITER $$
USE `Ferrovie`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_turni`(IN var_CF CHARACTER (17))
BEGIN
	SELECT DataTurno as Data, OraInizio, OraFine, Treno
    FROM Turno WHERE (LavoratoreAssegnato = var_CF OR LavoratoreSvolto = var_CF) 
    AND WEEK(DataTurno, 0) = WEEK(NOW(), 0);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `Ferrovie`.`week_turno`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ferrovie`.`week_turno`;
USE `Ferrovie`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ferrovie`.`week_turno` AS select `ferrovie`.`turno`.`LavoratoreAssegnato` AS `LavoratoreAssegnato`,`ferrovie`.`turno`.`DataTurno` AS `dataTurno`,week(`ferrovie`.`turno`.`DataTurno`,0) AS `Settimana` from `ferrovie`.`turno` where (`ferrovie`.`turno`.`LavoratoreSvolto` is null) union select `ferrovie`.`turno`.`LavoratoreSvolto` AS `LavoratoreAssegnato`,`ferrovie`.`turno`.`DataTurno` AS `DataTurno`,week(`ferrovie`.`turno`.`DataTurno`,0) AS `Settimana` from `ferrovie`.`turno` where (`ferrovie`.`turno`.`LavoratoreSvolto` is not null);

-- -----------------------------------------------------
-- View `Ferrovie`.`occupazione_vagoni_merci`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ferrovie`.`occupazione_vagoni_merci`;
USE `Ferrovie`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ferrovie`.`occupazione_vagoni_merci` AS select `ferrovie`.`merce`.`DataViaggio` AS `Data`,`ferrovie`.`merce`.`OraViaggio` AS `Ora`,`ferrovie`.`merce`.`Vagone` AS `Vagone` from `ferrovie`.`merce`;
USE `Ferrovie`;

DELIMITER $$
USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Vagone_passeggeri_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Vagone_passeggeri`
FOR EACH ROW
BEGIN
	DECLARE tipotreno BOOL;
    	SELECT Tipo FROM Treno
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
    	IF tipotreno <> 1 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Vagone_passeggeri_BEFORE_UPDATE`
BEFORE UPDATE ON `Ferrovie`.`Vagone_passeggeri`
FOR EACH ROW
BEGIN
	DECLARE tipotreno BOOL;
    	SELECT Tipo FROM Treno
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
    	IF tipotreno <> 1 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Viaggio_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Viaggio`
FOR EACH ROW
BEGIN
	IF NEW.Treno NOT IN (SELECT Treno.Matricola
						FROM Treno
						WHERE Treno.Tratta = NEW.Tratta) THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Fermare_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Fermare`
FOR EACH ROW
BEGIN
	IF (NEW.ProvinciaFermata, NEW.CittaFermata, NEW.StazioneFermata) NOT IN
		(SELECT ProvinciaFermata, CittaFermata, StazioneFermata
        		FROM Composizione_tratta WHERE Composizione_tratta.Tratta = NEW.Tratta) 
THEN
			SIGNAL SQLSTATE '45000';
END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Vagone_merci_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Vagone_merci`
FOR EACH ROW
BEGIN
	DECLARE tipotreno BOOL;
    	SELECT Tipo FROM Treno
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
    	IF tipotreno <> 0 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Vagone_merci_BEFORE_UPDATE`
BEFORE UPDATE ON `Ferrovie`.`Vagone_merci`
FOR EACH ROW
BEGIN
	DECLARE tipotreno BOOL;
    	SELECT Tipo FROM Treno
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
   	 IF tipotreno <> 0 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Merce_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Merce`
FOR EACH ROW
BEGIN
	DECLARE portatavagone SMALLINT;
    SELECT Portata FROM Vagone_merci
    WHERE Vagone_merci.Id_vagone_merci = NEW.Vagone INTO portatavagone;
    IF portatavagone < NEW.Massa THEN 
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Turno_BEFORE_INSERT`
BEFORE INSERT ON `Ferrovie`.`Turno`
FOR EACH ROW
BEGIN
	DECLARE tipotreno, ruololavoratore BOOL;
    	SELECT Treno.Tipo FROM Treno
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
    	SELECT Lavoratore.Ruolo FROM Lavoratore
    	WHERE Lavoratore.CF = NEW.LavoratoreAssegnato INTO ruololavoratore;
    	IF ruololavoratore = 1 AND tipotreno = 0 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Turno_FIVE_PER_WEEK`
BEFORE INSERT ON `Ferrovie`.`Turno`
FOR EACH ROW
BEGIN
	DECLARE nperweek INT;
	SELECT COUNT(*) FROM week_turno
    	WHERE week_turno.LavoratoreAssegnato = NEW.LavoratoreAssegnato and 
    	week_turno.Settimana = WEEK(NEW.DataTurno) INTO nperweek;
    	IF nperweek > 4 THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Turno_INTERVAL`
BEFORE INSERT ON `Ferrovie`.`Turno`
FOR EACH ROW
BEGIN
	DECLARE timeinterval TIME;
	SET timeinterval = TIMEDIFF( NEW.OraFine, NEW.OraInizio);
	IF timeinterval > '04:00:00' THEN
		SIGNAL SQLSTATE '45000';
	END IF;
END$$

USE `Ferrovie`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `Ferrovie`.`Turno_BEFORE_UPDATE`
BEFORE UPDATE ON `Ferrovie`.`Turno`
FOR EACH ROW
BEGIN
	DECLARE tipotreno, ruololavoratore BOOL;
    	SELECT Tipo FROM Treno 
    	WHERE Treno.Matricola = NEW.Treno INTO tipotreno;
    	IF tipotreno = 0 THEN
		SELECT Ruolo FROM Lavoratore
        		WHERE Lavoratore.CF = NEW.LavoratoreSvolto INTO ruololavoratore;
        		IF ruololavoratore = 1 THEN
			SIGNAL SQLSTATE '45000';
		END IF;
	END IF;
END$$

USE `Ferrovie`$$
CREATE EVENT IF NOT EXISTS `Turno_cleanup` 
ON SCHEDULE EVERY 1 MONTH STARTS '2021-01-01 00:00:00'
	ON COMPLETION PRESERVE
DO BEGIN
	DELETE FROM Turno WHERE DataTurno < DATE(NOW());
END$$

USE `Ferrovie`$$
CREATE EVENT IF NOT EXISTS `Viaggio_cleanup` 
ON SCHEDULE EVERY 1 DAY
	ON COMPLETION PRESERVE
DO BEGIN
	delete from Viaggio WHERE DataPartenza < DATE(NOW());
END$$

DELIMITER ;
CREATE USER 'LOGIN' IDENTIFIED BY 'login';
CREATE ROLE 'role_login';
GRANT 'role_login' TO 'LOGIN';
SET DEFAULT ROLE 'role_login' TO 'LOGIN';
GRANT EXECUTE ON PROCEDURE login TO 'role_login';

CREATE USER 'PASSEGGERO' IDENTIFIED BY 'passeggero';
CREATE ROLE 'role_passeggero';
GRANT 'role_passeggero' TO 'PASSEGGERO';
SET DEFAULT ROLE 'role_passeggero' TO 'PASSEGGERO';
GRANT EXECUTE ON PROCEDURE trova_viaggio TO 'role_passeggero';
GRANT EXECUTE ON PROCEDURE prenota_biglietto TO 'role_passeggero';

CREATE USER 'MACCHINISTA' IDENTIFIED BY 'macchinista';
CREATE ROLE 'role_macchinista';
GRANT 'role_macchinista' TO 'MACCHINISTA';
SET DEFAULT ROLE 'role_macchinista' TO 'MACCHINISTA';
GRANT EXECUTE ON PROCEDURE visualizza_turni TO 'role_macchinista';

CREATE USER 'CAPOTRENO' IDENTIFIED BY 'capotreno';
CREATE ROLE 'role_capotreno';
GRANT 'role_capotreno' TO 'CAPOTRENO';
SET DEFAULT ROLE 'role_capotreno' TO 'CAPOTRENO';
GRANT EXECUTE ON PROCEDURE visualizza_turni TO 'role_capotreno';
GRANT EXECUTE ON PROCEDURE controllo_biglietti TO 'role_capotreno';

CREATE USER 'MANUTENTORE' IDENTIFIED BY 'manutentore';
CREATE ROLE 'role_manutentore';
GRANT 'role_manutentore' TO 'MANUTENTORE';
SET DEFAULT ROLE 'role_manutentore' TO 'MANUTENTORE';
GRANT EXECUTE ON PROCEDURE insert_report TO 'role_manutentore';

CREATE USER 'AMMINISTRATORE' IDENTIFIED BY 'amministratore';
CREATE ROLE 'role_amministratore';
GRANT 'role_amministratore' TO 'AMMINISTRATORE';
SET DEFAULT ROLE 'role_amministratore' TO 'AMMINISTRATORE';
GRANT EXECUTE ON PROCEDURE insert_treno_merci TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_treno_passeggeri TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_turno TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE sostituisci_turno TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_lavoratore TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_utente TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE assign_train TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_merce TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE insert_viaggio TO 'role_amministratore';
GRANT EXECUTE ON PROCEDURE num_fermate TO 'role_amministratore';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Azienda`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Azienda` (`PartitaIva`, `Nome`, `Tipo`, `Indirizzo`) VALUES ('00001234567', 'Spedizioni', 'srl', 'Via Roma 120');
INSERT INTO `Ferrovie`.`Azienda` (`PartitaIva`, `Nome`, `Tipo`, `Indirizzo`) VALUES ('00009876543', 'Spedizioni 2.0', 'srl', 'Via Firenze 10');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Passeggero`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Passeggero` (`CF_passeggero`, `Nome_passeggero`, `Cognome_passeggero`, `Data_nascita_passeggero`) VALUES ('FRCVRD78B11H501K', 'Francesco', 'Verdi', '1978-02-11');
INSERT INTO `Ferrovie`.`Passeggero` (`CF_passeggero`, `Nome_passeggero`, `Cognome_passeggero`, `Data_nascita_passeggero`) VALUES ('CRLGLL89H43H678L', 'Carla', 'Gialli', '1989-06-03');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Veicolo`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (1, 'Frecciarossa', '1000', '2020-09-23');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (2, 'Frecciarossa', '1000', '2020-09-23');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (3, 'Frecciarossa', '1000', '2020-09-23');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (4, 'Frecciarossa', 'ETR 500', '2016-08-01');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (5, 'Frecciarossa', 'ETR 500', '2016-08-01');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (6, 'Frecciarossa', 'ETR 500', '2016-08-01');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (7, 'Frecciarossa', '1000', '2019-05-05');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (8, 'Frecciarossa', '1000', '2019-05-05');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (9, 'Frecciargento', 'ETR 200', '2005-09-09');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (10, 'Frecciargento', 'ETR 200', '2005-09-09');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (11, 'Frecciargento', '600', '2008-07-09');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (12, 'Frecciargento', '600', '2008-07-09');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (13, 'Frecciargento', '600', '2008-07-09');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (14, 'ADME', '550', '2001-07-16');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (15, 'ADME', '550', '2001-07-16');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (16, 'ADME', '320', '2010-12-06');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (17, 'ADME', '320', '2010-12-06');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (18, 'ADME', '320', '2010-12-06');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (19, 'WTR', 'ETR 400', '2012-11-11');
INSERT INTO `Ferrovie`.`Veicolo` (`Id_veicolo`, `Marca`, `Modello`, `DataAcquisto`) VALUES (20, 'WTR', 'ETR 400', '2012-11-11');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Tratta`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Tratta` (`Id_tratta`) VALUES (100);
INSERT INTO `Ferrovie`.`Tratta` (`Id_tratta`) VALUES (200);
INSERT INTO `Ferrovie`.`Tratta` (`Id_tratta`) VALUES (300);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Treno`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (2727, 1, 100);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (1212, 0, 100);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (4343, 1, 100);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (5656, 1, 200);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (3434, 0, 200);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (9898, 1, 300);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (2323, 1, 300);
INSERT INTO `Ferrovie`.`Treno` (`Matricola`, `Tipo`, `Tratta`) VALUES (7676, 0, 300);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Vagone_passeggeri`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (2, 1, 2727, 10);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (3, 2, 2727, 12);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (5, 2, 4343, 10);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (6, 1, 4343, 5);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (8, 1, 5656, 7);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (10, 2, 9898, 10);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (12, 2, 2323, 12);
INSERT INTO `Ferrovie`.`Vagone_passeggeri` (`Id_vagone_passeggeri`, `Classe`, `Treno`, `Posti`) VALUES (13, 1, 2323, 9);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Viaggio`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Viaggio` (`Tratta`, `DataPartenza`, `OraPartenza`, `Treno`) VALUES (100, '2021-09-13', '08:00:00', 1212);
INSERT INTO `Ferrovie`.`Viaggio` (`Tratta`, `DataPartenza`, `OraPartenza`, `Treno`) VALUES (100, '2021-09-07', '12:00:00', 4343);
INSERT INTO `Ferrovie`.`Viaggio` (`Tratta`, `DataPartenza`, `OraPartenza`, `Treno`) VALUES (200, '2021-09-08', '17:00:00', 5656);
INSERT INTO `Ferrovie`.`Viaggio` (`Tratta`, `DataPartenza`, `OraPartenza`, `Treno`) VALUES (200, '2021-09-14', '09:00:00', 3434);
INSERT INTO `Ferrovie`.`Viaggio` (`Tratta`, `DataPartenza`, `OraPartenza`, `Treno`) VALUES (300, '2021-09-15', '13:00:00', 9898);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Posto`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 1, 1, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 2, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 3, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 4, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 5, 1, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 6, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 7, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 8, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 9, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (5, 10, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (6, 1, 0, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (8, 1, 1, 200, '2021-09-08', '17:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (8, 2, 0, 200, '2021-09-08', '17:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (8, 3, 0, 200, '2021-09-08', '17:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (10, 1, 0, 300, '2021_09-15', '13:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (10, 2, 0, 300, '2021_09-15', '13:00:00');
INSERT INTO `Ferrovie`.`Posto` (`Vagone`, `Numero`, `Occupato`, `Tratta`, `DataViaggio`, `OraViaggio`) VALUES (10, 3, 0, 300, '2021_09-15', '13:00:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Biglietto`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Biglietto` (`Codice_prenotazione`, `CF_passeggero`, `NumeroCartaCredito`, `Utilizzato`, `VagonePosto`, `NumeroPosto`, `TrattaViaggio`, `DataViaggio`, `OraViaggio`) VALUES (1, 'FRCVRD78B11H501K', '3333444455556666', 0, 5, 1, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Biglietto` (`Codice_prenotazione`, `CF_passeggero`, `NumeroCartaCredito`, `Utilizzato`, `VagonePosto`, `NumeroPosto`, `TrattaViaggio`, `DataViaggio`, `OraViaggio`) VALUES (2, 'FRCVRD78B11H501K', '7777666655554444', 1, 5, 5, 100, '2021-09-07', '12:00:00');
INSERT INTO `Ferrovie`.`Biglietto` (`Codice_prenotazione`, `CF_passeggero`, `NumeroCartaCredito`, `Utilizzato`, `VagonePosto`, `NumeroPosto`, `TrattaViaggio`, `DataViaggio`, `OraViaggio`) VALUES (3, 'CRLGLL89H43H678L', '8888444422220000', 0, 8, 1, 200, '2021-09-08', '17:00:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Fermata`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Roma', 'Roma', 'Termini');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Firenze', 'Firenze', 'Rifredi');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Milano', 'Milano', 'Centrale');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Milano', 'Rho', 'Fiera');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Venezia', 'Venezia', 'Santa Lucia');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Venezia', 'Mestre', 'Mestre');
INSERT INTO `Ferrovie`.`Fermata` (`Provincia`, `Citta`, `Stazione`) VALUES ('Roma', 'Roma', 'Tiburtina');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Composizione_tratta`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (100, 'Roma', 'Roma', 'Termini', 1);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (100, 'Roma', 'Roma', 'Tiburtina', 2);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (100, 'Firenze', 'Firenze', 'Rifredi', 3);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (100, 'Milano', 'Milano', 'Centrale', 4);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (200, 'Venezia', 'Venezia', 'Santa Lucia', 1);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (200, 'Venezia', 'Mestre', 'Mestre', 2);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (200, 'Milano', 'Rho', 'Fiera', 3);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (200, 'Milano', 'Milano', 'Centrale', 4);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (300, 'Milano', 'Milano', 'Centrale', 1);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (300, 'Firenze', 'Firenze', 'Rifredi', 2);
INSERT INTO `Ferrovie`.`Composizione_tratta` (`Tratta`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `Ordine`) VALUES (300, 'Roma', 'Roma', 'Termini', 3);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Fermare`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-13', '08:00:00', 'Roma', 'Roma', 'Termini', '08:00:00', NULL);
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-13', '08:00:00', 'Roma', 'Roma', 'Tiburtina', '08:25:00', '08:15:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-13', '08:00:00', 'Firenze', 'Firenze', 'Rifredi', '12:00:00', '11:30:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-13', '08:00:00', 'Milano', 'Milano', 'Centrale', NULL, '15:00:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-07', '12:00:00', 'Roma', 'Roma', 'Termini', '12:00:00', NULL);
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-07', '12:00:00', 'Roma', 'Roma', 'Tiburtina', '12:40:00', '12:25:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-07', '12:00:00', 'Firenze', 'Firenze', 'Rifredi', '13:30:00', '13:10:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (100, '2021-09-07', '12:00:00', 'Milano', 'Milano', 'Centrale', NULL, '16:00:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-08', '17:00:00', 'Venezia', 'Venezia', 'Santa Lucia', '17:00:00', NULL);
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-08', '17:00:00', 'Venezia', 'Mestre', 'Mestre', '17:45:00', '17:30:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-08', '17:00:00', 'Milano', 'Rho', 'Fiera', '18:35:00', '18:30:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-08', '17:00:00', 'Milano', 'Milano', 'Centrale', NULL, '19:00:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-14', '09:00:00', 'Venezia', 'Venezia', 'Santa Lucia', '09:00:00', NULL);
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-14', '09:00:00', 'Venezia', 'Mestre', 'Mestre', '10:00:00', '09:25:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-14', '09:00:00', 'Milano', 'Rho', 'Fiera', '12:15:00', '12:00:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (200, '2021-09-14', '09:00:00', 'Milano', 'Milano', 'Centrale', NULL, '13:00:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (300, '2021-09-15', '13:00:00', 'Milano', 'Milano', 'Centrale', '13:00:00', NULL);
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (300, '2021-09-15', '13:00:00', 'Firenze', 'Firenze', 'Rifredi', '15:00:00', '14:30:00');
INSERT INTO `Ferrovie`.`Fermare` (`Tratta`, `DataViaggio`, `OraViaggio`, `ProvinciaFermata`, `CittaFermata`, `StazioneFermata`, `OraPartenza`, `OraArrivo`) VALUES (300, '2021-09-15', '13:00:00', 'Roma', 'Roma', 'Termini', NULL, '16:00:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Lavoratore`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Lavoratore` (`CF`, `Nome`, `Cognome`, `DataNascita`, `LuogoNascita`, `Ruolo`) VALUES ('DCNSRA99H59H501S', 'Sara', 'Da Canal', '1999-06-19', 'Roma (RM)', 0);
INSERT INTO `Ferrovie`.`Lavoratore` (`CF`, `Nome`, `Cognome`, `DataNascita`, `LuogoNascita`, `Ruolo`) VALUES ('RSSMRO67L02H501R', 'Mario', 'Rossi', '1967-08-02', 'Roma(RM)', 1);
INSERT INTO `Ferrovie`.`Lavoratore` (`CF`, `Nome`, `Cognome`, `DataNascita`, `LuogoNascita`, `Ruolo`) VALUES ('BNCMRA79M53H501F', 'Maria', 'Bianchi', '1979-09-13', 'Roma(RM)', 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Locomotrice`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (1, 2727);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (4, 4343);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (7, 5656);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (9, 9898);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (11, 2323);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (14, 1212);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (16, 3434);
INSERT INTO `Ferrovie`.`Locomotrice` (`Id_locomotrice`, `Treno`) VALUES (19, 7676);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Vagone_merci`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Vagone_merci` (`Id_vagone_merci`, `Portata`, `Treno`) VALUES (15, 300, 1212);
INSERT INTO `Ferrovie`.`Vagone_merci` (`Id_vagone_merci`, `Portata`, `Treno`) VALUES (17, 4000, 3434);
INSERT INTO `Ferrovie`.`Vagone_merci` (`Id_vagone_merci`, `Portata`, `Treno`) VALUES (18, 3200, 3434);
INSERT INTO `Ferrovie`.`Vagone_merci` (`Id_vagone_merci`, `Portata`, `Treno`) VALUES (20, 950, 7676);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Merce`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Merce` (`Id_merce`, `Tipo`, `Massa`, `Vagone`, `Provenienza`, `Direzione`, `Viaggio`, `DataViaggio`, `OraViaggio`) VALUES (1, 'Patate', 200, 15, '00001234567', '00009876543', 100, '2021-09-13', '08:00:00');
INSERT INTO `Ferrovie`.`Merce` (`Id_merce`, `Tipo`, `Massa`, `Vagone`, `Provenienza`, `Direzione`, `Viaggio`, `DataViaggio`, `OraViaggio`) VALUES (2, 'Pere', 1000, 17, '00009876543', '00001234567', 200, '2021-09-14', '09:00:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Turno`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('DCNSRA99H59H501S', '2021-09-13', '08:00:00', '12:00:00', 1212, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('DCNSRA99H59H501S', '2021-09-07', '12:00:00', '16:00:00', 4343, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('DCNSRA99H59H501S', '2021-09-08', '17:00:00', '20:00:00', 5656, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('DCNSRA99H59H501S', '2021-09-14', '09:00:00', '13:00:00', 3434, 'BNCMRA79M53H501F');
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('RSSMRO67L02H501R', '2021-09-07', '12:00:00', '16:00:00', 4343, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('RSSMRO67L02H501R', '2021-09-08', '17:00:00', '21:00:00', 5656, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('RSSMRO67L02H501R', '2021-09-15', '13:00:00', '16:00:00', 9898, NULL);
INSERT INTO `Ferrovie`.`Turno` (`LavoratoreAssegnato`, `DataTurno`, `OraInizio`, `OraFine`, `Treno`, `LavoratoreSvolto`) VALUES ('BNCMRA79M53H501F', '2021-09-15', '13:00:00', '16:00:00', 9898, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Ferrovie`.`Utenti`
-- -----------------------------------------------------
START TRANSACTION;
USE `Ferrovie`;
INSERT INTO `Ferrovie`.`Utenti` (`Username`, `U_password`, `Ruolo`) VALUES ('Admin', 'admin', 'amministratore');
INSERT INTO `Ferrovie`.`Utenti` (`Username`, `U_password`, `Ruolo`) VALUES ('Manutentore', 'admin', 'manutentore');
INSERT INTO `Ferrovie`.`Utenti` (`Username`, `U_password`, `Ruolo`) VALUES ('DCNSRA99H59H501S', 'admin', 'macchinista');
INSERT INTO `Ferrovie`.`Utenti` (`Username`, `U_password`, `Ruolo`) VALUES ('RSSMRO67L02H501R', 'admin', 'capotreno');
INSERT INTO `Ferrovie`.`Utenti` (`Username`, `U_password`, `Ruolo`) VALUES ('BNCMRA79M53H501F', 'admin', 'macchinista');

COMMIT;

