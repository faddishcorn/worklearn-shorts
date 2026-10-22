-- Apply this schema only to a newly created database.
CREATE TABLE admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    username TEXT NOT NULL UNIQUE CHECK (length(username) BETWEEN 1 AND 50),
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE videos (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT NOT NULL CHECK (length(title) BETWEEN 2 AND 100),
    description TEXT NOT NULL DEFAULT '' CHECK (length(description) <= 500),
    video_path TEXT NOT NULL,
    thumbnail_path TEXT DEFAULT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 30)
);

CREATE TABLE courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL CHECK (length(name) BETWEEN 2 AND 50),
    description TEXT NOT NULL DEFAULT '' CHECK (length(description) <= 300),
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE course_videos (
    course_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    sort_order INTEGER NOT NULL CHECK (typeof(sort_order) = 'integer' AND sort_order >= 1),
    PRIMARY KEY (course_id, video_id),
    UNIQUE (course_id, sort_order),
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE
);
