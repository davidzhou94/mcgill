/* Exercise 1 */

CREATE TABLE department (
	did		INTEGER PRIMARY KEY,
	dept_name	VARCHAR(50)	NOT NULL,
	number_of_beds	INTEGER		NOT NULL
);

CREATE TABLE employee (
	eid		INTEGER		PRIMARY KEY,
	did		INTEGER		NULL REFERENCES department(did) ON DELETE CASCADE,
	first_name	VARCHAR(50)	NOT NULL,
	last_name	VARCHAR(70)	NOT NULL,
	job_title	VARCHAR(50)	NULL,
	start_date	DATE		NOT NULL DEFAULT current_date,
	last_date	DATE		NULL,
	gender		VARCHAR(1)	NOT NULL CHECK (gender ~ '^[MF]$'),
	date_of_birth	DATE		NOT NULL,
	phone		VARCHAR(10)	NULL CHECK (phone ~ '^[0-9]+$'),
	email		VARCHAR(70)	NULL
);

CREATE TABLE patient (
	medicare_number	VARCHAR(12)	PRIMARY KEY,
	first_name	VARCHAR(50)	NOT NULL,
	last_name	VARCHAR(70)	NOT NULL,
	gender		VARCHAR(1)	NOT NULL CHECK (gender ~ '^[MF]$'),
	date_of_birth	DATE		NOT NULL,
	phone		VARCHAR(10)	NULL CHECK (phone ~ '^[0-9]+$'),
	address		VARCHAR(70)	NULL
);

CREATE TABLE admission (
	admit_time	TIME		NOT NULL DEFAULT current_time,
	admit_date	DATE		NOT NULL DEFAULT current_date,
	medicare_number	VARCHAR(12)	NOT NULL REFERENCES patient(medicare_number) ON DELETE CASCADE,
	reason		VARCHAR(50)	NULL,
	discharge_date	DATE		NULL
);

CREATE TABLE visit (
	visit_time	TIME		NOT NULL DEFAULT current_time,
	visit_date	DATE		NOT NULL DEFAULT current_date,
	medicare_number	VARCHAR(12)	NOT NULL REFERENCES patient(medicare_number) ON DELETE CASCADE,
	diagnosis	VARCHAR(50)	NULL,
	medical_report	TEXT		NULL
);

CREATE TABLE specialist (
	eid		INTEGER		PRIMARY KEY REFERENCES employee(eid) ON DELETE CASCADE,
	specialty_did	INTEGER		NOT NULL REFERENCES department(did) ON DELETE CASCADE,
	specialty	VARCHAR(50)	NULL,
	visit_fee	NUMERIC		NULL DEFAULT 0.00,
	city		VARCHAR(50)	NULL,
	specialist_role	VARCHAR(1)	NOT NULL DEFAULT 'N' CHECK (specialist_role ~ '^[DN]$')
);

ALTER TABLE department 
	ADD COLUMN 
	administrator_id INTEGER 	REFERENCES employee(eid);
ALTER TABLE admission 
	ADD COLUMN 
	assigned_doctor_id INTEGER 	NOT NULL REFERENCES specialist(eid) ON DELETE CASCADE;
ALTER TABLE admission
	ADD PRIMARY KEY(admit_date, medicare_number, assigned_doctor_id);
ALTER TABLE visit
	ADD COLUMN
	assigned_doctor_id INTEGER	NOT NULL REFERENCES specialist(eid) ON DELETE CASCADE;
ALTER TABLE visit
	ADD PRIMARY KEY(visit_time, visit_date, medicare_number, assigned_doctor_id);

/* Exercise 2 */

INSERT INTO department (did, dept_name, number_of_beds, administrator_id) VALUES
	(001, 'Administration', 0, NULL),
	(002, 'Nursing', 0, NULL),
	(003, 'Emergency Room', 27, NULL),
	(004, 'Surgery', 10, NULL),
	(005, 'Onconlogy', 15, NULL),
	(006, 'Cardiology', 19, NULL),
	(007, 'Neurology', 55, NULL),
	(008, 'Out-Patient Care', 19, NULL),
	(009, 'Pediatric Medicine', 48, NULL),
	(010, 'Pharmacy', 0, NULL);

