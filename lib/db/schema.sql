-- General user quotes (i.e. every user line written to the channel)
CREATE TABLE IF NOT EXISTS user_quotes (
  id bigserial PRIMARY KEY,
  nickname varchar(25) NOT NULL,
  message text NOT NULL,
  date_added timestamp NOT NULL
);

-- Administrator users table
CREATE TABLE IF NOT EXISTS admins (
  id bigserial PRIMARY KEY,
  nickname VARCHAR(225) NOT NULL,
  hostname VARCHAR(225),
  date_added timestamp NOT NULL
);

-- Banned users table
CREATE TABLE IF NOT EXISTS banned_users (
  id bigserial PRIMARY KEY,
  nickname VARCHAR(225) NOT NULL,
  hostname VARCHAR(225),
  date_added timestamp NOT NULL
);

-- All 'Hi' quotes
CREATE TABLE IF NOT EXISTS hi_quotes (
  id bigserial PRIMARY KEY,
  quote text NOT NULL,
  date_added timestamp NOT NULL
);

-- All UPPERCASE quotes
CREATE TABLE IF NOT EXISTS uppercase_quotes (
  id bigserial PRIMARY KEY,
  quote text NOT NULL,
  nickname VARCHAR(225) NOT NULL,
  date_added timestamp NOT NULL
);
