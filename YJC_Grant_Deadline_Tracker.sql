/*Verified*/
CREATE DATABASE YJC_Grants;

/*Verified - used in grantors table*/
CREATE TYPE funder_type as ENUM ('philanthropy', 'government', 'corporate', 'individual', 'professionalGroup');

/*Verified */
CREATE TABLE grantors(
  /*List of grantor organizations - unduplicated*/
  grantor_ID serial PRIMARY KEY,
  org_Name TEXT NOT Null,
  org_alias TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  zip NUMERIC (5,0),
  funder_type funder_type,
  /*Specified in CREATE TYPE funder_type: philanthropy, government, corporate_Philanthropy, individual*/
  parent_Organization TEXT
);

/*Verified */
/*Sample data for grantors table*/
INSERT INTO grantors(org_Name, address, city, state, zip, funder_type, parent_organization) VALUES ('My Business', '111 E 222', 'Chicago', 'IL', 60600, 'government', 'MAJI LLC');
INSERT INTO grantors(org_Name, address, city, state, zip, funder_type, parent_organization) VALUES ('Her Business', '222 E 222', 'Zoom', 'IL', 60605, 'philanthropy', 'USA');


/*Verified */
CREATE TYPE person_status as ENUM ('active', 'noLongerWithOrg', 'noLongerPrimary', 'unknown');

/*Verified */
CREATE TYPE grant_status as ENUM ('active', 'prospective Grant Lead (new)', 'former Grant Lead');

/*Verified */
CREATE TABLE grantor_contacts(
  /*One entry per grantors contact. Contacts are not deleted but status is changed. If a contact switched organizations then a new entry is created.*/
  contact_ID serial PRIMARY KEY,
  organization SMALLINT,
  name_prefix TEXT,
  first_Name TEXT NOT Null,
  last_Name TEXT NOT Null,
  org_Status person_status,
  grant_Status grant_status,
  title TEXT,
  department TEXT,
  email VARCHAR (50),
  telephone NUMERIC (10,0)
);

/*Verified */
/*Sample data for grantor_contacts table*/
INSERT INTO grantor_contacts (organization, first_name, last_Name, org_Status, grant_Status, title, email, telephone) VALUES ('1', 'Johnny', 'Walker', 'active', 'active', 'Head', 'Johnny@walker.com', 1234567890);

INSERT INTO grantor_contacts (organization, first_name, last_Name, org_Status, grant_Status, title, email, telephone) VALUES ('2', 'Remy', 'Martin', 'active', 'active', 'Personnel', 'Remy@martin.com', 0987654321);

/*Verified */
CREATE TABLE grant_log (
  /*List of grants - unduplicated*/
  grant_ID serial PRIMARY KEY,
  name TEXT NOT Null,
  announce_Date Date,
  start_Date Date,
  end_Date Date,
  target_Client Text,
  target_Service Text,
  direct_Grant_Amount INT,
  indirect_Grant_Donation TEXT
);

/*Verified */
/*Sample data for grant_log table*/
INSERT INTO grant_log (name, announce_Date, start_Date, end_Date, target_Client, target_Service, direct_Grant_Amount) VALUES ('Best Grant in the World', '2017-11-01', '2017-12-01', '2018-11-30', 'People in Need', 'Helping Them', 5000000);

INSERT INTO grant_log (name, announce_Date, start_Date, end_Date, target_Client, target_Service, direct_Grant_Amount) VALUES ('Worst Grant in the World', '2017-01-01', '2017-12-15', '2018-11-15', 'Nondeserving', 'Inefficiency', 10000000);

INSERT INTO grant_log (name, announce_Date, start_Date, end_Date, target_Client, target_Service, direct_Grant_Amount) VALUES ('Medium Grant in the World', '2017-01-01', '2017-12-15', '2018-11-15', 'Nondeserving', 'Inefficiency', 50);


/*Verified */
CREATE TABLE grant_log_Contacts (
  /*List of grants (duplicated) matched with grantor_contacts. A grantor may be duplicated from different grants or grant renewals*/
  grant_ID SMALLINT,
  contact_ID SMALLINT
);
/*Sample data for grant_log_Contacts*/
INSERT INTO grant_log_Contacts (grant_ID, contact_ID) VALUES (1,1);
INSERT INTO grant_log_Contacts (grant_ID, contact_ID) VALUES (2,2);
INSERT INTO grant_log_Contacts (grant_ID, contact_ID) VALUES (1,2);
INSERT INTO grant_log_Contacts (grant_ID, contact_ID) VALUES (3,1);