INSERT INTO employee (eid, did, first_name, last_name, job_title, start_date, last_date, gender, date_of_birth, phone, email) VALUES
	(001, 001, 'Gregory', 'House', 'Dean of Medicine', '2005-07-25', NULL, 'M', '1958-01-16', '2257189055', 'house@mail.uhn.ca'),
	(002, 008, 'Rand', 'Paul', 'Optometrist', '2005-07-10', NULL, 'F', '1972-09-10', '2257189021', 'rpaul@mail.uhn.ca'),
	(003, 001, 'George-Oscar', 'Bluth', 'Chief Technical Officer', '2005-07-25', NULL, 'F', '1972-08-10', '2257189011', 'gob@mail.uhn.ca'),
	(004, 003, 'Clare', 'Underwood', 'Emergency Room Physician', DEFAULT, NULL, 'F', '1977-08-10', '2257189013', 'cunderwood@mail.uhn.ca'),
	(005, 006, 'Hannibal', 'Lecter', 'Psychiatrist', '2006-09-01', NULL, 'F', '1972-08-10', '2257189012', 'hlecter@mail.uhn.ca'),
	(006, 010, 'Julian', 'Bashir', 'Chief Pharmacist', '2005-07-25', NULL, 'F', '1972-06-10', '2257189021', 'jbashir@mail.uhn.ca'),
	(007, 002, 'Temperence', 'Brennen', 'Director of Nursing', '2005-07-25', NULL, 'F', '1972-08-15', '2257189015', 'bones@mail.uhn.ca'),
	(008, 001, 'James', 'McGill', 'Lawyer', '2005-07-25', NULL, 'F', '1972-08-10', '2257189077', 'sgoodman@mail.uhn.ca'),
	(009, 005, 'James', 'Wilson', 'Director of Oncology', '2005-07-10', NULL, 'F', '1972-02-16', '2257189027', 'wilson@mail.uhn.ca'),
	(010, 003, 'Chelsea', 'Clinton', 'Director of Emergency Medicine', '2005-07-25', NULL, 'F', '1980-04-10', '2257189573', 'cclinton@mail.uhn.ca'),
	(011, 004, 'Tuco', 'Salamanca', 'Chief Surgeon', '2006-09-01', NULL, 'M', '1972-09-11', '2257189575', 'tuco@mail.uhn.ca'),
	(012, 004, 'Joffrey', 'Baratheon', 'Surgeon', DEFAULT, NULL, 'F', '1972-03-10', '2257189588', 'jbaratheon@mail.uhn.ca'),
	(013, 004, 'Ramsay', 'Bolton', 'Neurosurgeon', '2005-07-25', NULL, 'F', '1966-05-10', '2257189554', 'rsnow@mail.uhn.ca'),
	(014, 006, 'Peter', 'Mansbridge', 'Director of Cardiology', '2005-07-25', NULL, 'F', '1951-07-29', '2257189897', 'pmansbridge@mail.uhn.ca'),
	(015, 007, 'Seymour', 'Lipschutz', 'Director of Neurology', '2005-07-25', NULL, 'F', '1972-08-10', '2257189035', 'fifthed@mail.uhn.ca'),
	(016, 009, 'Jebediah', 'Bush', 'Pediatrician', '2005-07-25', NULL, 'F', '1972-11-17', '2257189041', 'bush3@mail.uhn.ca'),
	(017, 001, 'Taylor', 'Swift', 'IT Analyst', '2005-07-10', NULL, 'F', '1972-08-10', '2257189559', 'tswift@mail.uhn.ca'),
	(018, 009, 'Vladimir', 'Putin', 'Director of Pediatric Medicine', '2005-07-25', NULL, 'F', '1955-08-10', '2257189094', 'vputin@mail.uhn.ca'),
	(019, 007, 'Tommy', 'Hilfiger', 'Neurologist', DEFAULT, NULL, 'F', '1955-12-10', '2257189665', 'thilfiger@mail.uhn.ca'),
	(020, 007, 'John', 'Baird', 'Neurologist', '2005-07-25', NULL, 'F', '1972-10-12', '2257189561', 'jbaird@mail.uhn.ca'),
	(021, 007, 'Nikola', 'Tesla', 'Neurologist', '2005-07-10', NULL, 'F', '1972-10-10', '2257189884', 'ntesla@mail.uhn.ca'),
	(022, 007, 'Raymond', 'Tusk', 'Neurologist', DEFAULT, NULL, 'F', '1972-08-10', '2257189812', 'rtusk@mail.uhn.ca'),
	(023, 007, 'Carl', 'Gustav', 'Neurologist', '2006-09-01', NULL, 'F', '1972-09-14', '2257189004', 'koenigsvenska@mail.uhn.ca'),
	(024, 008, 'Amy', 'Poehler', 'Dermatologist', '2005-07-10', NULL, 'F', '1972-04-10', '2257189931', 'lknope@mail.uhn.ca'),
	(025, 004, 'Paul', 'Calandra', 'Anesthesiologist', '2005-07-25', NULL, 'F', '1972-08-10', '2257189586', 'pcalandra@mail.uhn.ca'),
	(026, 010, 'Robert', 'Ford', 'Pharmacist', '2005-07-25', NULL, 'F', '1965-08-27', '2257189927', 'rford@mail.uhn.ca'),
	(027, 005, 'Rod', 'Blagojevich', 'Oncologist', DEFAULT, NULL, 'F', '1972-08-01', '2257189191', 'rblagosomething@mail.uhn.ca'),
	(028, 006, 'Frida', 'Kahlo', 'Cardiologist', DEFAULT, NULL, 'F', '1972-02-10', '2257189666', 'fkahlo@mail.uhn.ca'),
	(029, 002, 'Angela', 'Merkel', 'Senior Nurse', '2005-07-25', NULL, 'F', '1972-08-10', '2257189999', 'amerkel@mail.uhn.ca'),
	(030, 002, 'A.R.', 'Rahman', 'Nurse', DEFAULT, NULL, 'F', '1977-12-12', '2257189696', 'arr@mail.uhn.ca');

