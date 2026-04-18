-- ============================================================
--  Smart Campus DB — Full Schema v2.0
--  Database: PostgreSQL
--  Run with: psql -U postgres -f init_db.sql
-- ============================================================

CREATE DATABASE smart_campus_db;
\c smart_campus_db;

-- ─────────────────────────────────────────
--  STUDENTS
-- ─────────────────────────────────────────
CREATE TABLE students (
    id          SERIAL PRIMARY KEY,
    student_id  VARCHAR(50)  UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,
    department  VARCHAR(100),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
--  CHAT SESSIONS
-- ─────────────────────────────────────────
CREATE TABLE chat_sessions (
    id          SERIAL PRIMARY KEY,
    student_id  VARCHAR(50) REFERENCES students(student_id) ON DELETE CASCADE,
    message     TEXT NOT NULL,
    response    TEXT NOT NULL,
    timestamp   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
--  BUS ROUTES
-- ─────────────────────────────────────────
CREATE TABLE bus_routes (
    id              SERIAL PRIMARY KEY,
    route_name      VARCHAR(100) NOT NULL,
    working_days    TEXT DEFAULT 'Sun,Mon,Tue,Wed,Thu'
);

-- ─────────────────────────────────────────
--  BUS STOPS  (ordered stops per route)
-- ─────────────────────────────────────────
CREATE TABLE bus_stops (
    id          SERIAL PRIMARY KEY,
    route_id    INTEGER REFERENCES bus_routes(id) ON DELETE CASCADE,
    stop_name   VARCHAR(100) NOT NULL,
    stop_order  INTEGER DEFAULT 0,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION
);

-- ─────────────────────────────────────────
--  BUS SCHEDULES  (departure / return per route)
-- ─────────────────────────────────────────
CREATE TABLE bus_schedules (
    id              SERIAL PRIMARY KEY,
    route_id        INTEGER REFERENCES bus_routes(id) ON DELETE CASCADE,
    departure_time  VARCHAR(10) NOT NULL,
    return_time     VARCHAR(10) NOT NULL
);

-- ─────────────────────────────────────────
--  BUSES  (physical vehicles)
-- ─────────────────────────────────────────
CREATE TABLE buses (
    id              SERIAL PRIMARY KEY,
    bus_number      VARCHAR(20) UNIQUE NOT NULL,
    plate_number    VARCHAR(20),
    capacity        INTEGER DEFAULT 40,
    route_id        INTEGER REFERENCES bus_routes(id),
    status          VARCHAR(20) DEFAULT 'idle',   -- idle | on_route | maintenance
    driver_name     VARCHAR(100),
    current_lat     DOUBLE PRECISION,
    current_lng     DOUBLE PRECISION,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
--  LIBRARY CATEGORIES
-- ─────────────────────────────────────────
CREATE TABLE library_categories (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) UNIQUE NOT NULL,
    icon    VARCHAR(50) DEFAULT 'book'
);

-- ─────────────────────────────────────────
--  LIBRARY BOOKS
-- ─────────────────────────────────────────
CREATE TABLE library_books (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    author      VARCHAR(100),
    category_id INTEGER REFERENCES library_categories(id),
    price       DECIMAL(8,2) DEFAULT 0.00,
    available   BOOLEAN DEFAULT TRUE,
    featured    BOOLEAN DEFAULT FALSE,
    cover_color VARCHAR(20) DEFAULT '#9E1B22',
    description TEXT,
    isbn        VARCHAR(50),
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
--  BORROWED BOOKS
-- ─────────────────────────────────────────
CREATE TABLE borrowed_books (
    id          SERIAL PRIMARY KEY,
    student_id  VARCHAR(50) REFERENCES students(student_id) ON DELETE CASCADE,
    book_id     INTEGER REFERENCES library_books(id) ON DELETE CASCADE,
    borrow_date DATE DEFAULT CURRENT_DATE,
    due_date    DATE DEFAULT CURRENT_DATE + INTERVAL '14 days',
    return_date DATE
);

-- ─────────────────────────────────────────
--  UNIVERSITY RULES
-- ─────────────────────────────────────────
CREATE TABLE rule_categories (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) UNIQUE NOT NULL,
    icon    VARCHAR(50) DEFAULT 'gavel'
);

CREATE TABLE university_rules (
    id              SERIAL PRIMARY KEY,
    category_id     INTEGER REFERENCES rule_categories(id),
    rule_number     INTEGER,
    rule_title      VARCHAR(200),
    rule_text       TEXT NOT NULL,
    severity        VARCHAR(20) DEFAULT 'info'  -- info | warning | critical
);

-- ─────────────────────────────────────────
--  NOTIFICATIONS
-- ─────────────────────────────────────────
CREATE TABLE notifications (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    message     TEXT NOT NULL,
    type        VARCHAR(20) DEFAULT 'info',   -- info | warning | alert
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
--  SEED DATA
-- ============================================================

-- Test student (password will be updated via API — use /auth/register)
INSERT INTO students (student_id, name, email, password, department) VALUES
('STU001', 'Ahmed Al-Rashid',  'ahmed@meu.edu.jo',  'PLACEHOLDER', 'Computer Science'),
('STU002', 'Sara Al-Khalidi',  'sara@meu.edu.jo',   'PLACEHOLDER', 'Business Administration'),
('STU003', 'Omar Barakat',     'omar@meu.edu.jo',   'PLACEHOLDER', 'Engineering');

-- Bus routes
INSERT INTO bus_routes (route_name) VALUES
('Amman – Main Campus'),
('Zarqa – Main Campus'),
('Madaba – Main Campus');

-- Bus stops (with approximate GPS coords near Amman)
INSERT INTO bus_stops (route_id, stop_name, stop_order, latitude, longitude) VALUES
(1, 'Sports City',               1, 31.9854, 35.8516),
(1, 'University of Jordan Area', 2, 31.9922, 35.8667),
(1, 'MEU Main Gate',             3, 31.9539, 35.9300),
(2, 'Zarqa Downtown',            1, 32.0728, 36.0880),
(2, 'Hashmiya Circle',           2, 32.0300, 36.0100),
(2, 'MEU Main Gate',             3, 31.9539, 35.9300),
(3, 'Madaba Center',             1, 31.7167, 35.8000),
(3, 'Airport Road Junction',     2, 31.8200, 35.9000),
(3, 'MEU Main Gate',             3, 31.9539, 35.9300);

-- Bus schedules
INSERT INTO bus_schedules (route_id, departure_time, return_time) VALUES
(1, '07:00', '14:30'),
(1, '08:00', '16:00'),
(2, '07:15', '15:00'),
(3, '07:30', '15:30');

-- Buses (physical vehicles with GPS)
INSERT INTO buses (bus_number, plate_number, capacity, route_id, status, driver_name, current_lat, current_lng) VALUES
('BUS-01', '12-345-JO', 45, 1, 'on_route',   'Khalid Mansour',  31.9854, 35.8516),
('BUS-02', '67-890-JO', 40, 1, 'idle',        'Rami Saleh',      31.9539, 35.9300),
('BUS-03', '11-222-JO', 40, 2, 'on_route',   'Tariq Hassan',    32.0728, 36.0880),
('BUS-04', '33-444-JO', 35, 3, 'maintenance', 'Ali Nasser',      31.7167, 35.8000);

-- Library categories
INSERT INTO library_categories (name, icon) VALUES
('Computer Science', 'computer'),
('Engineering',      'build'),
('Business',         'business'),
('Medicine',         'local_hospital'),
('Literature',       'auto_stories'),
('Mathematics',      'functions');

-- Library books
INSERT INTO library_books (title, author, category_id, price, available, featured, cover_color, description) VALUES
('Introduction to Algorithms',              'Thomas H. Cormen',     1, 45.00, TRUE,  TRUE,  '#1565C0', 'The standard reference for algorithm design and analysis.'),
('Clean Code',                              'Robert C. Martin',     1, 38.00, TRUE,  TRUE,  '#2E7D32', 'A handbook of agile software craftsmanship.'),
('Database System Concepts',                'Abraham Silberschatz', 1, 52.00, FALSE, FALSE, '#6A1B9A', 'Comprehensive coverage of database systems.'),
('Artificial Intelligence: Modern Approach','Stuart Russell',       1, 60.00, TRUE,  TRUE,  '#E65100', 'The definitive AI textbook used worldwide.'),
('Computer Networks',                       'Andrew Tanenbaum',     1, 48.00, TRUE,  FALSE, '#00695C', 'Comprehensive guide to computer networking.'),
('Engineering Mathematics',                 'K.A. Stroud',          2, 35.00, TRUE,  FALSE, '#4527A0', 'Essential mathematics for engineers.'),
('Fundamentals of Electric Circuits',       'Charles Alexander',    2, 55.00, TRUE,  TRUE,  '#AD1457', 'Core electrical engineering principles.'),
('Principles of Management',                'Peter Drucker',        3, 30.00, TRUE,  FALSE, '#37474F', 'Classic management theory and practice.'),
('Financial Accounting',                    'Weygandt & Kimmel',    3, 42.00, FALSE, FALSE, '#BF360C', 'Core concepts in financial accounting.'),
('Calculus: Early Transcendentals',         'James Stewart',        6, 50.00, TRUE,  TRUE,  '#1B5E20', 'The world''s most popular calculus textbook.');

-- University rule categories
INSERT INTO rule_categories (name, icon) VALUES
('Academic Integrity',  'school'),
('Attendance',          'event_available'),
('Campus Conduct',      'people'),
('Registration',        'assignment'),
('Library & Labs',      'local_library');

-- University rules
INSERT INTO university_rules (category_id, rule_number, rule_title, rule_text, severity) VALUES
(1, 1, 'Academic Honesty',      'Plagiarism, cheating, or any form of academic dishonesty will result in course failure and possible suspension.', 'critical'),
(1, 2, 'Exam Conduct',          'Students must present their university ID before entering any exam. Mobile phones must be off during exams.', 'critical'),
(1, 3, 'Assignment Submission', 'Late assignments incur a 10% deduction per day unless prior approval from the instructor is obtained.', 'warning'),
(2, 4, 'Minimum Attendance',    'Students must attend at least 75% of all lectures. Falling below this threshold results in automatic course failure.', 'critical'),
(2, 5, 'Absence Notification',  'Students must notify their department of absences in advance when possible. Medical absences require official documentation.', 'warning'),
(3, 6, 'Campus ID',             'University ID must be carried and presented on request at all times while on campus.', 'info'),
(3, 7, 'Dress Code',            'Students must dress modestly and appropriately in accordance with university standards.', 'info'),
(3, 8, 'Noise & Respect',       'Respect for faculty, staff, and fellow students is mandatory. Disruptive behavior will not be tolerated.', 'warning'),
(4, 9, 'Registration Deadline', 'Course registration must be completed within the official dates. Late registration incurs a 25 JOD penalty fee.', 'warning'),
(4,10, 'Drop & Add',            'Students may add or drop courses within the first two weeks of the semester without academic penalty.', 'info'),
(5,11, 'Library Returns',       'Borrowed books must be returned within 14 days. Overdue books incur a 0.50 JOD fine per day.', 'warning'),
(5,12, 'Lab Equipment',         'Lab equipment must be handled with care. Damage due to negligence is the financial responsibility of the student.', 'warning');

-- Notifications
INSERT INTO notifications (title, message, type) VALUES
('Welcome to Spring Semester 2025', 'Spring semester has officially started. Check your schedule on the student portal.', 'info'),
('Library Extended Hours',           'The library will be open on Fridays from 9 AM to 2 PM during the exam season.', 'info'),
('Bus Schedule Update',              'Route 2 (Zarqa) departure time has changed to 07:30 starting next week.', 'alert'),
('Registration Deadline Reminder',   'Course registration closes on February 15th. Late fees apply after this date.', 'warning');