/*Verified */
CREATE VIEW grant_log_Org_Name AS SELECT
 grant_log.grant_ID AS grant_ID, grant_log.name AS Grant_Name, string_agg(grantors.org_Name, ', ')  as Grantor_Names, grant_log.direct_Grant_Amount AS Grant_Amount, grant_log.indirect_Grant_Donation AS Additional_Grant_InKind
FROM grant_log LEFT JOIN grant_log_Contacts ON grant_log.grant_ID=grant_log_Contacts.grant_ID
INNER JOIN grantor_contacts on grant_log_Contacts.contact_ID = grantor_contacts.contact_ID
JOIN grantors on grantor_contacts.organization=grantors.grantor_ID
GROUP BY grant_log.grant_ID;

/*Verified */
CREATE TABLE grant_YJC_Leads(
  /*List of YJC_leads matched with grants. Data is not deleted but new entries created if staff member changes. Typically only one entry per grant per department*/
  record SERIAL not Null,
  grant_ID SMALLINT,
  YJC_Dept TEXT,
  YJC_Lead_Name TEXT,
  YJC_Lead_Status person_status,
  grant_Status grant_status
);

/*Verified */
/*Sample data for grant_YJC_Leads*/
INSERT INTO grant_YJC_Leads (grant_ID, YJC_Dept, YJC_Lead_Name, YJC_Lead_Status) VALUES (1, 'OSY', 'Billy Jones', 'active');

INSERT INTO grant_YJC_Leads (grant_ID, YJC_Dept, YJC_Lead_Name, YJC_Lead_Status) VALUES (2, 'ISY', 'Your Mama', 'active');

INSERT INTO grant_YJC_Leads (grant_ID, YJC_Dept, YJC_Lead_Name, YJC_Lead_Status) VALUES (3, 'ISY', 'Your Mama', 'active');

INSERT INTO grant_YJC_Leads (grant_ID, YJqant_Funders_Concatenated.grant_ID
-- GROUP BY Dept
-- ORDER BY Total_Grant_Funding DESC;

CREATE VIEW grant_by_Department  AS SELECT
 min(grant_YJC_Leads.YJC_dept) AS Dept, min(grant_log.grant_ID) AS grant_ID, grant_log.name AS Grant_Name, string_agg(grantors.org_Name, ', ')  as Grantor_Names, grant_log.direct_Grant_Amount AS Grant_Amount, grant_log.indirect_Grant_Donation AS Additional_Grant_InKind
FROM grant_log LEFT JOIN grant_log_Contacts ON grant_log.grant_ID=grant_log_Contacts.grant_ID
RIGHT JOIN grant_YJC_Leads on grant_log.grant_ID=grant_YJC_Leads.grant_ID
INNER JOIN grantor_contacts on grant_log_Contacts.contact_ID = grantor_contacts.contact_ID
JOIN grantors on grantor_contacts.organization=grantors.grantor_ID
GROUP BY Grant_Name, Grant_Amount, Additional_Grant_InKind;



/*Verified */
CREATE TABLE reports(
  /*Individual report deadlines for List of grants (duplicated) */
  grant_ID SMALLINT,
  report_id serial PRIMARY KEY,
  report_Name TEXT Not Null,
  report_Due_Date Date Not Null,
  target_Submittal_Date Date,
  submission_Status TEXT
);

/*Verified */
INSERT INTO reports (grant_ID, report_Name, report_Due_Date, target_Submittal_Date, submission_Status ) VALUES (1, 'Final Report', '2018-06-01', '2018-05-15', 'active');

CREATE VIEW reports_by_Department_2018 AS SELECT reports.grant_ID as Grant_ID, grant_by_Department.Dept AS Dept, grant_by_Department.Funders AS Funders, reports.report_Name AS Report_Name, reports.target_Submittal_Date AS Target_Submittal_Date, reports.report_Due_Date AS report_Due_Date, reports.submission_Status AS submission_Status
FROM reports
WHERE Extract (Year from reports.report_Due_Date) = 2018
LEFT JOIN grant_by_Department ON reports.grant_ID=grant_by_Department.Grant_ID
GROUP BY Dept
ORDER BY Target_Submittal_Date ASC
);

