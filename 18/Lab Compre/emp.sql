-- creates some test-tables and data
-- DROP TABLE EMPLOYEE;
-- DROP TABLE DEPARTMENT;
-- DROP TABLE SALARYGRADE;
-- DROP TABLE BONUS;
-- DROP TABLE PROJECT;
-- DROP TABLE PROJECT_PARTICIPATION;
-- DROP TABLE ROLE;

DROP TABLE IF EXISTS EMPLOYEE;
CREATE TABLE EMPLOYEE(
   empno      INTEGER NOT NULL,
   name       VARCHAR(10),
   job        VARCHAR(9),
   boss       INTEGER,
   hiredate   VARCHAR(12),
   salary     DECIMAL(7, 2),
   comm       DECIMAL(7, 2),
   deptno     INTEGER
);

DROP TABLE IF EXISTS DEPARTMENT;
CREATE TABLE DEPARTMENT(
   deptno     INTEGER NOT NULL,
   name       VARCHAR(14),
   location   VARCHAR(13)
);

DROP TABLE IF EXISTS SALARYGRADE;
CREATE TABLE SALARYGRADE(
   grade      INTEGER NOT NULL,
   losal      INTEGER NOT NULL,
   hisal      INTEGER NOT NULL
);

DROP TABLE IF EXISTS BONUS;
CREATE TABLE BONUS (
   ename      VARCHAR(10) NOT NULL,
   job        VARCHAR(9) NOT NULL,
   sal        DECIMAL(7, 2),
   comm       DECIMAL(7, 2)
);

DROP TABLE IF EXISTS PROJECT;
CREATE TABLE PROJECT(
   projectno    INTEGER NOT NULL,
   description  VARCHAR(100),
   start_date   VARCHAR(12),
   end_date     VARCHAR(12)
);

DROP TABLE IF EXISTS PROJECT_PARTICIPATION;
CREATE TABLE PROJECT_PARTICIPATION(
   projectno    INTEGER NOT NULL,
   empno        INTEGER NOT NULL,
   start_date   VARCHAR(12) NOT NULL,
   end_date     VARCHAR(12),
   role_id      INTEGER
);

DROP TABLE IF EXISTS ROLE;
CREATE TABLE ROLE(
   role_id      INTEGER NOT NULL,
   description  VARCHAR(100)
);

-- Primary Keys
ALTER TABLE EMPLOYEE
   ADD CONSTRAINT emp_pk
   PRIMARY KEY (empno);

ALTER TABLE DEPARTMENT
   ADD CONSTRAINT dept_pk
   PRIMARY KEY (deptno);

ALTER TABLE SALARYGRADE
   ADD CONSTRAINT salgrade_pk
   PRIMARY KEY (grade);

ALTER TABLE BONUS
   ADD CONSTRAINT bonus_pk
   PRIMARY KEY (ename, job);

ALTER TABLE PROJECT
   ADD CONSTRAINT project_pk
   PRIMARY KEY (projectno);
 
ALTER TABLE PROJECT_PARTICIPATION
   ADD CONSTRAINT participation_pk
   PRIMARY KEY (projectno, empno, start_date);

ALTER TABLE ROLE
   ADD CONSTRAINT role_pk
   PRIMARY KEY (role_id);

-- EMPLOYEE to DEPARTMENT
ALTER TABLE EMPLOYEE
   ADD CONSTRAINT department
   FOREIGN KEY (deptno)
   REFERENCES DEPARTMENT (deptno);

-- EMPLOYEE to EMPLOYEE
ALTER TABLE EMPLOYEE
   ADD CONSTRAINT boss
   FOREIGN KEY (boss)
   REFERENCES EMPLOYEE (empno);
 
-- EMPLOYEE to PROJECT_PARTICIPATION
ALTER TABLE PROJECT_PARTICIPATION
   ADD CONSTRAINT employee
   FOREIGN KEY (empno)
   REFERENCES EMPLOYEE (empno);

-- PROJECT to PROJECT_PARTICIPATION
ALTER TABLE PROJECT_PARTICIPATION
   ADD CONSTRAINT project
   FOREIGN KEY (projectno)
   REFERENCES PROJECT (projectno);

-- ROLE to PROJECT_PARTICIPATION
ALTER TABLE PROJECT_PARTICIPATION
   ADD CONSTRAINT role
   FOREIGN KEY (role_id)
   REFERENCES ROLE (role_id);

-- data
INSERT INTO DEPARTMENT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPARTMENT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPARTMENT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPARTMENT VALUES (40, 'OPERATIONS', 'BOSTON');
 
