CREATE SCHEMA FULL_UNIVERSIDAD;
set search_path = full_universidad, public;

CREATE TABLE LIBROS (
  idLIBROS INTEGER   NOT NULL ,
  TITULO VARCHAR(45)   NOT NULL ,
  EDITORIAL VARCHAR(45)   NOT NULL ,
  EDICION VARCHAR(45)      ,
PRIMARY KEY(idLIBROS));

CREATE TABLE FACULTADES (
  idFACULTADES INTEGER   NOT NULL ,
  NOMBRE VARCHAR(20)   NOT NULL   ,
PRIMARY KEY(idFACULTADES));

CREATE TABLE PERSONAS (
  DNI INTEGER   NOT NULL ,
  NOMBRE VARCHAR(20)   NOT NULL ,
  APELLIDO VARCHAR(20)   NOT NULL ,
  FECHA_NACIMIENTO DATE   NOT NULL ,
  TELEFONO INTEGER    ,
  DIRECCION VARCHAR(20)      ,
PRIMARY KEY(DNI));

CREATE TABLE MOVIMIENTOS (
  idMOVIMIENTOS INTEGER   NOT NULL ,
  FECHA   timestamp  NOT NULL ,
  USER_NAME VARCHAR(40)   NOT NULL ,
  NOTA1_INI INTEGER   NOT NULL ,
  NOTA1_FIN INTEGER   NOT NULL   ,
  NOTA2_INI INTEGER   NOT NULL ,
  NOTA2_FIN INTEGER   NOT NULL   ,
  NOTA3_INI INTEGER   NOT NULL ,
  NOTA3_FIN INTEGER   NOT NULL   ,
PRIMARY KEY(idMOVIMIENTOS));

CREATE TABLE ASIGNATURA (
  idASIGNATURA INTEGER   NOT NULL ,
  NOMBRE VARCHAR(20)   NOT NULL ,
  INTENCIDAD_H INTEGER   NOT NULL ,
  CREDITOS INTEGER  DEFAULT 3 NOT NULL   ,
PRIMARY KEY(idASIGNATURA));

CREATE TABLE EJEMPLARES (
  idEJEMPLARES INTEGER   NOT NULL ,
  idLIBROS INTEGER   NOT NULL ,
  NUMERO_E INTEGER      ,
PRIMARY KEY(idEJEMPLARES)  ,
  FOREIGN KEY(idLIBROS)
    REFERENCES LIBROS(idLIBROS));

CREATE TABLE CARRERA (
  idCARRERA INTEGER   NOT NULL ,
  idFACULTADES INTEGER   NOT NULL ,
  PERSONAS_DNI INTEGER   NOT NULL ,
  REG_CALIF VARCHAR(20)   NOT NULL ,
  NOMBRE VARCHAR(20)   NOT NULL   ,
PRIMARY KEY(idCARRERA)    ,
  FOREIGN KEY(idFACULTADES)
    REFERENCES FACULTADES(idFACULTADES),
  FOREIGN KEY(PERSONAS_DNI)
    REFERENCES PERSONAS(DNI));

CREATE TABLE GRUPOS (
  idGRUPO INTEGER   NOT NULL ,
  idASIGNATURA INTEGER   NOT NULL   ,
PRIMARY KEY(idGRUPO)  ,
  FOREIGN KEY(idASIGNATURA)
    REFERENCES ASIGNATURA(idASIGNATURA));

CREATE TABLE PERSONAS_has_LIBROS (
  DNI INTEGER   NOT NULL ,
  idLIBROS INTEGER   NOT NULL   ,
PRIMARY KEY(DNI,idLIBROS)    ,
  FOREIGN KEY(DNI)
    REFERENCES PERSONAS(DNI),
  FOREIGN KEY(idLIBROS)
    REFERENCES LIBROS(idLIBROS));

CREATE TABLE PROFESORES (
  idPROFESORES INTEGER   NOT NULL ,
  idFACULTADES INTEGER   NOT NULL ,
  PERSONAS_DNI INTEGER   NOT NULL ,
  PROFESION VARCHAR(20)   NOT NULL   ,
PRIMARY KEY(idPROFESORES)    ,
  FOREIGN KEY(PERSONAS_DNI)
    REFERENCES PERSONAS(DNI),
  FOREIGN KEY(idFACULTADES)
    REFERENCES FACULTADES(idFACULTADES));