/*Verified */
CREATE TABLE funder_Goals(
  /*Individual funder goals and deadlines for List of grants (duplicated) */
  grant_ID SMALLINT Not Null,
  funder_Goal_ID serial PRIMARY KEY,
  category TEXT Not Null,
  /*EG Recruitments, Enrollees, Attendees, Placed, Retained, Served, etc.*/
  percent_or_Number TEXT Not Null,
  deadline DATE Not Null,
  description TEXT,
  parameters TEXT
);

/*Sample funder_Goals data*/
/*Verified */
INSERT INTO funder_Goals (grant_ID, category, percent_or_number, deadline, description, parameters) VALUES (1, 'Recruitment', '300', '2017-12-31', 'Recruitment of target participants evidenced by interest cards', 'Must be 18-24');

INSERT INTO funder_Goals (grant_ID, category, percent_or_number, deadline, description, parameters) VALUES (3, 'Placements', '20%', '2018-01-31', 'Placement of target participants into jobs', 'Must be good jobs');

INSERT INTO funder_Goals (grant_ID, category, percent_or_number, deadline, description, parameters) VALUES (1, 'Recruitment', '300', '2018-03-31', 'Recruitment of target participants evidenced by interest cards', 'Must be 18-24');



/*Verified */
CREATE TABLE internal_Metrics(
    /*Individual internal metric and deadlines for List of grants (duplicated) */
    grant_ID SMALLINT Not Null,
    internal_Metric_ID serial PRIMARY KEY,
    category TEXT Not Null,
    /*EG Recruitments, Enrollees, Attendees, Placed, Retained, Served, etc.*/
    percent_or_Number TEXT Not Null,
    internal_Deadline DATE Not Null,
    description TEXT,
    parameters TEXT,
    funder_Goal_ID_Parent SMALLINT
  );

  /*Sample internal_Metrics data*/
  /*Verified */
INSERT INTO internal_Metrics (grant_ID, category, percent_or_Number, internal_Deadline, description, parameters, funder_Goal_ID_Parent) VALUES (1, 'Recruitment', '325', '2017-12-15', 'Recruitment of target participants evidenced by interest cards', 'Must be 18-24', 1);

INSERT INTO internal_Metrics (grant_ID, category, percent_or_Number, internal_Deadline, description, parameters, funder_Goal_ID_Parent)  VALUES (3, 'Placements', '20%', '2018-01-31', 'Placement of target participants into jobs', 'Must be good jobs', 2);

/*Verified */
CREATE TYPE dept as ENUM ('admin', 'ISY', 'OSY', 'DEV', 'COMM');

/*Verified */
CREATE TABLE strategy_for_internal_Metrics(
    /*Individual internal metric and deadlines for List of grants (duplicated) One row per department. Goal # should not be duplicated*/
    record SERIAL PRIMARY KEY,
    internal_Metric_ID SMALLINT REFERENCES internal_Metrics Not Null,
    strategy_Goal SMALLINT Not Null,
    strategy_Goal_Description TEXT Not Null,
    specified_Targets TEXT,
    internal_Deadline DATE Not Null,
    dept dept Not Null
  );

  /*Verified */
INSERT INTO strategy_for_internal_Metrics(internal_Metric_ID, strategy_Goal, strategy_Goal_Description, specified_Targets, internal_Deadline, dept) VALUES (1, 150, 'Recruitment of target participants online', 'High schoolers', '2017-12-01', 'COMM');

INSERT INTO strategy_for_internal_Metrics(internal_Metric_ID, strategy_Goal, strategy_Goal_Description, specified_Targets, internal_Deadline, dept) VALUES (1, 175, 'Recruitment of target participants at fairs', 'Dropped out students', '2017-12-01', 'OSY');

INSERT INTO strategy_for_internal_Metrics(internal_Metric_ID, strategy_Goal, strategy_Goal_Description, specified_Targets, internal_Deadline, dept) VALUES (2, 300, 'Placement of target participants into jobs', 'Enrollees who have completed training', '2018-01-15', 'ISY');

CREATE VIEW strategy_Funnel_2018 AS SELECT strategy_for_internal_Metrics.internal_Metric_ID, grant_by_Department.Dept AS Dept,
FROM reports
WHERE Extract (Year from reports.report_Due_Date) = 2018
LEFT JOIN grant_by_Department ON reports.grant_ID=grant_by_Department.Grant_ID
GROUP BY Dept
ORDER BY Target_Submittal_Date ASC
);
