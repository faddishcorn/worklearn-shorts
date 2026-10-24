-- 3조 DB 명세서 기준 schema.sql (SQLite, 테이블 11개)
-- 사용: backend/schema.sql 로 저장. DB 연결마다 PRAGMA foreign_keys=ON 을 적용해야 연쇄 삭제가 동작한다(src/db.js에서 설정).
-- 시각 기본값은 UTC ISO 8601 문자열.

CREATE TABLE admins (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  username      TEXT NOT NULL UNIQUE CHECK (length(username) BETWEEN 1 AND 50),
  password_hash TEXT NOT NULL,
  created_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE videos (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  title          TEXT NOT NULL CHECK (length(title) BETWEEN 2 AND 100),
  description    TEXT NOT NULL DEFAULT '' CHECK (length(description) <= 500),
  video_path     TEXT NOT NULL,
  thumbnail_path TEXT,
  created_at     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE tags (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 30)
);
-- trim·소문자 기준 중복 금지
CREATE UNIQUE INDEX ux_tags_name ON tags (lower(trim(name)));

CREATE TABLE courses (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL CHECK (length(name) BETWEEN 2 AND 50),
  description TEXT NOT NULL DEFAULT '' CHECK (length(description) <= 300),
  created_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE course_videos (
  course_id  INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  video_id   INTEGER NOT NULL REFERENCES videos(id)  ON DELETE CASCADE,
  sort_order INTEGER NOT NULL CHECK (sort_order >= 1),
  PRIMARY KEY (course_id, video_id),
  UNIQUE (course_id, sort_order)
);

CREATE TABLE video_tags (
  video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  tag_id   INTEGER NOT NULL REFERENCES tags(id)   ON DELETE CASCADE,
  PRIMARY KEY (video_id, tag_id)
);

CREATE TABLE video_views (
  video_id   INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  visitor_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  PRIMARY KEY (video_id, visitor_id)
);

CREATE TABLE video_likes (
  video_id   INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  visitor_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  PRIMARY KEY (video_id, visitor_id)
);

CREATE TABLE comments (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  video_id      INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  nickname      TEXT NOT NULL CHECK (length(nickname) BETWEEN 1 AND 20),
  password_hash TEXT NOT NULL,
  content       TEXT NOT NULL CHECK (length(content) BETWEEN 1 AND 500),
  created_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX ix_comments_video ON comments (video_id, created_at DESC, id DESC);

CREATE TABLE quizzes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  video_id   INTEGER NOT NULL UNIQUE REFERENCES videos(id) ON DELETE CASCADE,
  question   TEXT NOT NULL CHECK (length(question) BETWEEN 1 AND 200),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE quiz_options (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  quiz_id    INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  content    TEXT NOT NULL CHECK (length(content) BETWEEN 1 AND 100),
  sort_order INTEGER NOT NULL CHECK (sort_order BETWEEN 1 AND 5),
  is_correct INTEGER NOT NULL DEFAULT 0 CHECK (is_correct IN (0, 1)),
  UNIQUE (quiz_id, sort_order)
);
-- 퀴즈당 정답은 최대 1개
CREATE UNIQUE INDEX ux_quiz_one_correct ON quiz_options (quiz_id) WHERE is_correct = 1;
