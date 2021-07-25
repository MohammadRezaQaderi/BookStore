drop schema Book_store;
create database Book_store;
	
use Book_store;

CREATE TABLE Persons (
    PersonID INT NOT NULL AUTO_INCREMENT UNIQUE,
    PersonNationalID bigint NOT NULL,
    PersonFirstName VARCHAR(35) NOT NULL,
    PersonLastName VARCHAR(35) NOT NULL,
    PRIMARY KEY (PersonID)
);

CREATE TABLE Accounts (
    AccountUserName VARCHAR(255) NOT NULL,
    AccountPassword VARCHAR(255) NOT NULL,
    AccountBalance INT DEFAULT 0,
    created_date DATE,
    PersonID INT NOT NULL,
    PRIMARY KEY (AccountUserName),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);


CREATE TABLE Students (
    StudentID VARCHAR(25) NOT NULL,
    UniversityName VARCHAR(25) NOT NULL,
    PersonID INT NOT NULL,
    PRIMARY KEY (PersonID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Instructors (
    InstructorID VARCHAR(25) NOT NULL,
    UniversityName VARCHAR(25) NOT NULL,
    PersonID INT NOT NULL,
    PRIMARY KEY (PersonID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);


CREATE TABLE Regulars (
    Job VARCHAR(25) NOT NULL,
    PersonID INT NOT NULL,
    PRIMARY KEY (PersonID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Librarians (
    PersonID INT NOT NULL,
    PRIMARY KEY (PersonID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Managers (
    PersonID INT NOT NULL,
    PRIMARY KEY (PersonID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Phones (
    Phone VARCHAR(14) NOT NULL,
    PersonID INT NOT NULL,
    PRIMARY KEY (Phone),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Address (
    Address VARCHAR(225) NOT NULL,
    PersonID INT NOT NULL,
    PRIMARY KEY (Address),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);

CREATE TABLE Publishers (
    PublisherName VARCHAR(25) NOT NULL,
    Address VARCHAR(225) NOT NULL,
    Website VARCHAR(100) NOT NULL,
    PRIMARY KEY (PublisherName)
);

CREATE TABLE Books (
    BookID INT NOT NULL AUTO_INCREMENT UNIQUE,
    Titel VARCHAR(255) NOT NULL,
    Years INT NOT NULL,
    -- Category ENUM('ALL', 'STUDENT', 'INSTRUCTOR') NOT NULL,
    Category varchar(225) not null,
    Pages INT NOT NULL,
    Price INT NOT NULL,
    Edition INT NOT NULL,
    Valume INT DEFAULT 0 NOT NULL,
    PublisherName VARCHAR(25) NOT NULL,
    PRIMARY KEY (BookID),
    FOREIGN KEY (PublisherName)
        REFERENCES Publishers (PublisherName)
);

CREATE TABLE Stores (
    BookCode INT NOT NULL AUTO_INCREMENT UNIQUE,
    BookID INT NOT NULL,
    PRIMARY KEY (BookCode),
    FOREIGN KEY (BookID)
        REFERENCES Books (BookID)
);

CREATE TABLE BooksAuthor (
    AuthorName varchar(255) NOT NULL,
    BookID INT NOT NULL,
    PRIMARY KEY (BookID , AuthorName),
    FOREIGN KEY (BookID)
        REFERENCES Books (BookID)
);

-- trigger to handel 
DELIMITER &&
drop trigger if exists historyChecking;
create trigger historyChecking
before insert on histories 
for each row
begin
	insert into mails (PersonID,message) value (new.personID,new.message);
END &&
DELIMITER ;

-- trigger 

DELIMITER &&
drop trigger if exists historyUpdate;
create trigger historyUpdate
before update on histories 
for each row
begin
	insert into mails (PersonID,message) value (new.personID,new.message);
END &&
DELIMITER ;


CREATE TABLE Histories (
    HistoryID INT NOT NULL AUTO_INCREMENT UNIQUE,
    PersonID INT NOT NULL,
    BookCode INT NOT NULL,
    message VARCHAR(225) DEFAULT 'Seccussful',
    start_date DATE NOT NULL,
    return_date DATE DEFAULT 0,
    duration int not null default 5,
    cost INT NOT NULL,
    valid INT DEFAULT 0 NOT NULL,
    PRIMARY KEY (HistoryID),
    CONSTRAINT FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID),
    CONSTRAINT FOREIGN KEY (BookCode)
        REFERENCES Stores (BookCode)
);


DELIMITER &&
drop trigger if exists loginsCheck;
create trigger loginsCheck
before update on Logins 
for each row
begin
	insert into mails (PersonID,message) value (new.personID,new.message);
END &&
DELIMITER ;


DELIMITER &&
create trigger accesses
    before insert on logins
    for each row 
    begin
    declare tagName varchar(255);
    set tagName = new.tag;
    if(new.typeID = 'manager') then
		grant all on deleteAccount to tagName@'localhost';
	end if;
	End &&
DELIMITER ;



CREATE TABLE Logins (
    PersonID INT NOT NULL UNIQUE,
    tag VARCHAR(255) NOT NULL,
    typeID VARCHAR(225) NOT NULL,
    PRIMARY KEY (tag),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);


CREATE TABLE Mails (
    MailID INT NOT NULL AUTO_INCREMENT UNIQUE,
    PersonID INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    times DATE NOT NULL default 0,
    PRIMARY KEY (MailID),
    FOREIGN KEY (PersonID)
        REFERENCES Persons (PersonID)
);


   -- manager and laberians function

-- add book finished
DELIMITER && 
create function addBook(bookID int )
returns varchar(255) deterministic
begin
	declare result varchar(255);
	if(exists(select * from Books where Books.BookID = bookID))then
		insert into Stores (BookID) value (bookId);
		set result = 'Book Added successfuly';
        return result;
	else
		set result = 'There is no such Book ID';
        return result;
	end if;
end	&&
DELIMITER ;


-- 
DELIMITER && 
create function addNewBook(num int , personidInput int)
returns varchar(255) deterministic
begin
	declare result varchar(250);
    if(num < 0) then 
		set	result = 'Invalid Increase Amount';
        return result;
	end if;
	if(exists(select * from Accounts where Accounts.PersonID = personidInput))then
		update accounts set accounts.AccountBalance = accounts.AccountBalance + num	;
		set result = 'Increase Balance successfuly';
        return result;
	else
		set result = 'There is no such person';
        return result;
	end if;
end	&&
DELIMITER ;


-- delete users finished
DELIMITER && 
create function deleteAccount(PersonIdInput int)
returns varchar(255) deterministic
begin
	declare result varchar(255);
	if(exists(select * from Persons where Persons.PersonID = PersonIdInput))then
			delete from Mails where Mails.PersonID = PersonIdInput;
            delete from Histories where Histories.PersonID = PersonIdInput;
            delete from Address where Address.PersonID = PersonIdInput;
            delete from Phones where Phones.PersonID = PersonIdInput;
			delete from Regulars where Regulars.PersonID = PersonIdInput;
            delete from Students where Students.PersonID = PersonIdInput;
            delete from Instructors where Instructors.PersonID = PersonIdInput;
            delete from Accounts where Accounts.PersonID = PersonIdInput;
            delete from Persons where Persons.PersonID = PersonIdInput;
		set result = 'User Delete Successfuly';
        return result;
	else
		set result = 'The User Is not find';
        return result;
	end if;
end	&&
DELIMITER ;



-- find user by LastName finished
DELIMITER &&
create procedure findByLastName(LastName varchar(35))
	begin
		select * 
		from Accounts join Persons
		where Accounts.PersonID = Persons.PersonID and Persons.PersonLastName = LastName
		;
	end &&
DELIMITER ;
    
-- find user by FirstName finished
DELIMITER &&
create procedure findByFirstName(FirstName varchar(35))
	begin
		select * 
		from Accounts join Persons
		where Accounts.PersonID = Persons.PersonID and Persons.PersonFirstName = FirstName
		;
	end &&
DELIMITER ;

-- find user by LastName finished
DELIMITER &&
create procedure InfoUser(UserName varchar(225))
	begin
		select * 
		from Accounts join Persons join Address join Phone 
		where Accounts.AccountUserName = UserName and Persons.PersonID = Accounts.PersonID and Persons.PersonID = Address.PersonID and Persons.PersonID = Phone.PersonID
        ;
	end &&
DELIMITER ;

-- find user Book history
DELIMITER &&
create procedure BookHistory(PersonIdInput int)
	begin
		select Mails.message , Mails.times 
		from Mails
		where PersonIdInput = Mails.PersonID
        order by Mails.times desc
		;
	end &&
DELIMITER ;



 -- persons functions 
 
 
 
 
-- 1) get back the information of user finished
DELIMITER &&
create procedure seeInfo(PersonIDinput int )
	begin
		select * 
		from Accounts join Persons
		where Accounts.PersonID = Persons.PersonID and Persons.PersonID = PersonIDinput
		;
	end &&
DELIMITER ;
    
-- 1*) Check delation
DELIMITER &&
create procedure BookDelay(in PersonIDinput int , out Delays int)
	begin
		select count(*) 
        into Delays
		from Persons join histories
		where histories.PersonID = Persons.PersonID and Persons.PersonID = PersonIDinput and (((DATE_SUB(curdate(), INTERVAL histories.duration DAY)) < histories.start_date) and (histories.start_date > (DATE_SUB(curdate(), INTERVAL 2 MONTH))))
		;
	end &&
DELIMITER ;

-- 2) get the book back finished (not compile)
DELIMITER &&   
create function getBack(BookCodeinput int)
returns varchar(255) deterministic
begin
	declare result varchar(255);
    if(exists(select * from Stores where Stores.BookCode = BookCodeinput)) then 
		if(exists(select * from Histories where Histories.BookCode = BookCodeinput and Histories.return_date = 0 and Histories.valid = 1))then
			update Histories  set Histories.return_date = current_date();
			set	result = 'Book has been give back successfully';	
			return result;
		end if;
	else 
		set result = 'We Don`t have this book';
        return result;
	end if;
end	&&
DELIMITER ;



-- 3) login finished
 DELIMITER && 
create function login(usernameInput varchar(255) , passwordInput varchar(255))
returns varchar(255) deterministic
begin
	declare result varchar(255);
    declare personID int;
    declare typeID varchar(255);
    if(exists(select * from Accounts where Accounts.AccountUserName = usernameInput and Accounts.AccountPassword = sha1(passwordInput)))then
		set personID = (select Accounts.PersonID from Accounts where Accounts.AccountUserName = usernameInput and Accounts.AccountPassword = sha1(passwordInput));
        if(exists(select * from Students where Students.PersonID = personID))then
			set typeID = 'Student';
		elseif(exists(select * from instructors where instructors.PersonID = personID))then
			set typeID = 'Instructor';
		elseif(exists(select * from regulars where regulars.PersonID = personID))then
			set typeID = 'Regular';
		elseif(exists(select * from managers where managers.PersonID = personID))then
			set typeID = 'Manager';
		elseif(exists(select * from librarians where librarians.PersonID = personID))then
			set typeID = 'Librarian';
		end if;
		insert into logins (PersonID , tag , typeID) value (personID , concat(usernameInput , "  " , passwordInput ,"  " , current_date()) , typeID);
        set result = 'loged in successfuly';
		return result;
    else
		set result = 'There is no User Like This';
        return result;
	end if;
end &&
DELIMITER ;



-- 4) Sign up finished
 DELIMITER && 
create function signup(AccountUserName varchar(255) , AccountPassword varchar(255) , PersonFirstName varchar(35) ,  PersonLastName varchar(35) , PersonNationalID varchar(15) , userType varchar(15) , universityName varchar(25) ,  SIID varchar(25))
returns varchar(255) deterministic
begin
	declare result varchar(255);
    declare personID int;
    declare typeID varchar(255);
    if(exists(select * from Persons where persons.PersonNationalID = PersonNationalID))then
		set result = 'Person National ID is exist already';
        return result;
	end if;
    if(exists(select * from Accounts where LOWER(Accounts.AccountUserName) = LOWER(AccountUserName)))then
		set result = 'userName is exist already';
        return result;
    end if;
    if (length(AccountUserName) < 6)then
		set result = 'username should have more than 5 character';
        return result;
    end if;
    if (length(AccountPassword) < 8)then
		set result = 'password should have more than 7 character';
        return result;
    end if;
    if (AccountPassword like '%[0-9]%' or LOWER(AccountPassword) like '%[a-z]%') then
		set result = 'Password should have numeric and character in it';
        return result;
    end if;
    if(userType = 'Student')then
		if(exists(select * from students where students.StudentID = SIID  and students.UniversityName = universityName))then
			set result = 'Student ID is exists Already';
			return result;
		end if;
		insert into Persons ( PersonNationalID , PersonFirstName , PersonLastName ) value (PersonNationalID , PersonFirstName , PersonLastName);
		set personID = (select persons.PersonID from persons where persons.PersonNationalID = PersonNationalID); 
		insert into Accounts (AccountUserName , AccountPassword , AccountBalance , created_date ,PersonID) value (AccountUserName , sha1(AccountPassword) , 0 , current_date() , personID);
		insert into Students (StudentID , UniversityName , PersonID) value ( SIID, universityName , personID);
		set result = 'successfull';
		return result;
	end if ;
    if(userType = 'Instructor')then
		if(exists(select * from instructors where instructors.InstructorID = SIID  and instructors.UniversityName = universityName))then
				set result = 'Instructor ID is exists Already';
				return result;
		end if;
		insert into Persons ( PersonNationalID , PersonFirstName , PersonLastName ) value (PersonNationalID , PersonFirstName , PersonLastName);
		set personID = (select persons.PersonID from persons where persons.PersonNationalID = PersonNationalID); 
		insert into Accounts (AccountUserName , AccountPassword , AccountBalance , created_date ,PersonID) value (AccountUserName , sha1(AccountPassword) , 0 , current_date() , personID);
		insert into Instructors (InstructorID , UniversityName , PersonID) value ( SIID, universityName , personID);
		set result = 'successfull';
		return result;
	end if;
	if(userType = 'Regular')then
		insert into Persons ( PersonNationalID , PersonFirstName , PersonLastName ) value (PersonNationalID , PersonFirstName , PersonLastName);
		set personID = (select persons.PersonID from persons where persons.PersonNationalID = PersonNationalID); 
		insert into Accounts (AccountUserName , AccountPassword , AccountBalance , created_date ,PersonID) value (AccountUserName , sha1(AccountPassword) , 0 , current_date() , personID);
		insert into Regulars (Job , PersonID) value (universityName , personID);
		set result = 'successfull';
		return result;
	end if;
	if(userType = 'Manager')then
		insert into Persons ( PersonNationalID , PersonFirstName , PersonLastName ) value (PersonNationalID , PersonFirstName , PersonLastName);
		set personID = (select persons.PersonID from persons where persons.PersonNationalID = PersonNationalID); 
		insert into Accounts (AccountUserName , AccountPassword , AccountBalance , created_date ,PersonID) value (AccountUserName , sha1(AccountPassword) , 0 , current_date() , personID);
		insert into Managers (PersonID) value (personID);
		set result = 'successfull';
		return result;
	end if;
	if(userType = 'Librarians')then
		insert into Persons ( PersonNationalID , PersonFirstName , PersonLastName ) value (PersonNationalID , PersonFirstName , PersonLastName);
		set personID = (select persons.PersonID from persons where persons.PersonNationalID = PersonNationalID); 
		insert into Accounts (AccountUserName , AccountPassword , AccountBalance , created_date ,PersonID) value (AccountUserName , sha1(AccountPassword) , 0 , current_date() , personID);
		insert into Librarians (PersonID) value (personID);
		set result = 'successfull';
		return result;
	end if;
end &&
DELIMITER ;



 
-- 5) increament balance finished
DELIMITER && 
create function increaseBalance(Amount int , personIdInput int)
returns varchar(255) deterministic
begin
	declare result varchar(255);
    if(Amount < 0) then 
		set	result = 'Invalid Increase Amount';
        return result;
	end if;
	if(exists(select * from Accounts where Accounts.PersonID = personIdInput))then
		update Accounts set Accounts.AccountBalance = Accounts.AccountBalance + Amount;
		set result = 'Increase Balance successfuly';
        return result;
	else
		set result = 'There is no such person';
        return result;
	end if;
end	&&
DELIMITER ;


-- 6) borrow book (not finished)
DELIMITER && 
create function borrowBook(personIdBorrow int , bookCodeBorrow int)
returns varchar(255) deterministic
begin
	declare result varchar(255);
    declare price int ;
    declare delay int;
    call BookDelay(personIdBorrow , delay);
    set price = (select (Books.Price*5/100) from Books join Stores where Stores.BookCode = BookCodeBorrow and Stores.BookID = Books.BookID );
    if(not exists(select * from Stores where Stores.BookCode = BookCodeBorrow))then
		set result = 'There is no such book in store';
        return result;
	elseif(not exists(select * from Accounts where Accounts.PersonID = personIdBorrow))then
		set result = 'There is no such User';
        return result;
    elseif(delay >= 4)then
		set result = 'You are Punished for book delivery';
        return result;
    elseif(not exists (select * from Accounts where Accounts.PersonID = personIdBorrow and Accounts.AccountBalance > price))then
		set result = 'You dont have enough money';
        return result;
	else
		insert into Histories(PersonID , BookCode , message , start_date , duration , cost) value (personIdBorrow ,BookCodeBorrow , 'The Book give it' , curdate() , 10 , price);
        insert into Mails(PersonID , message , times) value (personIdBorrow , concat(personIdBorrow , " Borrow This Book " ,  BookCodeBorrow  ," In This Time " , curdate()) , current_date());
		set result = 'Successfuly given';
        return result;
    end if;
end	&&
DELIMITER ;

DELIMITER && 
create function logout(tagInput varchar(255))
returns varchar(255) deterministic
begin
	declare result varchar(255);
    if(exists(select * from logins where logins.tag = tag))then
		delete from logins where login.tag = tagInput;
        set result = 'Log out Successfuly';
        return result;
	else 
		set result = 'There is no like that Loggedin';
        return result;
	end if;
end	&&
DELIMITER ;

-- 7) log out finished successfuly
DELIMITER && 
create function logout(tagInput varchar(255))
returns varchar(255) deterministic
begin
	declare result varchar(255);
    if(exists(select * from logins where logins.tag = tag))then
		delete from logins where login.tag = tagInput;
        set result = 'Log out Successfuly';
        return result;
	else 
		set result = 'There is no like that Loggedin';
        return result;
	end if;
end	&&
DELIMITER ;



-- 8) search not finished
DELIMITER && 
create procedure searchBook(titleInput varchar(255) , authorNameInput varchar(255) , editionInput int  , yearInput int)
Begin 
drop temporary table if exists temp;
create temporary table temp(BookID int,Title varchar(255),Years int,Category varchar(255),Pages int,Price int,Edition int,Valume int,PublisherName Varchar(25),BookCode int);
INSERT INTO temp select Books.BookID, Books.Titel, Years, Category, Pages, Price, Edition, Valume, PublisherName, BookCode from Books join stores where Books.BookID = stores.BookID;
IF(yearInput != 0) then
	delete from temp where temp.Years != yearInput;
