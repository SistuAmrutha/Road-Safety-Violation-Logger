-- Ensure the table exists for embedded H2 (dev) so INSERT in this script won't fail
CREATE TABLE IF NOT EXISTS reports (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	description VARCHAR(2000),
	status VARCHAR(255),
	created_at TIMESTAMP
);

INSERT INTO reports (id, title, description, status, created_at) VALUES (1, 'First Report', 'Seeded report', 'OPEN', CURRENT_TIMESTAMP());
