INSERT INTO users (name, email, password, role, email_verified, is_active)
VALUES ('Admin', 'admin@iset.tn', '$2a$12$j.QvqUwBNJ2PtmFbitB4PuiapvZ.uJjSRkomUU6CkL4d7zO3iqWyS', 'admin', true, true)
ON CONFLICT (email) DO UPDATE SET password = '$2a$12$j.QvqUwBNJ2PtmFbitB4PuiapvZ.uJjSRkomUU6CkL4d7zO3iqWyS', is_active = true, email_verified = true;