INSERT INTO specialist (eid, specialty_did, specialty, visit_fee, city, specialist_role) VALUES
	(001, 001, 'Diagnostics', 150.00, 'Toronto', 'D'),
	(002, 008, 'Eyes', 127.30, 'Montreal', 'D'),
	(004, 003, 'Lungs', 125.45, 'Longeuil', 'D'),
	(005, 006, 'Psychiatry', 125.45, 'Toronto', 'D'),
	(007, 002, 'Bones', 79.50, 'Laval', 'N'),
	(009, 005, 'Cancer', 125.45, 'New York', 'D'),
	(010, 003, 'HIV', 125.45, 'Laval', 'D'),
	(011, 004, 'Surgery', 125.45, 'Sherbrooke', 'D'),
	(012, 004, 'Heart Surgery', 125.45, 'Scarborough', 'D'),
	(013, 004, 'Brain', 125.45, 'Toronto', 'D'),
	(014, 006, 'Heart', 125.45, 'Montreal', 'D'),
	(015, 007, 'Brain', 125.45, 'Toronto', 'D'),
	(016, 009, 'Children', 68.80, 'Richmond Hill', 'D'),
	(018, 009, 'Heart Surgery', 68.80, 'Markham', 'D'),
	(019, 007, 'Brain', 125.45, 'Laval', 'D'),
	(020, 007, 'Neuro', 180.00, 'Toronto', 'D'),
	(021, 007, 'Neuro', 101.15, 'Montreal', 'D'),
	(022, 007, 'Neuro', 101.15, 'Laval', 'D'),
	(023, 007, 'Brain', 125.45, 'Toronto', 'D'),
	(024, 008, 'Skin', 100.00, 'Sherbrooke', 'D'),
	(027, 005, 'Cancer', 120.00, 'Repentigny', 'D'),
	(028, 006, 'Heart Surgery', 180.00, 'Montreal', 'D'),
	(029, 002, 'Fractures', 45.45, 'Toronto', 'N'),
	(030, 002, 'Throat', 45.45, 'Laval', 'N');

