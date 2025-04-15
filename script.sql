-- SQLite Script to Handle Features (Without AI Tables)
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS PomodoroSessions;
DROP TABLE IF EXISTS Streaks;
DROP TABLE IF EXISTS Achievements;
DROP TABLE IF EXISTS CommunityPosts;
DROP TABLE IF EXISTS CommunityComments;

-- Table for User Profiles
CREATE TABLE IF NOT EXISTS Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL, -- Added password field
    -- Add other profile information as needed
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table for Tasks
CREATE TABLE IF NOT EXISTS Tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    subject TEXT, -- Changed from description to subject
    description TEXT, -- Added a new column 'description' to store additional details about tasks
    due_date DATETIME,
    priority INTEGER DEFAULT 3, -- e.g., 1: High, 2: Medium, 3: Low
    status TEXT DEFAULT 'To Do', -- e.g., 'To Do', 'In Progress', 'Done', 'Cancelled'
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Table for Pomodoro Sessions (Chế độ Pomodoro)
CREATE TABLE IF NOT EXISTS PomodoroSessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    user_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration_seconds INTEGER NOT NULL,
    type TEXT DEFAULT 'Work', -- e.g., 'Work', 'Short Break', 'Long Break'
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Table for Streaks
CREATE TABLE IF NOT EXISTS Streaks (
    streak_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    streak_type TEXT NOT NULL UNIQUE, -- e.g., 'daily_task_completion', 'pomodoro_sessions'
    start_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    count INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Table for Achievements
CREATE TABLE IF NOT EXISTS Achievements (
    achievement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    achieved_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    points INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Table for Community Posts (Cộng đồng)
CREATE TABLE IF NOT EXISTS CommunityPosts (
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Table for Community Comments (Cộng đồng)
CREATE TABLE IF NOT EXISTS CommunityComments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES CommunityPosts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Bảng Users
INSERT INTO Users (username, email, password) VALUES
('alice123', 'alice@example.com', 'hashed_password_alice'), -- Remember to hash passwords in a real application
('bob.builder', 'bob@example.com', 'hashed_password_bob'),
('charlie_coder', 'charlie@example.com', 'hashed_password_charlie'),
('Phuc Nguyen', 'phucnguyen@example.com', 'phucnguyen123');

-- Bảng Tasks
INSERT INTO Tasks (user_id, title, subject, description, due_date, priority, status) VALUES
(1, 'Hoàn thành Module Cơ bản', 'Văn', NULL, '2025-04-20', 1, 'Đang làm'),
(1, 'Luyện tập Bài tập Python', 'Toán', NULL, '2025-04-25', 2, 'Quá hạn'),
(2, 'Lên kế hoạch Cấu trúc', 'Vật Lý', NULL, '2025-04-25', 1, 'Hoàn thành'),
(2, 'Thiết kế Bản nháp', 'Hóa Học', NULL, '2025-05-05', 1, 'Đang làm'),
(1, 'Đọc "Sapiens"', 'Lịch sử', NULL, '2025-05-15', 3, 'Đang làm');

-- Bảng Pomodoro Sessions (Chế độ Pomodoro)
INSERT INTO PomodoroSessions (task_id, user_id, start_time, end_time, duration_seconds, type) VALUES
(1, 1, '2025-04-15 10:00:00', '2025-04-15 10:25:00', 1500, 'Làm việc'),
(1, 1, '2025-04-15 10:30:00', '2025-04-15 10:55:00', 1500, 'Làm việc'),
(3, 1, '2025-04-16 14:00:00', '2025-04-16 14:50:00', 3000, 'Làm việc'),
(3, 1, '2025-04-16 14:55:00', '2025-04-16 15:00:00', 300, 'Nghỉ ngắn'),
(4, 2, '2025-04-26 11:00:00', '2025-04-26 11:25:00', 1500, 'Làm việc');

-- Bảng Streaks
INSERT INTO Streaks (user_id, streak_type, start_date, end_date, count) VALUES
(1, 'hoàn thành_nhiệm_vụ_hàng_ngày', '2025-04-10', '2025-04-14', 5),
(2, 'phiên_pomodoro', '2025-04-12', '2025-04-14', 3),
(1, 'chuỗi_đọc_sách', '2025-04-14', '2025-04-14', 1);

-- Bảng Achievements
INSERT INTO Achievements (user_id, title, description, achieved_date, points) VALUES
(1, 'Người mới học Python', 'Hoàn thành module đầu tiên của khóa học Python', '2025-04-15', 50),
(2, 'Nhà Lập Kế Website', 'Lên kế hoạch cấu trúc cho website portfolio', '2025-04-25', 30),
(1, 'Ngày Đọc Sách Đầu Tiên', 'Đã đọc sách lần đầu tiên để hướng tới mục tiêu đọc sách', '2025-04-16', 20);

-- Bảng Community Posts (Cộng đồng)
INSERT INTO CommunityPosts (user_id, title, content) VALUES
(1, 'Rất hào hứng bắt đầu học Python!', 'Vừa mới bắt đầu hành trình Python của mình. Có lời khuyên nào cho người mới bắt đầu không?'),
(2, 'Ý tưởng Website Portfolio', 'Đang tìm kiếm cảm hứng cho website portfolio của mình. Chia sẻ những thiết kế bạn yêu thích!');

-- Bảng Community Comments (Cộng đồng)
INSERT INTO CommunityComments (post_id, user_id, content) VALUES
(1, 2, 'Chào mừng! Hãy tập trung vào những điều cơ bản trước và luyện tập thường xuyên nhé.'),
(1, 3, 'Có rất nhiều tài nguyên và cộng đồng trực tuyến tuyệt vời để giúp bạn.');