end if;
if (editionInput != 0) then
	delete from temp where temp.Edition != editionInput;
end if;
if (titleInput != 'None') then
	delete from temp where temp.Title != titleInput;
end if;
if (authorNameInput != 'None') then
	delete from temp where temp.BookID not in (select Books.BookID from Books join BooksAuthor Where BooksAuthor.AuthorName = authorNameInput);
End if;
SELECT * FROM temp;
end	&&
DELIMITER ;


-- insert into tables



insert into Publishers (PublisherName , Address , Website) values ('negarestan','Tehran-Alborz','negarestan.com'),
('peydayesh','Tehran-sattar','peydayesh.ir'),
('nikan','Mashhad-kohsangi','nikan.ir'),
('shohada','Hamedan-soleimani','shohada.com'),
('shohadaNashr','yazd-taleghani','shohadaNashr.ir'),
('sefid','Mashhad-enghelab','seifd.com'),
('aboqarib','Khoramshahr-beheshti','abogharib.com'),
('aboamer','Khoramshahr-enghelab','aboamer.ir'),
('islamenab','Qom-imamkhomeini','islamenab.com'),
('ghalam','Qom-taleghani','ghalam.ir');

insert into books(Titel , Years ,Category , Pages , Price , Edition ,Valume , PublisherName) values ('shazhdeh-koholo', 1371 , 'science' , 3113 , 4891 , 8 , 0 , 'aboqarib'),
('Java',1363,'general',3416,3993,10,0,'shohada'),
('Java',1363,'general',1470,2112,10,1,'shohada'),
('Islamshenasi',1383,'university',1720,4300,8,0,'negarestan'),
('assare-morakab',1381,'general',1031,3717,4,0,'aboqarib'),
('assare-morakab',1381,'general',3559,3099,4,1,'aboqarib'),
('assare-morakab',1381,'general',3456,356,4,2,'aboqarib'),
('Shahnameh',1382,'science',2407,137,8,0,'islamenab'),
('Shahnameh',1382,'science',806,1888,8,1,'islamenab'),
('Shahnameh',1382,'science',4815,1413,8,2,'islamenab'),
('Shahnameh',1382,'science',816,4506,8,3,'islamenab'),
('Shahnameh',1382,'science',499,2613,8,4,'islamenab'),
('sepid-dandan',1395,'science',4067,1484,3,0,'shohada'),
('sepid-dandan',1395,'science',3146,3384,3,1,'shohada'),
('sepid-dandan',1395,'science',686,3832,3,2,'shohada'),
('sepid-dandan',1395,'science',4854,4436,3,3,'shohada'),
('sepid-dandan',1395,'science',1311,3727,3,4,'shohada'),
('kebrit-forush',1363,'mazhabi',2588,2233,0,0,'shohadaNashr'),
('kebrit-forush',1363,'mazhabi',3690,2551,0,1,'shohadaNashr'),
('kebrit-forush',1363,'mazhabi',2587,1985,0,2,'shohadaNashr'),
('kebrit-forush',1363,'mazhabi',3690,1824,0,3,'shohadaNashr'),
('biology',1385,'historic',4732,1548,4,0,'nikan'),
('biology',1385,'historic',1410,1484,4,1,'nikan'),
('biology',1385,'historic',996,3236,4,2,'nikan'),
('biology',1385,'historic',4483,2465,4,3,'nikan'),
('biology',1385,'historic',3572,4665,4,4,'nikan'),
('Hafez',1361,'science',1579,2104,4,0,'islamenab'),
('Hafez',1361,'science',972,4176,4,1,'islamenab'),
('kebrit-forush',1365,'science',1743,4843,10,0,'aboamer'),
('kebrit-forush',1365,'science',771,4142,10,1,'aboamer'),
('kebrit-forush',1365,'science',1956,1307,10,2,'aboamer'),
('kebrit-forush',1365,'science',508,4877,10,3,'aboamer'),
('assare-morakab',1385,'historic',3389,4061,8,0,'shohadaNashr'),
('pezeshki',1362,'mazhabi',2692,939,7,0,'aboamer'),
('pezeshki',1362,'mazhabi',560,1497,7,1,'aboamer'),
('pezeshki',1362,'mazhabi',231,4779,7,2,'aboamer'),
('pezeshki',1362,'mazhabi',2613,3997,7,3,'aboamer'),
('sepid-dandan',1394,'mazhabi',1041,2902,8,0,'shohadaNashr'),
('sepid-dandan',1394,'mazhabi',1183,3660,8,1,'shohadaNashr'),
('sepid-dandan',1394,'mazhabi',3669,641,8,2,'shohadaNashr'),
('kebrit-forush',1397,'historic',1359,1160,5,0,'aboqarib'),
('kebrit-forush',1397,'historic',4583,1331,5,1,'aboqarib'),
('kebrit-forush',1397,'historic',3398,2084,5,2,'aboqarib'),
('kebrit-forush',1397,'historic',577,3424,5,3,'aboqarib'),
('Java',1380,'historic',2321,2146,4,0,'peydayesh'),
('maslakh-eshgh',1365,'historic',3949,4093,8,0,'aboamer'),
('maslakh-eshgh',1365,'historic',563,974,8,1,'aboamer'),
('maslakh-eshgh',1365,'historic',4163,2638,8,2,'aboamer'),
('maslakh-eshgh',1365,'historic',4568,636,8,3,'aboamer'),
('maslakh-eshgh',1365,'historic',2782,1508,8,4,'aboamer'),
('Java',1378,'historic',998,341,2,0,'nikan'),
('assare-morakab',1396,'general',3301,3369,0,0,'aboqarib'),
('biology',1378,'historic',3509,3819,10,0,'peydayesh'),
('biology',1378,'historic',1443,2050,10,1,'peydayesh'),
('biology',1378,'historic',1728,638,10,2,'peydayesh'),
('biology',1378,'historic',2638,974,10,3,'peydayesh'),
('darbareye-eli',1374,'mazhabi',4112,1781,8,0,'nikan'),
('darbareye-eli',1374,'mazhabi',1334,4046,8,1,'nikan'),
('darbareye-eli',1374,'mazhabi',2210,257,8,2,'nikan'),
('darbareye-eli',1374,'mazhabi',2411,1828,8,3,'nikan'),
('Islamshenasi',1377,'general',3355,885,6,0,'islamenab'),
('Islamshenasi',1377,'general',2639,3322,6,1,'islamenab'),
('Islamshenasi',1377,'general',1036,2947,6,2,'islamenab'),
('Islamshenasi',1377,'general',928,3234,6,3,'islamenab'),
('Karbalaye4',1377,'mazhabi',1702,3095,7,0,'ghalam'),
('Karbalaye4',1377,'mazhabi',2526,3470,7,1,'ghalam'),
('Karbalaye4',1377,'mazhabi',3185,3114,7,2,'ghalam'),
('Karbalaye4',1377,'mazhabi',927,3173,7,3,'ghalam'),
('Karbalaye4',1377,'mazhabi',1457,1762,7,4,'ghalam'),
('pezeshki',1360,'general',2434,4776,4,0,'shohada'),
('pezeshki',1360,'general',1354,1476,4,1,'shohada'),
('pezeshki',1360,'general',1207,2517,4,2,'shohada'),
('pezeshki',1360,'general',2929,4133,4,3,'shohada'),
('pezeshki',1360,'general',1512,850,4,4,'shohada'),
('C Program',1399,'mazhabi',1428,1516,4,0,'peydayesh'),
('C Program',1399,'mazhabi',1481,3082,4,1,'peydayesh'),
('biology',1398,'mazhabi',924,2218,9,0,'sefid'),
('biology',1398,'mazhabi',4775,1466,9,1,'sefid'),
('biology',1398,'mazhabi',740,4193,9,2,'sefid'),
('biology',1398,'mazhabi',437,2145,9,3,'sefid'),
('biology',1398,'mazhabi',2997,4280,9,4,'sefid'),
('pezeshki',1375,'university',1770,3685,7,0,'peydayesh'),
('pezeshki',1375,'university',846,3117,7,1,'peydayesh'),
('pezeshki',1375,'university',4056,3627,7,2,'peydayesh'),
('pezeshki',1375,'university',4121,3636,7,3,'peydayesh'),
('pezeshki',1375,'university',547,626,7,4,'peydayesh');