UPDATE department SET administrator_id = 001 WHERE did = 001;
UPDATE department SET administrator_id = 007 WHERE did = 002;
UPDATE department SET administrator_id = 010 WHERE did = 003;
UPDATE department SET administrator_id = 011 WHERE did = 004;
UPDATE department SET administrator_id = 009 WHERE did = 005;
UPDATE department SET administrator_id = 014 WHERE did = 006;
UPDATE department SET administrator_id = 015 WHERE did = 007;
UPDATE department SET administrator_id = 002 WHERE did = 008;
UPDATE department SET administrator_id = 018 WHERE did = 009;
UPDATE department SET administrator_id = 006 WHERE did = 010;

INSERT INTO patient (medicare_number, first_name, last_name, gender, date_of_birth, phone, address) VALUES
	('MU5118038302','Yuri','Krushchev','M','1985-06-14','9075511339','P.O. Box 765, 5752 Nunc Rd.'),
	('MU4713190086','Thomas','Clark','M','1976-10-16','9758965043','P.O. Box 459, 6292 Lorem, St.'),
	('MD5100565834','Dominique','St-Denis','M','1980-09-30','5875269844','797-7577 Malesuada Road'),
	('AL1938518035','Will','Graham','M','1981-04-03','6106156781','359-3420 Libero. Avenue'),
	('NO0996364742','Owen','Wolfe','M','1959-02-04','9564449323','Ap #806-7893 Purus St.'),
	('EE3930151037','Hadley','Erickson-Payette','F','1997-11-06','1515914571','1342 Risus. Street'),
	('GR7429349470','Kelly','Stephens','F','1958-02-08','8762379056','3155, Avenue du Parc'),
	('MT22BQND9285','Shannon','Schmidt','F','1985-01-01','3295409051','6552 Rue St-Laurent'),
	('NO1948063495','Tuco','Salamanca','M','1972-09-11','2257189575','P.O. Box 276, 1569 Amet, Av.'),
	('IL1265147415','Cameron','White','M','1990-05-25','7888488257','7098 Sagittis Street'),
	('SE6410980544','Arial','Italic','F','1993-08-09','9644299760','Ap #110-5544 Ante. Rd.'),
	('MK8721668183','Qing','Hua','F','1971-02-01','4766592224','Ap #523-1058 Nec, Rd.'),
	('CR6559805942','Llyod','George','M','1982-10-16','9908565312','Ap #245-6942 Nec, Ave'),
	('CY6519338569','Walter','White','M','1972-09-21','2173089446','P.O. Box 568, 2397 Scelerisque Rd.'),
	('LT3183141253','Seth','McFarlane','M','1981-07-25','2966477526','402-3776 Nunc Rd.'),
	('CY9175239617','Carrie','Wu','F','1995-04-29','5206606151','P.O. Box 832, 8096 Libero Rd.'),
	('AL0750125901','Kathleen','Guzman','F','1981-08-16','6639528688','P.O. Box 343, 648 Elit, Av.'),
	('CH0812446762','James','McGill','M','1970-06-05','1997358243','Ap #524-883 Accumsan St.'),
	('SK8256484067','Murphy','Henry','M','1998-10-02','2876200170','P.O. Box 616, 5063 Ipsum. Avenue'),
	('KW2038591241','Meridith','Simpson','F','1966-04-29','3669193618','316-7005 Augue Rd.'),
	('GT5478451219','Rita','Gonzalez','F','1988-03-23','1183153542','510-5822 Libero Avenue'),
	('SE4097033337','Colin','Firth','M','1992-02-12','7491892046','898 Ut, Av.'),
	('SA4144724382','Lupe','Fiasco','F','1964-11-27','8465601691','286-3357 Adipiscing Rd.'),
	('MK9862446425','Cedric','Godot','M','1996-03-29','5714243139','6536 Ste-Catherine E.'),
	('AZ7108907118','Amal','Faisal','F','1982-01-04','2153003670','Ap #580-124 Lorne.'),
	('MC0309412824','Kyle','McConnell','M','1973-03-18','4397083750','Ap #985-121 Aliquam Rd.');

