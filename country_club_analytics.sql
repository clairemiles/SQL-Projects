/*The data used for this project is from the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table. */

/*Important Note: Answers below have been checked against Springboard's provided solutions and therefore may be influenced by them. Answers were only checked after an initial attempt without assistance.*/

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
FROM Facilities
WHERE membercost <> 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( * ) 
FROM Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < ( monthlymaintenance * .20 ) 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid
IN ( 1, 5 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance > 100
THEN  'expensive'
ELSE  'cheap'
END AS cheap_or_expensive
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
FROM Members
WHERE joindate = ( 
SELECT MAX( joindate ) AS most_recent
FROM Members )

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT tennis.name AS facility, CONCAT(book.first, " ", book.surname) AS member
FROM (

(SELECT DISTINCT(M.firstname) AS first, M.surname, B.facid
FROM Bookings B
INNER JOIN Members M
ON M.memid = B.memid
) book
 
INNER JOIN

(SELECT facid, name
FROM Facilities
WHERE name LIKE 'Tennis Court%') tennis

ON tennis.facid = book.facid
)
GROUP BY member

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT F.name AS facility,
CASE WHEN B.memid = 0 THEN M.firstname 
	ELSE M.firstname|| " " || M.surname END AS member,
CASE WHEN B.memid = 0 THEN B.slots * F.guestcost
	ELSE SUM(B.slots * F.membercost) END AS cost

FROM Bookings B
JOIN Facilities F ON B.facid=F.facid
JOIN Members M ON B.memid=M.memid
WHERE LEFT(B.starttime, 10) = '2012-09-14'

GROUP BY 1,2
HAVING cost > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub.name AS facility,
	   CASE WHEN sub.memid = 0 THEN M.firstname 
			ELSE M.firstname|| " " || M.surname END AS member, 
	   CASE WHEN sub.memid = 0 THEN sub.slots * sub.cost
			ELSE SUM(sub.slots * sub.cost) END AS cost
FROM Members M
JOIN
(SELECT B.memid AS memid,
 F.name AS name,
 B.slots AS slots,
 F.guestcost AS cost
FROM Bookings B
JOIN Facilities F ON F.facid = B.facid
WHERE LEFT(B.starttime, 10) = '2012-09-14'
AND B.memid = 0) sub ON M.memid = sub.memid

GROUP BY facility, member 
HAVING cost > 30
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT sub.facility, sub.revenue

FROM(
    SELECT F.name AS facility,
	CASE WHEN B.memid = 0 THEN SUM(B.slots*F.guestcost) 
    	ELSE SUM(B.slots*F.membercost) END AS revenue,
	F.facid
	FROM Bookings B
	JOIN Facilities F ON B.facid = F.facid
	WHERE B.memid = 0
	GROUP BY facility) sub

WHERE revenue < 1000
ORDER BY revenue DESC