insert into BooksAuthor(BookID , AuthorName) values (80,'hoshang.ebtehaj'),
(1,'Ch.D'),
(1,'ahmad.panahi'),
(1,'Ann.Patchet'),
(2,'hoshang.ebtehaj'),
(2,'saeed.kazemi'),
(2,'J.A'),
(2,'Hosseon.ashghari'),
(3,'Mohammad.Behjat'),
(3,'Ann.Patchet'),
(4,'D.Y'),
(5,'kazem.hoseini'),
(6,'poria.fakhimi'),
(7,'J.A'),
(8,'Mohammad.Behjat'),
(8,'E.B'),
(9,'Shekspier'),
(9,'R.L.Stine'),
(9,'Mohammad.Behjat'),
(9,'E.B'),
(10,'Hosseon.ashghari'),
(11,'D.Y'),
(12,'E.B'),
(12,'omar.jafari'),
(13,'saeed.kazemi'),
(14,'Mohammad.Behjat'),
(15,'D.Y'),
(16,'J.A'),
(17,'omar.jafari'),
(18,'kazem.hoseini'),
(19,'omar.jafari'),
(19,'E.B'),
(19,'J.A'),
(20,'Patterson'),
(21,'kazem.hoseini'),
(22,'kazem.hoseini'),
(23,'J.A'),
(24,'Ch.D'),
(25,'Hosseon.ashghari'),
(26,'R.L.Stine'),
(27,'Hosseon.ashghari'),
(27,'E.B'),
(28,'hoshang.ebtehaj'),
(29,'kazem.hoseini'),
(29,'E.B'),
(29,'Mohammad.Behjat'),
(30,'Ch.D'),
(31,'Hosseon.ashghari'),
(32,'Ch.D'),
(33,'James.Johnson'),
(34,'Shekspier'),
(34,'Ch.D'),
(34,'Mohammad.Behjat'),
(35,'omar.jafari'),
(36,'masoud.rezaee'),
(36,'saeed.kazemi'),
(36,'James.Johnson'),
(36,'poria.fakhimi'),
(37,'E.B'),
(37,'J.A'),
(38,'masoud.rezaee'),
(39,'ahmad.panahi'),
(40,'Shekspier'),
(41,'poria.fakhimi'),
(41,'R.L.Stine'),
(41,'J.A'),
(41,'Ann.Patchet'),
(42,'hoshang.ebtehaj'),
(43,'E.B'),
(43,'Mohammad.Behjat'),
(44,'ahmad.panahi'),
(44,'hoshang.ebtehaj'),
(44,'Ann.Patchet'),
(45,'E.B'),
(46,'R.L.Stine'),
(47,'omar.jafari'),
(48,'saeed.kazemi'),
(48,'kazem.hoseini'),
(48,'ahmad.panahi'),
(49,'Hosseon.ashghari'),
(50,'James.Johnson'),
(50,'J.K'),
(50,'Shekspier'),
(51,'R.L.Stine'),
(52,'Shekspier'),
(53,'E.B'),
(54,'hoshang.ebtehaj'),
(55,'Hosseon.ashghari'),
(56,'Shekspier'),
(56,'Patterson'),
(56,'Ann.Patchet'),
(57,'Patterson'),
(57,'Ch.D'),
(58,'saeed.kazemi'),
(59,'D.Y'),
(60,'J.A'),
(61,'Ann.Patchet'),
(61,'Hosseon.ashghari'),
(61,'saeed.kazemi'),
(61,'R.L.Stine'),
(62,'J.K'),
(62,'hoshang.ebtehaj'),
(63,'Hosseon.ashghari'),
(64,'saeed.kazemi'),
(65,'R.L.Stine'),
(66,'Mohammad.Behjat'),
(67,'J.A'),
(67,'Ch.D'),
(67,'masoud.rezaee'),
(67,'E.B'),
(68,'Ann.Patchet'),
(69,'saeed.kazemi'),
(69,'Mohammad.Behjat'),
(69,'masoud.rezaee'),
(70,'Ann.Patchet'),
(71,'Patterson'),
(71,'Ch.D'),
(71,'D.Y'),
(72,'Ch.D'),
(73,'R.L.Stine'),
(74,'saeed.kazemi'),
(74,'hoshang.ebtehaj'),
(75,'E.B'),
(75,'J.K'),
(75,'poria.fakhimi'),
(76,'Ann.Patchet'),
(77,'J.K'),
(77,'E.B'),
(77,'masoud.rezaee'),
(77,'Patterson'),
(78,'D.Y'),
(79,'J.K'),
(79,'Patterson'),
(79,'omar.jafari'),
(80,'J.K');