INSERT INTO EMPLOYEE VALUES (7839, 'KING',   'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10);
INSERT INTO EMPLOYEE VALUES (7566, 'JONES',  'MANAGER',   7839, '1981-04-02',  2975, NULL, 20);
INSERT INTO EMPLOYEE VALUES(7788, 'SCOTT',  'ANALYST',   7566, '1982-12-09', 3000, NULL, 20);
INSERT INTO EMPLOYEE VALUES(7876, 'ADAMS',  'CLERK',     7788, '1983-01-12', 1100, NULL, 20);
INSERT INTO EMPLOYEE VALUES(7902, 'FORD',   'ANALYST',   7566, '1981-12-03',  3000, NULL, 20);
INSERT INTO EMPLOYEE VALUES(7369, 'SMITH',  'CLERK',     7902, '1980-12-17',  800, NULL, 20);
INSERT INTO EMPLOYEE VALUES (7698, 'BLAKE',  'MANAGER',   7839, '1981-05-01',  2850, NULL, 30);
INSERT INTO EMPLOYEE VALUES(7499, 'ALLEN',  'SALESMAN',  7698, '1981-02-20', 1600,  300, 30);
INSERT INTO EMPLOYEE VALUES(7521, 'WARD',   'SALESMAN',  7698, '1981-02-22', 1250,  500, 30);
INSERT INTO EMPLOYEE VALUES(7654, 'MARTIN', 'SALESMAN',  7698, '1981-09-28', 1250, 1400, 30);
INSERT INTO EMPLOYEE VALUES(7844, 'TURNER', 'SALESMAN',  7698, '1981-09-08',  1500,    0, 30);
INSERT INTO EMPLOYEE VALUES(7900, 'JAMES',  'CLERK',     7698, '1981-12-03',   950, NULL, 30);
INSERT INTO EMPLOYEE VALUES(7782, 'CLARK',  'MANAGER',   7839, '1981-06-09',  2450, NULL, 10);
INSERT INTO EMPLOYEE VALUES(7934, 'MILLER', 'CLERK',     7782, '1982-01-23', 1300, NULL, 10);

INSERT INTO SALARYGRADE VALUES (1,  700, 1200);
INSERT INTO SALARYGRADE VALUES (2, 1201, 1400);
INSERT INTO SALARYGRADE VALUES (3, 1401, 2000);
INSERT INTO SALARYGRADE VALUES (4, 2001, 3000);
INSERT INTO SALARYGRADE VALUES (5, 3001, 9999);
 
INSERT INTO ROLE VALUES (100, 'Developer');
INSERT INTO ROLE VALUES (101, 'Researcher');
INSERT INTO ROLE VALUES (102, 'Project manager');

INSERT INTO PROJECT VALUES (1001, 'Development of Novel Magnetic Suspension System', '2006-01-01', '2007-08-13');
INSERT INTO PROJECT VALUES (1002, 'Research on thermofluid dynamics in Microdroplets', '2006-08-22', '2007-03-20');
INSERT INTO PROJECT VALUES (1003, 'Foundation of Quantum Technology', '2007-02-24', '2008-07-31');
INSERT INTO PROJECT VALUES (1004, 'High capacity optical network', '2008-01-01', null);
 
INSERT INTO PROJECT_PARTICIPATION VALUES (1001, 7902, '2006-01-01', '2006-12-30', 102);
INSERT INTO PROJECT_PARTICIPATION VALUES (1001, 7369, '2006-01-01', '2007-08-13', 100);
INSERT INTO PROJECT_PARTICIPATION VALUES (1001, 7788, '2006-05-15', '2006-11-01', 100);

INSERT INTO PROJECT_PARTICIPATION VALUES (1002, 7876, '2006-08-22', '2007-03-20', 102);
INSERT INTO PROJECT_PARTICIPATION VALUES (1002, 7782, '2006-08-22', '2007-03-20', 101);
INSERT INTO PROJECT_PARTICIPATION VALUES (1002, 7934, '2007-01-01', '2007-03-20', 101);

INSERT INTO PROJECT_PARTICIPATION VALUES (1003, 7566, '2007-02-24', '2008-07-31', 102);
INSERT INTO PROJECT_PARTICIPATION VALUES (1003, 7900, '2007-02-24', '2007-01-31', 101);

INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7499, '2008-01-01', null, 102);
INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7521, '2008-05-01', null, 101);
INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7654, '2008-04-15', null, 101);
INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7844, '2008-02-01', null, 101);
INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7900, '2008-03-01', '2008-04-01', 101);
INSERT INTO PROJECT_PARTICIPATION VALUES (1004, 7900, '2008-05-20', null, 101);

COMMIT;