CREATE TABLE PROFESORES_has_GRUPOS (
  idPROFESORES INTEGER   NOT NULL ,
  idGRUPO INTEGER   NOT NULL ,
  HORARIO VARCHAR(45)      ,
PRIMARY KEY(idPROFESORES, idGRUPO)    ,
  FOREIGN KEY(idPROFESORES)
    REFERENCES PROFESORES(idPROFESORES),
  FOREIGN KEY(idGRUPO)
    REFERENCES GRUPOS(idGRUPO));

CREATE TABLE ESTUDIANTES (
  COD INTEGER   NOT NULL ,
  idCARRERA INTEGER   NOT NULL ,
  DNI INTEGER   NOT NULL   ,
PRIMARY KEY(COD)    ,
  FOREIGN KEY(DNI)
    REFERENCES PERSONAS(DNI),
  FOREIGN KEY(idCARRERA)
    REFERENCES CARRERA(idCARRERA));

CREATE TABLE EJEMPLARES_has_ESTUDIANTES (
  idEJEMPLARES INTEGER   NOT NULL ,
  COD INTEGER   NOT NULL ,
  FECHA_INI DATE   NOT NULL ,
  FECHA_FIN DATE   NOT NULL   ,
PRIMARY KEY(idEJEMPLARES, COD)    ,
  FOREIGN KEY(idEJEMPLARES)
    REFERENCES EJEMPLARES(idEJEMPLARES),
  FOREIGN KEY(COD)
    REFERENCES ESTUDIANTES(COD));

CREATE TABLE ESTUDIANTES_has_GRUPOS (
  COD INTEGER   NOT NULL ,
  idGRUPO INTEGER   NOT NULL ,
  NOTA1 FLOAT    ,
  NOTA2 FLOAT    ,
  NOTA3 FLOAT      ,
PRIMARY KEY(COD, idGRUPO)    ,
  FOREIGN KEY(COD)
    REFERENCES ESTUDIANTES(COD),
  FOREIGN KEY(idGRUPO)
    REFERENCES GRUPOS(idGRUPO));


CREATE VIEW List_Estudiante_por_Gruop AS
SELECT COD, (SELECT NOMBRE FROM personas) AS NOMBRE, IDGRUPO FROM estudiantes_has_grupos;

CREATE VIEW List_Libros AS
select nombre,titulo from personas_has_libros
INNER join full_universidad.personas USING(dni)
INNER join full_universidad.libros USING(idlibros);

CREATE VIEW Notas_Estudiante AS
select cod,(SELECT nombre  from personas)as nombre ,nota1,nota2,nota3 from estudiantes_has_grupos;

CREATE VIEW Libros_Prestados AS
SELECT cod,(SELECT nombre  from personas),fecha_ini,fecha_fin,idejemplares 
from ejemplares_has_estudiantes;


CREATE ROLE COORDINADOR;
GRANT ALL ON ESTUDIANTES TO COORDINADOR;
GRANT ALL ON PROFESORES TO COORDINADOR;
GRANT ALL ON ESTUDIANTES_has_GRUPOS TO COORDINADOR;
GRANT ALL ON PROFESORES_has_GRUPOS TO COORDINADOR;
GRANT ALL ON PERSONAS TO COORDINADOR;

CREATE ROLE PROFESOR;
GRANT ALL ON PROFESORES TO PROFESOR;
GRANT ALL ON PERSONAS TO PROFESOR;
GRANT SELECT ON LIST_LIBROS TO PROFESOR;
GRANT SELECT ON  NOTAS_ESTUDIANTE TO PROFESOR;

CREATE ROLE ESTUDIANTE;
GRANT ALL ON PERSONAS TO ESTUDIANTE;
GRANT SELECT ON LIST_LIBROS TO ESTUDIANTE;
GRANT SELECT ON  NOTAS_ESTUDIANTE TO ESTUDIANTE;

CREATE ROLE BIBLIOTECARIO;
GRANT ALL ON LIBROS TO BIBLIOTECARIO;
GRANT SELECT, INSERT, UPDATE ON EJEMPLARES_has_ESTUDIANTES TO BIBLIOTECARIO;
GRANT ALL ON EJEMPLARES TO BIBLIOTECARIO;
GRANT ALL ON PERSONAS TO BIBLIOTECARIO;
GRANT ALL ON LIBROS_PRESTADOS TO BIBLIOTECARIO;

SELECT NOMBRE FROM ESTUDIANTES
INNER JOIN PERSONAS USING(DNI)

CREATE OR REPLACE FUNCTION create_user_estudiante() RETURNS
TRIGGER AS $create_user_estudiante$
DECLARE
 user_name VARCHAR(30) := (SELECT nombre FROM personas WHERE DNI = NEW.DNI);
