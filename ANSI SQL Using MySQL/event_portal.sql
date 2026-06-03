-- DATABASE
CREATE DATABASE IF NOT EXISTS event_portal;
USE event_portal;

-- =====================
-- TABLES
-- =====================

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    city VARCHAR(100) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status ENUM('upcoming','completed','cancelled'),
    organizer_id INT,
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id)
);

CREATE TABLE Sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    title VARCHAR(200) NOT NULL,
    speaker_name VARCHAR(100) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_id INT,
    registration_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    feedback_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

CREATE TABLE Resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    resource_type ENUM('pdf','image','link'),
    resource_url VARCHAR(255) NOT NULL,
    uploaded_at DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- =====================
-- QUERIES
-- =====================

-- 1
SELECT e.*
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
JOIN Users u ON r.user_id = u.user_id
WHERE e.status='upcoming' AND e.city = u.city
ORDER BY e.start_date;

-- 2
SELECT event_id, AVG(rating) avg_rating
FROM Feedback
GROUP BY event_id
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC;

-- 3
SELECT *
FROM Users
WHERE user_id NOT IN (
    SELECT user_id FROM Registrations
    WHERE registration_date >= CURDATE() - INTERVAL 90 DAY
);

-- 4
SELECT event_id, COUNT(*) session_count
FROM Sessions
WHERE TIME(start_time) BETWEEN '10:00:00' AND '12:00:00'
GROUP BY event_id;

-- 5
SELECT u.city, COUNT(DISTINCT r.user_id) total_users
FROM Registrations r
JOIN Users u ON r.user_id = u.user_id
GROUP BY u.city
ORDER BY total_users DESC
LIMIT 5;

-- 6
SELECT event_id,
SUM(resource_type='pdf') pdf_count,
SUM(resource_type='image') image_count,
SUM(resource_type='link') link_count
FROM Resources
GROUP BY event_id;

-- 7
SELECT u.full_name, e.title, f.rating, f.comments
FROM Feedback f
JOIN Users u ON f.user_id = u.user_id
JOIN Events e ON f.event_id = e.event_id
WHERE rating < 3;

-- 8
SELECT e.event_id, e.title, COUNT(s.session_id) total_sessions
FROM Events e
LEFT JOIN Sessions s ON e.event_id = s.event_id
WHERE e.status='upcoming'
GROUP BY e.event_id;

-- 9
SELECT organizer_id, status, COUNT(*) total_events
FROM Events
GROUP BY organizer_id, status;

-- 10
SELECT e.*
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
LEFT JOIN Feedback f ON e.event_id = f.event_id
WHERE f.event_id IS NULL;

-- 11
SELECT registration_date, COUNT(*) users_count
FROM Users
WHERE registration_date >= CURDATE() - INTERVAL 7 DAY
GROUP BY registration_date;

-- 12
SELECT event_id
FROM Sessions
GROUP BY event_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 13
SELECT e.city, AVG(f.rating) avg_rating
FROM Feedback f
JOIN Events e ON f.event_id = e.event_id
GROUP BY e.city;

-- 14
SELECT event_id, COUNT(*) total_reg
FROM Registrations
GROUP BY event_id
ORDER BY total_reg DESC
LIMIT 3;

-- 15
SELECT s1.event_id, s1.session_id, s2.session_id
FROM Sessions s1
JOIN Sessions s2
ON s1.event_id = s2.event_id
AND s1.session_id < s2.session_id
AND s1.start_time < s2.end_time
AND s2.start_time < s1.end_time;

-- 16
SELECT *
FROM Users
WHERE registration_date >= CURDATE() - INTERVAL 30 DAY
AND user_id NOT IN (SELECT user_id FROM Registrations);

-- 17
SELECT speaker_name, COUNT(*) total_sessions
FROM Sessions
GROUP BY speaker_name
HAVING COUNT(*) > 1;

-- 18
SELECT e.*
FROM Events e
LEFT JOIN Resources r ON e.event_id = r.event_id
WHERE r.event_id IS NULL;

-- 19
SELECT e.event_id,
COUNT(DISTINCT r.registration_id) total_reg,
AVG(f.rating) avg_rating
FROM Events e
LEFT JOIN Registrations r ON e.event_id = r.event_id
LEFT JOIN Feedback f ON e.event_id = f.event_id
WHERE e.status='completed'
GROUP BY e.event_id;

-- 20
SELECT u.user_id,
COUNT(DISTINCT r.event_id) attended,
COUNT(DISTINCT f.feedback_id) feedbacks
FROM Users u
LEFT JOIN Registrations r ON u.user_id = r.user_id
LEFT JOIN Feedback f ON u.user_id = f.user_id
GROUP BY u.user_id;

-- 21
SELECT user_id, COUNT(*) total_feedback
FROM Feedback
GROUP BY user_id
ORDER BY total_feedback DESC
LIMIT 5;

-- 22
SELECT user_id, event_id, COUNT(*) cnt
FROM Registrations
GROUP BY user_id, event_id
HAVING cnt > 1;

-- 23
SELECT DATE_FORMAT(registration_date,'%Y-%m') month,
COUNT(*) total
FROM Registrations
WHERE registration_date >= CURDATE() - INTERVAL 12 MONTH
GROUP BY month;

-- 24
SELECT event_id,
AVG(TIMESTAMPDIFF(MINUTE,start_time,end_time)) avg_duration
FROM Sessions
GROUP BY event_id;

-- 25
SELECT e.*
FROM Events e
LEFT JOIN Sessions s ON e.event_id = s.event_id
WHERE s.event_id IS NULL;