insert into Persons (PersonFirstName,PersonLastName,PersonNationalID) values ('ahmad','eslami',9207064239),
('aliasghar','eslami',4294959074),
('saeed','esmaeeli',5009033648),
('aliasghar','koshki',7828276989),
('sadegh','fatehi',9250347552),
('abbas','bagheri',8021745484),
('aboalfazl','langarabadi',4737834290),
('sadegh','esmaeeli',7320395498),
('reza','bagheri',6711852405),
('ali','koshki',6805239704),
('aboalfazl','eslami',9392273492),
('mahdi','farshchi',9953773402),
('reza','farshchi',1140121743),
('mahdi','fatehi',7668278365),
('vahid','eslami',8247595963),
('ahmad','eslami',7892140451),
('sadegh','koshki',5693093556),
('ali','rezaee',4354336663),
('aliasghar','rezaee',9746414923),
('ali','langarabadi',4244668925),
('vahid','rezaee',8714561464),
('abbas','eslami',3917706881),
('saeed','bakhshabadi',9016498617),
('qolam','eslami',7230741532),
('mohammad','bagheri',1021818609),
('aboalfazl','fatehi',4935432867),
('mohammad','farshchi',6241439786),
('reza','esmaeeli',2479955649),
('vahid','eslami',7757973581),
('mahdi','fatehi',8260147429),
('ahmad','eslami',2653330061),
('aboalfazl','bagheri',6250509346),
('ahmad','bagheri',3111999677),
('aboalfazl','koshki',9593629680),
('saeed','fatehi',3834746380),
('saeed','raad',8835363779),
('mohammad','raad',4590532972),
('vahid','bakhshabadi',6625951506),
('aliasghar','rezaee',2672910236),
('sadegh','koshki',0400706810),
('ali','raad',0956835138),
('qolam','esmaeeli',1855367112),
('aliasghar','koshki',0763261787),
('vahid','fatehi',7015975843),
('reza','bagheri',8661147598),
('sadegh','bakhshabadi',3131458557),
('qolam','koshki',9965406996),
('mahdi','esmaeeli',6836768481),
('abbas','eslami',0648457858),
('saeed','koshki',6489003957),
('abbas','fatehi',1897326912),
('ahmad','langarabadi',2137967447),
('reza','rezaee',8568797000),
('saeed','bagheri',6617373827),
('reza','farshchi',8663126829),
('saeed','koshki',5133447529),
('aliasghar','koshki',4546282424),
('sadegh','bakhshabadi',8186036790),
('saeed','esmaeeli',7132283146),
('vahid','koshki',7631099226),
('qolam','rezaee',1319192600),
('aliasghar','rezaee',6861185364),
('aliasghar','langarabadi',5088225446),
('aliasghar','esmaeeli',5020574094),
('aboalfazl','bakhshabadi',6447787030),
('mahdi','farshchi',5150875942),
('qolam','fatehi',0468547512),
('reza','fatehi',6175897385),
('aliasghar','langarabadi',9774013268),
('aboalfazl','eslami',6069676244),
('vahid','langarabadi',5874200853),
('abbas','langarabadi',5598126664),
('aboalfazl','bagheri',4826840666),
('sadegh','bagheri',3617180216),
('abbas','bakhshabadi',6942911750),
('ahmad','fatehi',7053022081),
('ali','eslami',6404157510),
('reza','koshki',9305002975),
('sadegh','farshchi',4281315838),
('mohammad','langarabadi',7615341011),
('reza','fatehi',4653903613),
('ahmad','koshki',0254221780),
('mahdi','farshchi',2046003202),
('ali','langarabadi',6079358207),
('mahdi','bagheri',6490141852),
('saeed','bagheri',2997246660),
('abbas','eslami',2530781196),
('reza','rezaee',5470128170),
('mahdi','fatehi',1454059724),
('saeed','fatehi',1680340009),
('aliasghar','raad',7284087098),
('ahmad','fatehi',3012026510),
('vahid','langarabadi',9155849151),
('ali','rezaee',4584061075),
('reza','farshchi',8973038187),
('saeed','bagheri',7796005983),
('abbas','raad',3651499335),
('mohammad','rezaee',8015004832),
('aboalfazl','raad',0751837580),
('aliasghar','langarabadi',8771989662);