BEGIN
EXECUTE 'CREATE USER ' || user_name || ' WITH PASSWORD ''' || user_name || '''';
EXECUTE 'GRANT ESTUDIANTE TO ' || user_name;
RETURN NEW;
END;
$create_user_estudiante$ LANGUAGE plpgsql;

CREATE trigger create_user_estudiante AFTER INSERT ON ESTUDIANTES
FOR EACH ROW EXECUTE PROCEDURE create_user_estudiante();

CREATE OR REPLACE FUNCTION create_user_profesor() RETURNS 
TRIGGER AS $create_user_profesor$
DECLARE
 user_name VARCHAR(30) := (SELECT nombre FROM personas WHERE dni = NEW.PERSONAS_DNI);
BEGIN
EXECUTE 'CREATE USER ' || user_name || ' WITH PASSWORD ''' || user_name || '''';
EXECUTE 'GRANT ESTUDIANTE TO ' || user_name;
RETURN NEW;
END;
$create_user_profesor$ LANGUAGE plpgsql;

CREATE trigger create_user_profesor AFTER INSERT ON PROFESORES
FOR EACH ROW EXECUTE PROCEDURE create_user_profesor();

CREATE OR REPLACE FUNCTION tbl_MOVIMIENTOS() RETURNS TRIGGER AS $tbl_MOVIMIENTOS$
DECLARE
  fecha TIMESTAMP WITH TIME ZONE default NOW();
  NOTA1 FLOAT := (SELECT nota1 FROM estudiantes_has_grupos WHERE cod = NEW.cod);
  NOTA2 FLOAT := (SELECT nota2 FROM estudiantes_has_grupos WHERE cod = NEW.cod);
  NOTA3 FLOAT := (SELECT nota3 FROM estudiantes_has_grupos WHERE cod = NEW.cod);
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    NEW.USER_NAME := user;
    NEW.FECHA := fecha;
    NEW.NOTA1_INI := NOTA1;
    NEW.NOTA1_FIN := NEW.NOTA1;
    NEW.NOTA2_INI := NOTA2;
    NEW.NOTA2_FIN := NEW.NOTA2;
    NEW.NOTA3_INI := NOTA3;
    NEW.NOTA3_FIN := NEW.NOTA3;
  	RETURN NEW;
  END IF;
END;
$tbl_MOVIMIENTOS$ LANGUAGE plpgsql;

CREATE trigger tbl_MOVIMIENTOS AFTER UPDATE ON MOVIMIENTOS
FOR EACH ROW EXECUTE PROCEDURE tbl_MOVIMIENTOS();

-- add extension
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION encrypt_personas() RETURNS TRIGGER AS $encrypt_personas$
DECLARE
  DIRECCION VARCHAR(150) := NEW.DIRECCION;
BEGIN
  NEW.DIRECCION := encode(digest(DIRECCION::text, 'sha1'), 'hex');
  RETURN NEW;
END;
$encrypt_personas$ LANGUAGE plpgsql;

CREATE trigger encrypt_personas BEFORE INSERT ON PERSONAS
FOR EACH ROW EXECUTE PROCEDURE encrypt_personas();


insert into FULL_UNIVERSIDAD.facultades values (111,'INGENIERIAS');
insert into FULL_UNIVERSIDAD.facultades values (112,'CIENCIAS ECONOMICAS');
insert into FULL_UNIVERSIDAD.facultades values (113,'DERECHO');

insert into FULL_UNIVERSIDAD.personas values (101409872,'CAMILO','BERMUDEZ','12/11/1992',3202746,'CARRERA 13');
insert into FULL_UNIVERSIDAD.personas values (101409873,'FELIPE','QUINTERO','11/03/1994',2743513,'CARRERA 14');
insert into FULL_UNIVERSIDAD.personas values (101409874,'ROSA','BERMUDEZ','12/05/1994',2743514,'CARRERA 15');
insert into FULL_UNIVERSIDAD.personas values (101409875,'TOMAS','CARDENAS','15/04/1992',2743515,'CARRERA 16');
insert into FULL_UNIVERSIDAD.personas values (101409876,'ANDRES','ROSALES','16/02/1994',2743516,'CARRERA 17');
insert into FULL_UNIVERSIDAD.personas values (101409877,'SEBASTIAN','TORRES','17/12/1992',2743517,'CARRERA 18');
insert into FULL_UNIVERSIDAD.personas values (101409878,'JOSE','RUIZ','18/11/1992',2743518,'CARRERA 19');

insert into FULL_UNIVERSIDAD.asignatura values (121,'Programación_B',6,3);
insert into FULL_UNIVERSIDAD.asignatura values (122,'Bases_De_Datos',4,3);
insert into FULL_UNIVERSIDAD.asignatura values (123,'Ingles_I',3,3);
insert into FULL_UNIVERSIDAD.asignatura values (124,'Calculo',8,3);
insert into FULL_UNIVERSIDAD.asignatura values (125,'Algebra_L',4,2);
insert into FULL_UNIVERSIDAD.asignatura values (126,'Programación_I',4,3);
insert into FULL_UNIVERSIDAD.asignatura values (127,'Metodos',3,2);
insert into FULL_UNIVERSIDAD.asignatura values (128,'Ingles_II',3,2);
insert into FULL_UNIVERSIDAD.asignatura values (129,'Calculo_I',6,3);
insert into FULL_UNIVERSIDAD.asignatura values (120,'IA',6,2);

insert into FULL_UNIVERSIDAD.carrera values (131,111, 101409873,9876,'SISTEMAS');
insert into FULL_UNIVERSIDAD.carrera values (132,112, 101409873,8765,'ADMINISTRACION');
insert into FULL_UNIVERSIDAD.carrera values (133,112, 101409877,5644,'CONTADURIA');
insert into FULL_UNIVERSIDAD.carrera values (134,113, 101409877,5444,'DERECHO');
insert into FULL_UNIVERSIDAD.carrera values (135,112, 101409876,6775,'ECONOMIA');

insert into FULL_UNIVERSIDAD.profesores values (141,111,101409873,'INGENIERO SISTEMAS');
insert into FULL_UNIVERSIDAD.profesores values (142,113,101409877,'ABOGADO');
insert into FULL_UNIVERSIDAD.profesores values (143,112,101409876,'CONTADOR');

insert into FULL_UNIVERSIDAD.estudiantes values (151,131,101409872);
insert into FULL_UNIVERSIDAD.estudiantes values (152,132,101409875);
insert into FULL_UNIVERSIDAD.estudiantes values (153,134,101409874);
insert into FULL_UNIVERSIDAD.estudiantes values (154,135,101409878);

insert into FULL_UNIVERSIDAD.libros values (161,'ECONOMIA','PLANETA','PRIMERA EDICION');
insert into FULL_UNIVERSIDAD.libros values (162,'CONTABILIDAD_3','PLANETA','PRIMERA EDICION');
insert into FULL_UNIVERSIDAD.libros values (163,'INGLES_4','PLANETA','PRIMERA EDICION');
insert into FULL_UNIVERSIDAD.libros values (164,'MATEMATICAS_4','PLANETA','PRIMERA EDICION');
insert into FULL_UNIVERSIDAD.libros values (165,'PROGRAMACION_1','PLANETA','PRIMERA EDICION');

insert into FULL_UNIVERSIDAD.ejemplares values (171,161,4);
insert into FULL_UNIVERSIDAD.ejemplares values (172,162,6);
insert into FULL_UNIVERSIDAD.ejemplares values (173,163,8);
insert into FULL_UNIVERSIDAD.ejemplares values (174,165,3);
insert into FULL_UNIVERSIDAD.ejemplares values (175,164,4);

insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (171,151,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (171,152,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (171,153,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (171,154,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (172,151,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (174,154,'12/11/2022','12/12/2022');
insert into FULL_UNIVERSIDAD.ejemplares_has_estudiantes values (174,153,'12/11/2022','12/12/2022');

insert into FULL_UNIVERSIDAD.grupos values (181,121);
insert into FULL_UNIVERSIDAD.grupos values (182,122);
insert into FULL_UNIVERSIDAD.grupos values (183,123);

insert into FULL_UNIVERSIDAD.estudiantes_has_grupos values (151,181,3,4,4);
insert into FULL_UNIVERSIDAD.estudiantes_has_grupos values (152,181,3.5,4,4);
insert into FULL_UNIVERSIDAD.estudiantes_has_grupos values (153,183,3,4.2,4.5);
insert into FULL_UNIVERSIDAD.estudiantes_has_grupos values (154,183,3.5,4,4);

insert into FULL_UNIVERSIDAD.personas_has_libros values (101409872,164);
insert into FULL_UNIVERSIDAD.personas_has_libros values (101409873,163);
insert into FULL_UNIVERSIDAD.personas_has_libros values (101409874,165);

UPDATE FULL_UNIVERSIDAD.estudiantes_has_grupos 
SET NOTA2 = 3.7
WHERE COD = 151;