INSERT INTO admission (admit_time, admit_date, medicare_number, reason, discharge_date, assigned_doctor_id) VALUES
	('03:10','2010-01-21','MU5118038302','HIV','2010-01-21',010),
	('05:15','2015-02-13','MU4713190086','Heart',NULL,012),
	('21:30','2010-01-20','MD5100565834','Pediatric','2010-01-21',012),
	('06:25','2015-02-13','AL1938518035','Neonatal',NULL,021),
	('06:25','2010-02-13','AL1938518035','Eyes','2010-02-13',002),
	('13:15','2010-01-21','NO0996364742','Cancer','2010-01-21',009),
	('06:15','2010-01-21','EE3930151037','HIV','2010-01-22',012),
	('17:55','2010-01-21','GR7429349470','Cancer','2010-01-21',011),
	('13:15','2015-02-13','MT22BQND9285','OBGYN',NULL,028),
	('13:15','1994-03-18','NO1948063495','Heart','1994-03-18',011),
	('13:15','1991-04-17','IL1265147415','Pediatric','1991-04-21',016),
	('16:40','1994-12-17','SE6410980544','Cancer','1994-12-17',016),
	('13:15','2014-12-22','MK8721668183','HIV','2014-12-25',028),
	('17:10','2013-08-10','CR6559805942','Cardiac','2013-08-20',028),
	('13:25','2007-10-10','CY6519338569','HIV','2007-10-30',009),
	('05:20','2005-07-04','CY6519338569','Cancer','2005-07-04',010),
	('10:20','2004-08-09','CY6519338569','HIV','2004-08-10',001),
	('11:30','2003-10-04','CY6519338569','Cancer','2003-10-04',009),
	('09:30','2002-07-15','CY6519338569','Cancer','2002-07-18',001),
	('03:15','2004-04-09','LT3183141253','Skin','2004-04-13',024),
	('17:35','2014-12-11','CY9175239617','Cancer','2014-12-12',009),
	('23:15','2007-06-18','AL0750125901','OBGYN','2007-06-18',016),
	('19:40','2001-12-11','AL0750125901','Cancer','2001-12-18',018),
	('16:10','2002-02-23','CH0812446762','Emergency','2002-02-19',004),
	('13:15','2005-03-26','SK8256484067','HIV','2005-03-28',004),
	('17:55','2014-11-14','KW2038591241','Cancer',NULL,009),
	('13:15','2007-12-19','GT5478451219','Pediatric','2007-12-20',011),
	('13:40','2015-02-22','SE4097033337','Neonatal',NULL,021),
	('07:15','2014-04-21','SA4144724382','Cancer','2014-04-30',009),
	('10:20','2010-05-01','SA4144724382','Psychiatry','2010-05-10',005),
	('13:10','2013-05-24','MK9862446425','Heart','2013-05-24',009),
	('22:35','2015-01-15','AZ7108907118','OBGYN','2015-01-19',011),
	('16:20','2015-02-22','MC0309412824','Heart',NULL,004);