insert into Regulars(PersonID , Job) values (100,'Actor'),
(4,'Actor'),
(8,'Athlete'),
(26,'teacher'),
(31,'Actor'),
(37,'police'),
(39,'Actor'),
(41,'Actor'),
(47,'police'),
(48,'police'),
(49,'teacher'),
(50,'Actor'),
(58,'teacher'),
(70,'teacher'),
(74,'taxi-driver'),
(75,'Actor'),
(78,'doctor'),
(82,'teacher'),
(86,'teacher'),
(91,'doctor');

insert Instructors(PersonID, InstructorID , UniversityName) value (11,8580945,'Elm-o-sanat'),
(12,1172598,'AmirKabir'),
(13,7628850,'tehran'),
(16,6410491,'Elm-o-sanat'),
(18,0694520,'tehran'),
(25,0088127,'Sharif'),
(30,9561269,'AmirKabir'),
(32,3488413,'tehran'),
(35,4963751,'AmirKabir'),
(36,2851642,'ferdowsi'),
(55,6394752,'Sharif'),
(59,8976454,'Sharif'),
(64,2271702,'ferdowsi'),
(66,4953721,'Elm-o-sanat'),
(72,3926562,'AmirKabir'),
(87,3921858,'ferdowsi'),
(88,8176230,'Sharif'),
(90,4910613,'tehran'),
(95,5262620,'Sharif'),
(97,9925156,'ferdowsi'),
(98,8182920,'Elm-o-sanat'),
(99,3708250,'ferdowsi');

insert Students(PersonID, StudentID , UniversityName) values (1,8911999,'Elm-o-sanat'),
(3,7507863,'tehran'),
(5,8403063,'tehran'),
(6,2729371,'ferdowsi'),
(9,3518797,'Elm-o-sanat'),
(19,8259930,'AmirKabir'),
(21,0188962,'tehran'),
(22,9933325,'AmirKabir'),
(24,5468530,'ferdowsi'),
(28,4674775,'Elm-o-sanat'),
(34,4292275,'AmirKabir'),
(38,1970546,'Sharif'),
(40,9332166,'Elm-o-sanat'),
(43,7702747,'AmirKabir'),
(45,5927795,'Elm-o-sanat'),
(57,0199017,'AmirKabir'),
(61,7524491,'Sharif'),
(68,3613073,'ferdowsi'),
(73,6817551,'AmirKabir'),
(76,7546845,'Elm-o-sanat'),
(77,9658530,'Elm-o-sanat'),
(84,4410304,'Elm-o-sanat'),
(89,1399530,'Elm-o-sanat'),
(93,5254397,'ferdowsi');

insert into Librarians(PersonID) values (7),
(14),
(20),
(23),
(33),
(44),
(51),
(52),
(53),
(63),
(65),
(67),
(83);

insert into Stores (BookID) values (80),
(80),
(80),
(80),
(80),
(80),
(80),
(80),
(80),
(1),
(1),
(1),
(1),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(3),
(3),
(3),
(3),
(3),
(3),
(3),
(4),
(4),
(4),
(4),
(4),
(4),
(4),
(5),
(5),
(5),
(5),
(5),
(5),
(6),
(6),
(6),
(6),
(6),
(7),
(7),
(7),
(7),
(7),
(8),
(8),
(8),
(8),
(8),
(8),
(9),
(10),
(10),
(10),
(11),
(11),
(11),
(11),
(11),
(11),
(11),
(11),
(11),
(11),
(12),
(12),
(12),
(12),
(12),
(13),
(13),
(14),
(14),
(14),
(14),
(14),
(14),
(14),
(15),
(15),
(15),
(15),
(16),
(16),
(16),
(16),
(16),
(16),
(17),
(18),
(18),
(18),
(18),
(18),
(18),
(18),
(18),
(18),
(19),
(19),
(19),
(19),
(19),
(19),
(19),
(19),
(19),
(19),
(20),
(20),
(20),
(20),
(20),
(21),
(21),
(21),
(21),
(21),
(21),
(21),
(21),
(22),
(22),
(22),
(22),
(22),
(22),
(22),
(22),
(23),
(23),
(23),
(23),
(23),
(23),
(23),
(24),
(24),
(24),
(25),
(25),
(25),
(25),
(26),
(26),
(26),
(26),
(26),
(26),
(27),
(28),
(28),
(28),
(29),
(29),
(29),
(29),
(29),
(29),
(29),
(30),
(30),
(30),
(30),
(31),
(31),
(31),
(31),
(31),
(31),
(31),
(31),
(31),
(31),
(32),
(32),
(32),
(32),
(32),
(32),
(32),
(33),
(33),
(33),
(33),
(33),
(33),
(34),
(34),
(35),
(35),
(35),
(35),
(35),
(35),
(35),
(36),
(36),
(36),
(36),
(36),
(36),
(37),
(37),
(37),
(37),
(37),
(37),
(37),
(37),
(37),
(37),
(38),
(38),
(38),
(38),
(38),
(38),
(38),
(39),
(39),
(39),
(39),
(39),
(39),
(39),
(39),
(39),
(39),
(40),
(40),
(40),
(41),
(41),
(41),
(41),
(41),
(41),
(42),
(42),
(42),
(42),
(42),
(42),
(42),
(42),
(42),
(42),
(43),
(43),
(44),
(44),
(44),
(44),
(44),
(44),
(44),
(44),
(44),
(44),
(45),
(45),
(45),
(45),
(45),
(46),
(46),
(46),
(46),
(46),
(46),
(47),
(47),
(47),
(47),
(47),
(47),
(47),
(48),
(48),
(48),
(48),
(48),
(48),
(48),
(48),
(49),
(49),
(50),
(51),
(51),
(52),
(52),
(53),
(53),
(53),
(53),
(53),
(53),
(53),
(54),
(54),
(54),
(54),
(55),
(55),
(55),
(55),
(55),
(55),
(55),
(55),
(56),
(56),
(57),
(57),
(57),
(57),
(58),
(58),
(58),
(58),
(58),
(58),
(59),
(59),
(59),
(59),
(59),
(60),
(60),
(60),
(60),
(60),
(60),
(60),
(60),
(60),
(60),
(61),
(61),
(61),
(61),
(61),
(61),
(61),
(61),
(62),
(62),
(62),
(62),
(62),
(63),
(63),
(63),
(63),
(63),
(63),
(64),
(64),
(64),
(64),
(64),
(64),
(64),
(65),
(65),
(65),
(65),
(66),
(66),
(66),
(67),
(67),
(67),
(67),
(67),
(67),
(67),
(67),
(67),
(67),
(68),
(68),
(68),
(68),
(68),
(69),
(69),
(69),
(69),
(69),
(69),
(69),
(69),
(69),
(70),
(70),
(70),
(70),
(70),
(70),
(70),
(70),
(70),
(71),
(71),
(72),
(72),
(72),
(72),
(72),
(72),
(73),
(73),
(74),
(74),
(74),
(74),
(75),
(75),
(75),
(75),
(75),
(75),
(75),
(76),
(76),
(76),
(76),
(77),
(77),
(78),
(78),
(78),
(78),
(78),
(78),
(78),
(79),
(79),
(79);

