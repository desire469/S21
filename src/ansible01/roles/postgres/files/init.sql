-- Создание таблицы
CREATE TABLE IF NOT EXISTS {{ table_name }} (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2),
    hire_date DATE NOT NULL,
    department VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Очистка таблицы (опционально)
TRUNCATE {{ table_name }} RESTART IDENTITY;

-- Вставка трех произвольных записей
INSERT INTO {{ table_name }} (first_name, last_name, position, salary, hire_date, department, email) VALUES
    ('Иван', 'Иванов', 'Senior Developer', 150000.00, '2020-01-15', 'IT', 'ivan.ivanov@example.com'),
    ('Мария', 'Петрова', 'Project Manager', 120000.00, '2021-03-20', 'Management', 'maria.petrova@example.com'),
    ('Алексей', 'Сидоров', 'DevOps Engineer', 130000.00, '2022-06-10', 'IT', 'alexey.sidorov@example.com');

-- Добавим еще несколько записей для демонстрации
INSERT INTO {{ table_name }} (first_name, last_name, position, salary, hire_date, department, email) VALUES
    ('Елена', 'Козлова', 'QA Engineer', 90000.00, '2022-11-05', 'QA', 'elena.kozlov@example.com'),
    ('Дмитрий', 'Новиков', 'System Administrator', 110000.00, '2019-08-12', 'IT', 'dmitry.novikov@example.com');

-- Создание индекса для оптимизации
CREATE INDEX IF NOT EXISTS idx_employees_last_name ON {{ table_name }}(last_name);

-- Создание представления
CREATE OR REPLACE VIEW high_salary_employees AS
SELECT first_name, last_name, position, salary, department
FROM {{ table_name }}
WHERE salary > 100000
ORDER BY salary DESC;