INSERT INTO visit (visit_time, visit_date, medicare_number, assigned_doctor_id, diagnosis, medical_report) VALUES
	('03:10','2010-01-21','MU5118038302',010,'HIV','This is a medical report for this patient'),
	('05:15','2015-02-13','MU4713190086',012,'Trauma','This is a medical report for this patient'),
	('21:30','2010-01-20','MD5100565834',012,'Cancer','This is a medical report for this patient'),
	('20:10','2015-02-13','AL1938518035',021,'Neuro','The specialist did not complete this report'),
	('09:10','2010-02-13','AL1938518035',015,'Brain','A doctor wrote this report'),
	('09:00','2012-02-10','AL1938518035',023,'HIV','The specialist did not complete this report'),
	('08:30','2012-01-09','AL1938518035',022,'Cancer','This is a medical report for this patient'),
	('10:40','2013-02-01','AL1938518035',020,'Brain','A doctor wrote this report'),
	('10:45','2014-07-13','AL1938518035',015,'Neuro','This patient should visit again'),
	('06:35','2015-01-20','AL1938518035',019,'Eyes','The diagnosis is not conclusive'),
	('13:15','2010-01-21','NO0996364742',009,'Cancer','This is a medical report for this patient'),
	('06:15','2010-01-22','EE3930151037',012,'HIV','This is a medical report for this patient'),
	('17:55','2010-01-21','GR7429349470',011,'Cancer','This is a medical report for this patient'),
	('13:15','2015-02-13','MT22BQND9285',028,'OBGYN','This patient should visit again'),
	('13:15','1994-03-18','NO1948063495',011,'HIV','This is a medical report for this patient'),
	('13:15','1991-04-17','IL1265147415',016,'Pediatric','This patient should visit again'),
	('16:40','1994-12-17','SE6410980544',016,'Cancer','This is a medical report for this patient'),
	('13:15','2014-12-22','MK8721668183',028,'HIV','This is a medical report for this patient'),
	('17:10','2013-08-10','CR6559805942',028,'Cardiac','This is a medical report for this patient'),
	('12:00','2010-08-09','CY6519338569',028,'HIV','The diagnosis is not conclusive'),
	('10:20','2014-08-15','CY6519338569',001,'Heart','The diagnosis is not conclusive'),
	('09:25','2014-11-02','CY6519338569',002,'Heart','This is a medical report for this patient'),
	('13:25','2007-10-10','CY6519338569',009,'Heart','The specialist did not complete this report'),
	('05:20','2005-07-04','CY6519338569',010,'Heart','A doctor wrote this report'),
	('10:20','2004-08-09','CY6519338569',001,'HIV','The diagnosis is not conclusive'),
	('11:30','2003-10-04','CY6519338569',009,'Heart','The specialist did not complete this report'),
	('09:00','2002-07-15','CY6519338569',001,'Cancer','A doctor wrote this report'),
	('03:05','2004-04-09','LT3183141253',024,'AIDS','A doctor wrote this report'),
	('17:35','2014-12-11','CY9175239617',009,'Cancer','The diagnosis is not conclusive'),
	('23:15','2007-06-18','AL0750125901',016,'OBGYN','The diagnosis is not conclusive'),
	('19:40','2001-12-11','AL0750125901',018,'Cancer','The diagnosis is not conclusive'),
	('16:10','2002-02-23','CH0812446762',004,'Trauma','This is a medical report for this patient'),
	('13:15','2005-03-26','SK8256484067',004,'HIV','This patient should visit again'),
	('17:55','2014-10-09','KW2038591241',004,'Cancer','This is a medical report for this patient'),
	('07:00','2014-09-01','KW2038591241',002,'Cancer','A doctor wrote this report'),
	('19:10','2014-12-20','KW2038591241',002,'Trauma','The specialist did not complete this report'),
	('08:30','2014-06-11','KW2038591241',028,'Cancer','This is a medical report for this patient'),
	('10:20','2015-01-02','KW2038591241',011,'OBGYN','The specialist did not complete this report'),
	('11:25','2015-01-24','KW2038591241',021,'Cancer','A doctor wrote this report'),
	('20:45','2015-01-29','KW2038591241',009,'Cardiac','The specialist did not complete this report'),
	('17:55','2014-11-14','KW2038591241',009,'Cancer','The specialist did not complete this report'),
	('13:15','2007-12-19','GT5478451219',011,'Pediatric','This is a medical report for this patient'),
	('13:40','2015-02-22','SE4097033337',021,'Neonatal','This is a medical report for this patient'),
	('07:15','2014-04-21','SA4144724382',009,'Cancer','The diagnosis is not conclusive'),
	('10:20','2010-05-01','SA4144724382',005,'Psychiatry','This patient should visit again'),
	('13:10','2013-05-24','MK9862446425',009,'Trauma','This is a medical report for this patient'),
	('22:35','2015-01-15','AZ7108907118',011,'OBGYN','The diagnosis is not conclusive'),
	('16:20','2015-02-22','MC0309412824',004,'Cancer','The diagnosis is not conclusive');

/* Exercise 3 */

/* 1. List the information of all doctors who are specialized in heart surgery. */

SELECT * 
  FROM employee e
  LEFT JOIN specialist s
    ON e.eid = s.eid
 WHERE s.specialist_role = 'D' AND
       s.specialty = 'Heart Surgery';