insert into Address( PersonID, Address) values (100,'Babolsar-Soleimani-4'),
(100,'Tehran-Shariati-8'),
(100,'Sabzevar-SattarKhan-10'),
(1,'Yazd-Shariati-6'),
(1,'Tehran-SattarKhan-7'),
(1,'Qom-Shariati-7'),
(3,'Mashhad-Beheshti-10'),
(3,'Tehran-SattarKhan-4'),
(3,'Qom-Rey-1'),
(4,'Ilam-Beheshti-10'),
(4,'Babolsar-SattarKhan-6'),
(5,'Lorestan-Shariati-7'),
(5,'Yazd-SattarKhan-3'),
(6,'Arak-Ghods-8'),
(6,'Tehran-Rey-6'),
(7,'Qom-Talghani-1'),
(7,'Lorestan-Soleimani-10'),
(7,'Babolsar-Zaheedi-10'),
(8,'Arak-Beheshti-7'),
(9,'Yazd-SattarKhan-10'),
(9,'Mashhad-Enghelab-1'),
(9,'Mashhad-Enghelab-3'),
(10,'Lorestan-Talghani-6'),
(10,'Sanandaj-SattarKhan-3'),
(11,'Babolsar-Shariati-6'),
(12,'Tehran-Talghani-9'),
(13,'Lorestan-Ghods-6'),
(13,'Kordestan-Ghods-2'),
(14,'Qom-Talghani-8'),
(15,'Sabzevar-Talghani-8'),
(15,'Babolsar-Rey-2'),
(16,'Arak-Ghods-4'),
(16,'Sanandaj-Ghods-3'),
(16,'Ilam-Soleimani-5'),
(17,'Sabzevar-Shariati-8'),
(18,'Yazd-Talghani-8'),
(18,'Babolsar-Ghods-9'),
(18,'Ilam-Ghods-8'),
(20,'Mashhad-Rey-5'),
(20,'Yazd-Beheshti-5'),
(20,'Qom-SattarKhan-7'),
(21,'Mashhad-Ghods-3'),
(21,'Tehran-Zaheedi-1'),
(22,'Yazd-Shariati-3'),
(22,'Yazd-Zaheedi-7'),
(23,'Mashhad-Talghani-5'),
(23,'Qom-Soleimani-10'),
(24,'Kordestan-Zaheedi-7'),
(24,'Ilam-Ghods-1'),
(25,'Qom-Beheshti-7'),
(27,'Tehran-Soleimani-3'),
(28,'Tehran-Ghods-9'),
(28,'Tehran-Zaheedi-4'),
(28,'Sabzevar-Ghods-7'),
(30,'Ilam-Talghani-8'),
(30,'Yazd-Ghods-6'),
(31,'Yazd-Rey-6'),
(31,'Qom-Rey-3'),
(33,'Ilam-Iran-4'),
(34,'Kordestan-Zaheedi-1'),
(34,'Sanandaj-Enghelab-7'),
(35,'Lorestan-SattarKhan-10'),
(35,'Babolsar-Soleimani-8'),
(35,'Ilam-Ghods-6'),
(36,'Sanandaj-Shariati-3'),
(36,'Qom-Talghani-2'),
(37,'Mashhad-Beheshti-1'),
(37,'Tehran-Rey-7'),
(40,'Arak-Talghani-6'),
(40,'Sabzevar-Zaheedi-8'),
(41,'Sanandaj-Iran-2'),
(41,'Arak-Talghani-1'),
(42,'Qom-Rey-5'),
(42,'Ilam-Beheshti-6'),
(43,'Tehran-Soleimani-10'),
(43,'Kordestan-SattarKhan-1'),
(43,'Qom-Rey-4'),
(44,'Sabzevar-Beheshti-5'),
(44,'Qom-Beheshti-1'),
(44,'Ilam-Beheshti-5'),
(45,'Babolsar-Enghelab-1'),
(45,'Sanandaj-Beheshti-3'),
(48,'Qom-Shariati-10'),
(49,'Sabzevar-Enghelab-1'),
(51,'Sanandaj-Talghani-4'),
(51,'Sabzevar-Talghani-10'),
(51,'Sanandaj-Ghods-6'),
(52,'Qom-Ghods-9'),
(54,'Kordestan-Rey-6'),
(54,'Mashhad-Shariati-7'),
(54,'Yazd-Zaheedi-9'),
(57,'Tehran-Talghani-6'),
(57,'Ilam-Rey-8'),
(57,'Mashhad-Beheshti-9'),
(58,'Ilam-Ghods-2'),
(58,'Yazd-Shariati-10'),
(58,'Tehran-Rey-10'),
(59,'Mashhad-Shariati-10'),
(59,'Kordestan-SattarKhan-9'),
(59,'Sanandaj-Soleimani-8'),
(60,'Qom-Talghani-10'),
(60,'Arak-Enghelab-8'),
(60,'Sanandaj-Talghani-10'),
(63,'Arak-Ghods-1'),
(64,'Kordestan-SattarKhan-5'),
(64,'Ilam-Iran-8'),
(64,'Sabzevar-Beheshti-3'),
(66,'Ilam-Iran-5'),
(66,'Babolsar-Talghani-2'),
(66,'Yazd-Zaheedi-6'),
(67,'Ilam-Rey-6'),
(67,'Qom-Shariati-2'),
(67,'Sabzevar-Beheshti-10'),
(69,'Lorestan-Soleimani-5'),
(69,'Babolsar-Zaheedi-2'),
(70,'Lorestan-Shariati-6'),
(70,'Qom-Iran-1'),
(71,'Arak-Talghani-3'),
(72,'Lorestan-Soleimani-1'),
(72,'Lorestan-Zaheedi-2'),
(72,'Arak-Talghani-8'),
(75,'Kordestan-Talghani-5'),
(76,'Sabzevar-Enghelab-4'),
(76,'Sabzevar-Shariati-10'),
(76,'Tehran-Iran-3'),
(77,'Sabzevar-Iran-6'),
(78,'Yazd-Ghods-9'),
(79,'Ilam-Beheshti-9'),
(80,'Babolsar-SattarKhan-10'),
(81,'Qom-Rey-6'),
(81,'Lorestan-Shariati-8'),
(81,'Yazd-Iran-1'),
(82,'Lorestan-SattarKhan-1'),
(82,'Ilam-Ghods-3'),
(85,'Ilam-SattarKhan-3'),
(86,'Babolsar-Iran-6'),
(86,'Sanandaj-Iran-6'),
(86,'Kordestan-Shariati-10'),
(87,'Lorestan-Iran-1'),
(87,'Tehran-Shariati-5'),
(89,'Lorestan-Ghods-2'),
(89,'Qom-Rey-9'),
(90,'Sanandaj-Beheshti-6'),
(90,'Tehran-Rey-1'),
(91,'Sanandaj-SattarKhan-7'),
(91,'Mashhad-SattarKhan-3'),
(91,'Sabzevar-Iran-3'),
(92,'Yazd-Enghelab-1'),
(92,'Babolsar-Enghelab-3'),
(95,'Sanandaj-Enghelab-6'),
(96,'Tehran-Shariati-3'),
(96,'Kordestan-Iran-8'),
(96,'Mashhad-Rey-4'),
(97,'Lorestan-Enghelab-3'),
(97,'Arak-Rey-8'),
(97,'Sabzevar-SattarKhan-4'),
(98,'Sanandaj-Shariati-8'),
(98,'Ilam-SattarKhan-5'),
(99,'Ilam-Soleimani-3'),
(99,'Qom-Shariati-5');

