PRAGMA foreign_keys = ON;

DROP TABLE if exists question_likes;
DROP TABLE if exists replies;
DROP TABLE if exists question_follows;
DROP TABLE if exists questions;
DROP TABLE if exists users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(reply_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  questions (title, body)
VALUES
  ('CSS Question', 'CSS margin problems'),
  ('SQL Question', 'How to create tables');
  
INSERT INTO
  users (fname, lname)
VALUES
  ('Miso', 'Lee'),
  ('Sai', 'Pat');
  
INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1, 1),
  (2, 2);
  
INSERT INTO
  replies (body, question_id, user_id)
VALUES
  ('You are never going to learn CSS', 1, 1),
  ('Useless', 2, 2);

  