/* 2. List the information of all nurses who are from Laval and started since June 01,
      2012 and are still working.*/

SELECT *
  FROM employee e
  LEFT JOIN specialist s
    ON e.eid = s.eid
 WHERE s.specialist_role = 'N' AND
       s.city = 'Laval' AND
       e.start_date >= '2012-06-01' AND
       e.last_date IS NULL;

/* 3. Given a patient’s medicare number, list the Medical Report of that patient. */

SELECT v.medical_report
  FROM visit v
 WHERE v.medicare_number = 'CY6519338569';

/* 4. Given a patient’s medicare number, find out how much s/he has paid for each
      visit since June 2014 in ascending order by date and time. */

SELECT t.visit_time, t.visit_date, t.visit_fee
  FROM (
	SELECT *
	  FROM visit v
	  LEFT JOIN specialist s
	    ON v.assigned_doctor_id = s.eid
       ) t
 WHERE t.medicare_number = 'CY6519338569' AND
       t.visit_date > '2014-06-01'
 ORDER BY visit_date, visit_time ASC;

/* 5. List heart patients who were admitted/visited at least five times. */

SELECT p.first_name, p.last_name, t.count
  FROM (
	SELECT v.medicare_number,
	       count(*) AS count
	  FROM visit v
	 WHERE v.diagnosis = 'Heart'
	 GROUP BY v.medicare_number
	 UNION
	SELECT a.medicare_number,
	       count(*) as count
	  FROM admission a
	 WHERE a.reason = 'Heart'
	 GROUP BY a.medicare_number
       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
 WHERE t.count >= 5;

/* 6. List patient’s first name, last name, phone, date admitted, date discharged for all
      admitted patients with Cancer and HIV. */
      
SELECT p.first_name,
       p.last_name,
       p.phone,
       s.date_last_admitted,
       s.date_last_discharged
  FROM (
	SELECT DISTINCT a.medicare_number
	  FROM admission a
	 WHERE a.reason = 'Cancer' OR
	       a.reason = 'HIV'
	       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
  LEFT JOIN (
	SELECT a.medicare_number,
	       MAX(a.admit_date) AS date_last_admitted,
	       MAX(a.discharge_date) AS date_last_discharged
	  FROM admission a
	 GROUP BY a.medicare_number
       ) s
    ON s.medicare_number = p.medicare_number;

/* 7. List patient’s first name, last name, phone, date admitted, date discharged for all
      admitted patients with Cancer but do not have HIV. */

SELECT p.first_name,
       p.last_name,
       p.phone,
       s.date_last_admitted,
       s.date_last_discharged
  FROM (
	SELECT DISTINCT a.medicare_number
	  FROM admission a
	 WHERE a.reason = 'Cancer' AND
	       a.medicare_number NOT IN (
	       SELECT DISTINCT b.medicare_number
	         FROM admission b
	        WHERE b.reason = 'HIV' )
	       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
  LEFT JOIN (
	SELECT a.medicare_number,
	       MAX(a.admit_date) AS date_last_admitted,
	       MAX(a.discharge_date) AS date_last_discharged
	  FROM admission a
	 GROUP BY a.medicare_number
       ) s
    ON s.medicare_number = p.medicare_number;

/* 8. List patient’s first name, last name, phone, date admitted, date discharged for all
      admitted patients who are doctors. */

SELECT p.first_name,
       p.last_name,
       p.phone,
       s.date_last_admitted,
       s.date_last_discharged
  FROM (
	SELECT DISTINCT a.medicare_number
	  FROM admission a
	  LEFT JOIN patient p
	    ON a.medicare_number = p.medicare_number
	 RIGHT JOIN (
		SELECT e.first_name,
		       e.last_name,
		       e.gender,
		       e.date_of_birth
		  FROM employee e
		 RIGHT JOIN specialist dn
		    ON e.eid = dn.eid
		 WHERE dn.specialist_role = 'D'
	       ) d
	    ON p.date_of_birth = d.date_of_birth AND
	       p.first_name = d.first_name AND
	       p.last_name = d.last_name AND
	       p.gender = d.gender
	 WHERE a.medicare_number IS NOT NULL
       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
  LEFT JOIN (
	SELECT a.medicare_number,
	       MAX(a.admit_date) AS date_last_admitted,
	       MAX(a.discharge_date) AS date_last_discharged
	  FROM admission a
	 GROUP BY a.medicare_number
       ) s
    ON s.medicare_number = p.medicare_number;
      
/* 9. List patient’s first name, last name, phone, date admitted, date discharged for all
      admitted patients who visited all doctors in Neurology department. */

SELECT p.first_name,
       p.last_name,
       p.phone,
       s.date_last_admitted,
       s.date_last_discharged
  FROM (
	SELECT q.medicare_number
	  FROM (
		SELECT r.medicare_number,
		       count(*) AS count
		  FROM (
			SELECT DISTINCT v.medicare_number,
			       v.assigned_doctor_id
			  FROM visit v
			 WHERE v.assigned_doctor_id IN (
			    SELECT s.eid
			      FROM specialist s
			      LEFT JOIN department d
				ON s.specialty_did = d.did
			     WHERE d.dept_name = 'Neurology')
		       ) r
		 GROUP BY r.medicare_number
	       ) q
	 CROSS JOIN (
	    SELECT count(*) AS count
	      FROM specialist s
	      LEFT JOIN department d
		ON s.specialty_did = d.did
	     WHERE d.dept_name = 'Neurology') u
	 WHERE q.count >= u.count
       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
  LEFT JOIN (
	SELECT a.medicare_number,
	       MAX(a.admit_date) AS date_last_admitted,
	       MAX(a.discharge_date) AS date_last_discharged
	  FROM admission a
	 GROUP BY a.medicare_number
       ) s
    ON s.medicare_number = p.medicare_number;

/* 10. List employee's first name, last name, jobTitle, phone# of employees who are
       patients and diagnosed with HIV. */

SELECT e.first_name,
       e.last_name,
       e.job_title,
       e.phone
  FROM (
	SELECT DISTINCT v.medicare_number
	  FROM visit v
	 WHERE v.diagnosis = 'HIV'
	       ) t
  LEFT JOIN patient p
    ON p.medicare_number = t.medicare_number
 RIGHT JOIN employee e
    ON e.first_name = p.first_name AND
       e.last_name = p.last_name AND
       e.gender = p.gender AND
       e.date_of_birth = p.date_of_birth
 WHERE p.first_name IS NOT NULL;

/* 11. Give detail of doctors who charge the highest fee for their visit. */

SELECT e.eid,
       e.did,
       e.first_name,
       e.last_name,
       e.job_title,
       e.phone,
       s.specialty,
       s.visit_fee,
       s.city
  FROM specialist s
  LEFT JOIN employee e
    ON s.eid = e.eid
 WHERE s.visit_fee IN (
	SELECT max(visit_fee)
	  FROM specialist
       );

/* 12. For each department, provide the department name, the minimum visit fee, the
       maximum visit fee and the average visit fee charged by doctors in the department
       where the department have at least two doctors. */

SELECT t.dept_name,
       t.max_visit_fee,
       t.min_visit_fee,
       t.avg_visit_fee
  FROM (
	SELECT d.dept_name,
	       max(s.visit_fee) AS max_visit_fee,
	       min(s.visit_fee) AS min_visit_fee,
	       round(avg(s.visit_fee),2) AS avg_visit_fee,
	       count(*) AS count
	  FROM specialist s
	  LEFT JOIN department d
	    ON d.did = s.specialty_did
	 GROUP BY d.dept_name
       ) t
 WHERE t.count >= 2;

SELECT * FROM admission;
SELECT * FROM department;
SELECT * FROM employee;
SELECT * FROM patient;
SELECT * FROM specialist;
SELECT * FROM visit;

/* Exercise 4 */

DELETE FROM department;
DELETE FROM employee;
DELETE FROM patient;
DELETE FROM admission;
DELETE FROM visit;
DELETE FROM specialist;

/* Exercise 5 */

DROP TABLE department CASCADE;
DROP TABLE employee CASCADE;
DROP TABLE patient CASCADE;
DROP TABLE admission CASCADE;
DROP TABLE visit CASCADE;
DROP TABLE specialist;