insert into Phones (PersonID,Phone) values (100,'+9809294127065'),
(100,'+9809842170806'),
(1,'+9809440255357'),
(1,'+9809830977978'),
(1,'+9809722779011'),
(2,'+9809464094067'),
(2,'+9809150706769'),
(3,'+9809029843341'),
(3,'+9809416003155'),
(4,'+9809502798388'),
(4,'+9809648416649'),
(5,'+9809984298345'),
(6,'+9809791825809'),
(6,'+9809986004619'),
(6,'+9809170749283'),
(8,'+9809334306200'),
(8,'+9809031554837'),
(8,'+9809024663918'),
(10,'+9809772343949'),
(10,'+9809061964864'),
(11,'+9809424526558'),
(11,'+9809344814765'),
(11,'+9809570284276'),
(12,'+9809491044663'),
(12,'+9809445293742'),
(12,'+9809225198642'),
(13,'+9809764087193'),
(13,'+9809803455055'),
(14,'+9809762938884'),
(14,'+9809227812161'),
(16,'+9809502456953'),
(16,'+9809960239335'),
(16,'+9809249092828'),
(18,'+9809313457339'),
(18,'+9809386439960'),
(19,'+9809920046204'),
(19,'+9809632274190'),
(19,'+9809956971812'),
(21,'+9809907196370'),
(21,'+9809366205287'),
(22,'+9809768457752'),
(23,'+9809261590342'),
(23,'+9809058072138'),
(26,'+9809882391668'),
(26,'+9809875704716'),
(27,'+9809488078646'),
(27,'+9809703950719'),
(27,'+9809219447318'),
(28,'+9809753221198'),
(28,'+9809708903181'),
(29,'+9809692621599'),
(30,'+9809259140698'),
(30,'+9809530504976'),
(31,'+9809943061565'),
(31,'+9809559067290'),
(32,'+9809074313883'),
(32,'+9809578445155'),
(32,'+9809113150625'),
(33,'+9809515734593'),
(33,'+9809640976561'),
(34,'+9809479796954'),
(34,'+9809998093975'),
(34,'+9809598390746'),
(35,'+9809529062082'),
(36,'+9809698286894'),
(37,'+9809631141546'),
(37,'+9809729871528'),
(37,'+9809486620632'),
(38,'+9809007860300'),
(38,'+9809254381576'),
(38,'+9809499217001'),
(40,'+9809445660854'),
(41,'+9809449607788'),
(41,'+9809116258001'),
(41,'+9809535044967'),
(42,'+9809451274439'),
(43,'+9809548044018'),
(46,'+9809842720287'),
(46,'+9809700329972'),
(46,'+9809789053700'),
(47,'+9809554586583'),
(47,'+9809596301266'),
(47,'+9809786099077'),
(49,'+9809122175521'),
(49,'+9809124200978'),
(49,'+9809503531272'),
(50,'+9809238681481'),
(50,'+9809048218251'),
(54,'+9809553484252'),
(54,'+9809908289622'),
(54,'+9809101498363'),
(56,'+9809230025053'),
(56,'+9809709462569'),
(56,'+9809380879344'),
(57,'+9809407027926'),
(57,'+9809879758487'),
(58,'+9809897821175'),
(58,'+9809575660927'),
(58,'+9809125207056'),
(59,'+9809226045509'),
(59,'+9809999995250'),
(59,'+9809043977792'),
(61,'+9809296111540'),
(61,'+9809369353133'),
(62,'+9809231800405'),
(62,'+9809414149444'),
(63,'+9809930730452'),
(63,'+9809772431218'),
(64,'+9809560530934'),
(64,'+9809311267957'),
(66,'+9809303593515'),
(66,'+9809984537759'),
(67,'+9809619374555'),
(68,'+9809788935149'),
(68,'+9809872927270'),
(69,'+9809600634072'),
(69,'+9809387768023'),
(73,'+9809764251597'),
(73,'+9809975881557'),
(73,'+9809988689246'),
(74,'+9809324337173'),
(74,'+9809441249505'),
(75,'+9809244779871'),
(75,'+9809347358496'),
(77,'+9809606590088'),
(77,'+9809386357860'),
(77,'+9809234663097'),
(78,'+9809807541531'),
(78,'+9809602416360'),
(79,'+9809574597358'),
(80,'+9809714587928'),
(80,'+9809530783842'),
(80,'+9809050035123'),
(81,'+9809600730970'),
(82,'+9809582046103'),
(82,'+9809889264345'),
(83,'+9809922721312'),
(83,'+9809374829006'),
(83,'+9809405519656'),
(85,'+9809706083984'),
(85,'+9809065711875'),
(85,'+9809076307562'),
(87,'+9809303511608'),
(87,'+9809310734834'),
(88,'+9809180089246'),
(88,'+9809939364589'),
(89,'+9809203705795'),
(89,'+9809750022363'),
(89,'+9809752077481'),
(90,'+9809372099006'),
(90,'+9809502715224'),
(91,'+9809827305341'),
(91,'+9809281793377'),
(91,'+9809683746158'),
(92,'+9809798838008'),
(93,'+9809115759830'),
(95,'+9809268629905'),
(97,'+9809960315790'),
(97,'+9809642389360'),
(97,'+9809993110463'),
(98,'+9809871342072'),
(98,'+9809449069002'),
(98,'+9809594024564'),
(99,'+9809128473504');

insert into Managers(PersonID) values (2),
(10),
(15),
(17),
(27),
(29),
(42),
(46),
(54),
(56),
(60),
(62),
(69),
(71),
(79),
(80),
(81),
(85),
(92),
(94),
(96);
insert into Accounts(PersonID , AccountUserName , AccountPassword , created_date ,AccountBalance) value (100,'N123456789CNQDOFMT07',sha1('P123456789NVDZKK3IG'),"1399-12-22",9165),
(1,'Q1234567891N2VQDWE2C',sha1('E123456789W11PJKLATOP'),"1399-9-24",191),
(2,'Q123456789CT9XQXQBWAK',sha1('R123456789INQEX8OE3IAB'),"1397-7-29",1849),
(3,'M123456789FL8L8O',sha1('X12345678980ROQID5NO8M'),"1397-10-14",2286),
(4,'U1234567891SA4803',sha1('X123456789NIM7ROKKBD'),"1395-4-6",9104),
(5,'G123456789T4N3HO',sha1('Z1234567894TN47TLXN'),"1394-9-29",1198),
(6,'S1234567897M7IMZUAGPC',sha1('X123456789JWUAS8TUW'),"1394-7-20",7091),
(7,'E123456789IJCI4H9',sha1('Q123456789W020PO3CR'),"1397-12-10",336),
(8,'O123456789RN2WSKG6ZO',sha1('M123456789F7VMAKEEA'),"1396-9-15",7567),
(9,'C123456789VOPNTWNI',sha1('C123456789DFWL8M42RED'),"1397-5-3",9276),
(10,'V123456789GKZ607MVJB',sha1('L123456789D0Q67GPZ7TO3J'),"1395-5-1",8418),
(11,'Z123456789KH5G6LIUYC',sha1('N1234567895E00UI9V881K'),"1397-8-25",5268),
(12,'Q123456789QSTJZONH3N2',sha1('H1234567894G2H8LE40A6RX'),"1399-2-16",3125),
(13,'W1234567891GQQDL38',sha1('P123456789ICF8SM7A0GXU'),"1395-11-26",5208),
(14,'Y12345678965A4J2RRV1',sha1('U123456789FMJHKBH73K1PL'),"1396-3-22",7492),
(15,'G123456789FFWWZX0OZO',sha1('O123456789UZGCMROHB'),"1396-11-7",2428),
(16,'F123456789D9KA2GV2FU2',sha1('O123456789FWYNX007SDCH'),"1398-9-9",4771),
(17,'A123456789PBIPF7T',sha1('Y123456789I7FKGAMJ74'),"1396-2-19",4004),
(18,'D1234567894HNJRD',sha1('E1234567899J2Q4R1HST3K'),"1395-2-14",3406),
(19,'T1234567890NU5WO954',sha1('S123456789RJYL7O75IM5NNJ'),"1399-12-22",3214),
(20,'X123456789SND98LAT3N',sha1('L123456789I03GR28ZEN'),"1398-10-13",2273),
(21,'O123456789KE58FICMCHB',sha1('Q123456789GE7EVVGJW'),"1399-5-14",1354),
(22,'C123456789TS2X3V6CDT',sha1('Z123456789PU2PI0I2M7C'),"1396-10-8",6658),
(23,'S123456789HFE74A6T',sha1('R1234567893D52JL8H41GSY'),"1398-11-6",4951),
(24,'R123456789QDH9H5WR',sha1('O123456789MEJ63GCAHMB5'),"1398-3-10",5856),
(25,'V123456789DGPHVB',sha1('U1234567898GMMTN0KI67O5'),"1399-7-17",5985),
(26,'G123456789XS9UKMRSMR',sha1('J123456789ESXLEFS78'),"1397-2-8",2987),
(27,'G123456789XNHI5A',sha1('E123456789JSXJA1T95MMXZ'),"1397-4-11",6772),
(28,'G1234567892RWC61FRVC',sha1('T1234567898P5X0XB21TKD'),"1399-11-9",1037),
(29,'N123456789NPTEFE7AO8',sha1('J123456789O1LH8A0NFCZB'),"1395-7-6",3306),
(30,'T123456789BSGHHF8',sha1('O123456789YJUXF2XTAA1A'),"1395-5-12",5710),
(31,'Y12345678917KZI7',sha1('P123456789QK4IKNFY2L37'),"1397-10-8",6637),
(32,'S123456789ES7J7XUD',sha1('B1234567894GPU590JZQ6U'),"1398-4-14",4179),
(33,'S123456789647CSFY43',sha1('Y123456789Z1JLJLAWXH7'),"1396-2-16",4301),
(34,'Y123456789HQ8PXE96',sha1('R123456789O9Q84O8Y1IUC'),"1396-2-22",9740),
(35,'T123456789M3XSQRHO',sha1('P123456789PSEPTSUUT162KE'),"1396-5-27",875),
(36,'J123456789CVE5Y3',sha1('G123456789108DBE98LJDN'),"1395-3-2",6351),
(37,'I123456789M6VTJVG5',sha1('L123456789FO14WKH3P42WBW'),"1394-10-8",1326),
(38,'E123456789DO8J2I2F',sha1('Z123456789KEZL2OWG5AWH7'),"1398-12-22",8879),
(39,'A123456789K1RHMG2XB',sha1('J123456789CE4N01T39BO44N'),"1394-4-1",4105),
(40,'S123456789E2MD6WXDZ',sha1('P1234567897T9APKGCN7GL'),"1397-4-23",4986),
(41,'F123456789PHTJNGUER',sha1('S123456789JV96DAA2V'),"1399-4-13",1888),
(42,'G1234567891GTDB2VAM',sha1('J123456789TK9LS0Y21J4Z3Q'),"1398-8-17",5764),
(43,'M123456789TYALIOPY9U',sha1('H123456789CTTY2YH635'),"1399-2-28",6508),
(44,'R1234567892KJI8AQDW1',sha1('J123456789050XPZZG3ZWW'),"1396-11-10",8955),
(45,'S123456789DYVS25Z3M6P',sha1('Z123456789P62UKIYTOSRQ'),"1398-3-15",5325),
(46,'E12345678974JJGSW',sha1('O123456789JSCQR2K1FSE'),"1396-11-10",4201),
(47,'Z123456789JPX4GQ8JI3X',sha1('H1234567892JUHDJLDPW'),"1394-7-14",7006),
(48,'Z123456789I3Z30OUBJ0',sha1('O123456789GXJW5282IC'),"1398-7-11",8265),
(49,'I123456789V6W06W',sha1('F1234567891XBGNPZLC'),"1396-6-16",8176),
(50,'H123456789U4PO0Q',sha1('R1234567892DH59CM1SF4LUN'),"1396-10-24",9158),
(51,'Y123456789C53AYTM',sha1('S123456789ML3N6SJ1AS1'),"1397-6-17",6257),
(52,'Z1234567899KQG1T9O',sha1('X12345678930VVSG4GWPT'),"1395-3-21",9329),
(53,'S1234567897WU5IM',sha1('P123456789N6ZD98GIE78D'),"1396-1-2",4219),
(54,'F1234567892QVEMI32A',sha1('O1234567891XIKXBJXU'),"1397-12-14",2166),
(55,'V123456789W8FL59',sha1('Q12345678906WD1IWLLT5'),"1395-7-19",4269),
(56,'I123456789J1XI05',sha1('Y123456789K8XI4JX5ZO'),"1394-10-1",359),
(57,'E123456789BH9KWU',sha1('C123456789E8IG6X9FLH0CI'),"1396-2-1",7202),
(58,'E1234567895JJ9RIBY1',sha1('V123456789V3RYMTK2D76T'),"1399-10-20",6096),
(59,'Y1234567892E2VQC77',sha1('S123456789S0QU8FMQ5Y8EWD'),"1396-8-9",6640),
(60,'K123456789YITG47F7',sha1('N123456789ZC3APXGBZY'),"1396-3-9",9291),
(61,'G123456789KL9N4F',sha1('Q123456789D87NIIHCTU'),"1399-11-25",2318),
(62,'P123456789VBRK3MA',sha1('K123456789H6MDH6QSX1IPK'),"1399-10-12",3976),
(63,'B123456789O9E2I8',sha1('E12345678977GU83X7WRE5'),"1397-5-5",8732),
(64,'B123456789HQ3ERX',sha1('Y1234567893IQX1Y4YNTK'),"1399-8-30",8066),
(65,'S123456789CV1K9R427P',sha1('C123456789ZVFAIF7GKYV7O'),"1398-10-24",6048),
(66,'G1234567897XRJYLBG',sha1('C123456789WU45UXI6QV0O'),"1396-11-4",7103),
(67,'K123456789DWHD2SQ3YDV',sha1('D123456789R5F57VHFVK'),"1397-5-2",4518),
(68,'L123456789HI6MHT',sha1('D123456789EK6BXJM3CDO'),"1394-5-29",405),
(69,'A1234567897IKXU1ZH60',sha1('D123456789HXMN0EJ9E1'),"1395-12-5",3218),
(70,'E123456789L6EGB82QW',sha1('U123456789G5H65ZYZ6U'),"1396-3-3",2679),
(71,'C1234567890UWIRRXT4LE',sha1('N123456789G2HGNG9IIJ6'),"1398-3-17",3223),
(72,'P1234567894GE0Q8AHO',sha1('R123456789VEPCIQH1OZTHGP'),"1399-4-28",6137),
(73,'Z1234567896RX8X8S',sha1('F1234567899OBCYYAWP9'),"1396-2-4",6235),
(74,'Y12345678917RXH6U4N',sha1('Q123456789NX18N0VU46'),"1398-3-10",8448),
(75,'M123456789MEYQ2D',sha1('J123456789ZG1H1FQU83C'),"1395-4-15",2470),
(76,'G123456789273TN5N6XN',sha1('D123456789ZU2VU7YHKQQELE'),"1399-8-21",342),
(77,'H1234567896SPQ0D',sha1('E123456789PPR9L3RVXTW5'),"1396-1-13",4841),
(78,'Q123456789438XSM',sha1('B12345678907TN7PWJPN'),"1398-5-16",9496),
(79,'P123456789LR6YAOP78',sha1('B123456789IPMEXPFAIET'),"1397-1-20",4821),
(80,'M1234567891QF8XR5',sha1('G1234567890Y0UW8ZDPTQ82'),"1399-6-8",5346),
(81,'O12345678979KH1TM6D9R',sha1('E123456789A23JZE68U7'),"1396-3-1",7548),
(82,'X123456789WF4FIW',sha1('C123456789LOSQSDOMDK'),"1399-7-12",8848),
(83,'Z1234567895DTX0JK',sha1('O123456789VIEAOJI9S'),"1395-5-20",3139),
(84,'W1234567895X07MHOVNC',sha1('F1234567899L6YNRQY5ASNT5'),"1399-9-1",998),
(85,'L123456789QN78QTQ00',sha1('V123456789SMVA336Z5AXD7'),"1399-12-26",3380),
(86,'O123456789KG53J5XH',sha1('Q12345678941836JCRTO'),"1396-1-9",1901),
(87,'H12345678928515I3RFK',sha1('D12345678935R6YA6GKSSC'),"1399-4-26",7113),
(88,'L12345678914U5SNZVU',sha1('G123456789GNEKK6FBDOXRR'),"1397-12-3",1679),
(89,'C1234567898YL9MCIL',sha1('J123456789WJAIAPKPOSP'),"1396-11-6",2142),
(90,'F123456789KUXP9SJI69',sha1('N123456789WILHVVF8C0'),"1394-6-22",9586),
(91,'W123456789WQKZ8T17',sha1('R123456789X91DCFV4XRIJXV'),"1395-6-19",3495),
(92,'G1234567894MUGR1IIC0H',sha1('A1234567899XYIU564R483CN'),"1398-1-13",551),
(93,'P1234567894UAJ59',sha1('W123456789WO5GXNC69EK'),"1397-7-22",6187),
(94,'U123456789D7H6MR4QQX3',sha1('O123456789Z99R0F0CH2FT'),"1397-8-25",6333),
(95,'K123456789Q93E0MM1J',sha1('D123456789TU5UL7Q1M'),"1399-2-9",8603),
(96,'N123456789PJCO8EY',sha1('F1234567890L3YMZQPFJK'),"1397-5-24",9703),
(97,'Z123456789D15FVPQ', sha1('V123456789GDGZMDTUR'),"1398-9-1",8750),
(98,'X123456789WQ50CN',sha1('V123456789GDGZMDTUR'),"1396-7-24",1551),
(99,'E123456789HOAB3KF',sha1('L123456789KMTOBFF4PFSWU'),"1397-12-20",915);


insert into histories (PersonID ,BookCode,start_date,return_date ,duration,cost,valid) values (15,11,Date('2021-02-03'),0,23,239,1);
insert into histories (PersonID ,BookCode,start_date,return_date ,duration,cost,valid) values (15,12,Date('2021-01-10'),0,23,239,1);
insert into histories (PersonID ,BookCode,start_date,return_date ,duration,cost,valid) values (15,13,Date('2021-02-05'),0,23,239,1);
insert into histories (PersonID ,BookCode,start_date,return_date ,duration,cost,valid) values (15,14,Date('2021-02-09'),0,23,239,1);
insert into histories (PersonID ,BookCode, message , start_date,return_date ,duration,cost,valid) values (27,14, 'I Love You Saeed' , Date('2021-02-09'),0,23,239,1);

-- the qurey 

call seeInfo(40);

select login('Q1234567891N2VQDWE2C' , 'E123456789W11PJKLATOP');
select logout();
select * from accounts ;
select * from logins;
select signup('mgh2711Q' , 'm2711gH9985' , 'MohammadReza'  ,  'Qaderi' , '0480959838' , 'Student' , 'AUT' ,  '9627057');
SET SQL_SAFE_UPDATES=0;
select increaseBalance(55 , 101);
select * from Persons join accounts  where  Persons.PersonID = 101 and persons.PersonID = accounts.PersonID;
select increaseBalance(-5 , 101);
select getBack(15);
call searchBook('None' , 'None' , 4 , 1381 );
call bookDelay(101);
select deleteAccount(100) ;
select * from accounts where accounts.PersonID = 16 ;
select price from books join stores where books.BookID = stores.BookID and stores.BookCode = 98;
select borrowBook(15 , 5); 
select borrowBook(16 , 98); 
call BookDelay(15) ;
select * from accounts where accounts.PersonID = 16;

call BookHistory(15);
select * from mails where mails.PersonID = 27 ;
